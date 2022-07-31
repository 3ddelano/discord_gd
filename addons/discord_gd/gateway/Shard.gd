class_name Shard extends DiscordDataclass

signal shard_ready()
signal hello(discord_server_trace, id)
signal resume()
signal unknown(dictionary, id)
signal raw_packet(dictionary, id)


signal connection_established(id)
signal disconnect(error)

signal debug(message, id)
signal warn(message, id)
signal error(message, id)

var id: int # The id of the shard
var connecting: bool # Whether the shard is connecting
var discord_server_trace: Array # [Array] of [String] Debug trace of Discord servers
var last_heartbeat_received = null # [int] Last time Discord acknowledged a heartbeat, null if shard has not sent heartbeat yet
var last_heartbeat_sent = null # [int] Last time shard sent a heartbeat, null if shard has not sent heartbeat yet
var latency: int = -1 # The current latency between the shard and Discord, in milliseconds
var ready: bool # Whether the shard is ready
var status: String = "disconnected" # The status of the shard "disconnected"/"connecting"/"handshaking"/"ready"/"identifying"/"resuming"
var client # [DiscordClient]

var pre_ready = false

var seq: int
var session_id = null # [String]
var reconnect_interval: int # In seconds
var connect_attempts: int
var last_heartbeat_ack = false
var ws: WebSocketClient

var heartbeat_timer: Timer
var connect_timer: Timer

var guild_create_timeout # [int]
var presence: Dictionary
var token: String


func _init(p_id: String, p_client).("Shard"):
	id = int(p_id)
	client = p_client

	hard_reset()

	return self


func reset():
	connecting = false
	ready = false
	pre_ready = false
	last_heartbeat_ack = false
	last_heartbeat_received = null
	last_heartbeat_sent = null
	latency = INF
	status = "disconnected"
	if connect_timer:
		client.queue_free(connect_timer)
		connect_timer = null

func hard_reset():
	reset()
	seq = 0
	session_id = null
	reconnect_interval = 1
	connect_attempts = 0
	ws = null
	if heartbeat_timer:
		client.queue_free(heartbeat_timer)
	heartbeat_timer = null
	guild_create_timeout = null
	presence = client.presence.duplicate(true)
	if client:
		token = client.token


func connect_shard():
	if ws and ws.get_connection_status() != WebSocketClient.CONNECTION_DISCONNECTED:
		emit_signal("error", "Existing connection detected", id)
		return

	connect_attempts += 1
	connecting = true
	initialize_ws()


func initialize_ws():
	if not token:
		return disconnect_shard(null, "Token not specified")
	status = "connecting"
	ws = WebSocketClient.new()
	ws.connect("connection_established", self, "_on_ws_connection_established")
	ws.connect("data_received", self, "_on_ws_data_received")
	ws.connect("connection_closed", self, "_on_ws_connection_closed")
	ws.connect("connection_error", self, "_on_ws_connection_error")
	ws.connect_to_url(client.gateway_url)
	client.process_nodes.append(self)


func disconnect_shard(p_options = {}, p_error = null):
	if not ws:
		return

	if heartbeat_timer:
		client.queue_free(heartbeat_timer)
		heartbeat_timer = null

	if ws.get_connection_status() != WebSocketClient.CONNECTION_DISCONNECTED:
		ws.disconnect("data_received", self, "_on_ws_data_received")
		ws.disconnect("connection_closed", self, "_on_ws_connection_closed")

		if p_options.get("reconnect") and session_id != null:
			if ws.get_connection_status() == WebSocketClient.CONNECTION_CONNECTED:
				ws.disconnect_from_host(4901, "Discord.gd: reconnect")
			else:
				emit_signal("debug", "Terminating websocket (connection_status: %s" % ws.get_connection_status(), id)
				ws.disconnect_from_host()
		else:
			ws.disconnect_from_host(1000, "Discord.gd: normal")
	ws = null
	reset()

	if p_error:
		emit_signal("error", p_error, id)

	emit_signal("disconnect", p_error)

	if session_id != null and connect_attempts > client.options.max_resume_attempts:
		emit_signal("debug", "Automatically invalidating session due to excessive resume attempts | Attempt %s" % connect_attempts, id)
		session_id = null

	if DiscordUtils.var_is_str(p_options.reconnect, "auto") and client.options.autoreconnect:
		if session_id:
			emit_signal("debug", "Immediately reconnecting for potential resume | Attempt %s" % connect_attempts, id)
			client.shards.connect(self)
		else:
			emit_signal("debug", "Queueing reconnect in %ss | Attempt %s" % [reconnect_interval, connect_attempts], id)
			var timer = client.get_tree().create_timer(reconnect_interval)
			yield(timer, "timeout")
			client.shards.connect(self)
			randomize()
			reconnect_interval = min(round(reconnect_interval + rand_range(1, 2)), 30)

	elif not p_options.get("reconnect"):
		hard_reset()


func _on_ws_connection_established(_protocol: String):
	last_heartbeat_ack = true
	emit_signal("connection_established", id)


func _on_ws_data_received():
	var data = ws.get_peer(1).get_packet()
	var dict = parse_json(data.get_string_from_utf8())
	_on_packet(dict)


func _on_packet(packet: Dictionary):
	if packet.t and packet.t != "GUILD_CREATE":
		print("on packet: ", JSON.print(packet, "\t", true))
	emit_signal("raw_packet", packet, id)

	if packet.s != null:
		if packet.s > seq + 1 and ws and status == "resuming":
			emit_signal("warn", "Non-consecutive sequence (%s -> %s)" % [seq, packet.s], id)
		seq = packet.s

	match int(packet.op):
		GatewayOPCodes.DISPATCH:
			ws_event(packet)
		GatewayOPCodes.HEARTBEAT:
			heartbeat()
			pass
		GatewayOPCodes.INVALID_SESSION:
			seq = 0
			session_id = null
			print("shard warn", "Invalid session, reidentifying!")
			emit_signal("warn", "Invalid session, reidentifying!", id)
			identify()
			pass
		GatewayOPCodes.RECONNECT:
			print("debug reconnect: ", "Reconnecting due to server request", id)
			emit_signal("debug", "Reconnecting due to server request", id)
			disconnect_shard({
				reconnect = "auto"
			})
			pass
		GatewayOPCodes.HELLO:
			if packet.d.heartbeat_interval > 0:
				if heartbeat_timer:
					client.queue_free(heartbeat_timer)
					heartbeat_timer = null
				heartbeat_timer = Timer.new()
				client.add_child(heartbeat_timer)
				heartbeat_timer.wait_time = packet.d.heartbeat_interval / 1000
				heartbeat_timer.start()
				heartbeat_timer.connect("timeout", self, "heartbeat", [true])
			discord_server_trace = packet.d._trace
			connecting = false
			if connect_timer:
				connect_timer.stop()
				client.queue_free(connect_timer)
				connect_timer = null
			if session_id != null:
				resume()
			else:
				identify()
				heartbeat()

			emit_signal("hello", packet.d._trace, id)
			pass
		GatewayOPCodes.HEARTBEAT_ACK:
			last_heartbeat_ack = true
			last_heartbeat_received = OS.get_ticks_msec()
			latency = last_heartbeat_received - last_heartbeat_sent
		_:
			emit_signal("unknown", packet, id)


func ws_event(packet: Dictionary):
	match packet.t:
		"PRESENCE_UPDATE":
			pass
		"VOICE_STATE_UPDATE":
			pass
		"TYPING_START":
			pass
		"MESSAGE_CREATE":
			pass
		"MESSAGE_UPDATE":
			pass
		"MESSAGE_DELETE":
			pass
		"MESSAGE_DELETE_BULK":
			pass
		"MESSAGE_REACTION_ADD":
			pass
		"MESSAGE_REACTION_REMOVE":
			pass
		"MESSAGE_REACTION_REMOVE_ALL":
			pass
		"MESSAGE_REACTION_REMOVE_EMOJI":
			pass
		"GUILD_MEMBER_ADD":
			pass
		"GUILD_MEMBER_UPDATE":
			pass
		"GUILD_MEMBER_REMOVE":
			pass
		"GUILD_CREATE":
			pass
		"GUILD_UPDATE":
			pass
		"GUILD_DELETE":
			pass
		"GUILD_BAN_ADD":
			pass
		"GUILD_BAN_REMOVE":
			pass
		"GUILD_ROLE_CREATE":
			pass
		"GUILD_ROLE_UPDATE":
			pass
		"GUILD_ROLE_DELETE":
			pass
		"INVITE_CREATE":
			pass
		"INVITE_DELETE":
			pass
		"CHANNEL_CREATE":
			pass
		"CHANNEL_UPDATE":
			pass
		"CHANNEL_DELETE":
			pass
		"CALL_CREATE":
			pass
		"CALL_UPDATE":
			pass
		"CALL_DELETE":
			pass
		"CHANNEL_RECIPIENT_ADD":
			pass
		"CHANNEL_RECIPIENT_REMOVE":
			pass
		"FRIEND_SUGGESTION_CREATE":
			pass
		"FRIEND_SUGGESTION_DELETE":
			pass
		"GUILD_MEMBERS_CHUNK":
			pass
		"GUILD_SYNC":
			pass
		"RESUMED", "READY":
			connect_attempts = 0
			reconnect_interval = 1
			connecting = false
			if connect_timer:
				client.queue_free(connect_timer)
				connect_timer = null
			status = "ready"
			presence.status = "online"
			client.shards._ready_packet_cb(id)

			if packet.t == "RESUMED":
				heartbeat()
				pre_ready = true
				ready = true
				emit_signal("resume")
			client.user = client.users.update(ExtendedUser.new(packet.d.user, client), client)
		"VOICE_SERVER_UPDATE":
			pass
		"USER_UPDATE":
			pass
		"RELATIONSHIP_ADD":
			pass
		"RELATIONSHIP_REMOVE":
			pass
		"GUILD_EMOJIS_UPDATE":
			pass
		"GUILD_STICKERS_UPDATE":
			pass
		"CHANNEL_PINS_UPDATE":
			pass
		"WEBHOOKS_UPDATE":
			pass
		"PRESENCES_REPLACE":
			pass
		"USER_NOTE_UPDATE":
			pass
		"USER_GUILD_SETTINGS_UPDATE":
			pass
		"THREAD_CREATE":
			pass
		"THREAD_UPDATE":
			pass
		"THREAD_DELETE":
			pass
		"THREAD_LIST_SYNC":
			pass
		"THREAD_MEMBER_UPDATE":
			pass
		"THREAD_MEMBERS_UPDATE":
			pass
		"STAGE_INSTANCE_CREATE":
			pass
		"STAGE_INSTANCE_UPDATE":
			pass
		"STAGE_INSTANCE_DELETE":
			pass
		"MESSAGE_ACK":
			pass
		"GUILD_INTEGRATIONS_UPDATE":
			pass
		"USER_SETTINGS_UPDATE":
			pass
		"CHANNEL_PINS_ACK":
			pass
		"INTERACTION_CREATE":
			pass


func resume():
	status = "resuming"
	send_ws(GatewayOPCodes.RESUME, {
		token = token,
		session_id = session_id,
		seq = seq
	})


func heartbeat(normal = false):
	if status == "resuming" or status == "identifying":
		return

	if normal:
		if last_heartbeat_ack == null:
			emit_signal("debug", "Heartbeat timeout;%s" % to_json({
				last_received = last_heartbeat_received,
				last_sent = last_heartbeat_sent,
				interval = heartbeat_timer.wait_time,
				status = status,
				timestamp = OS.get_ticks_msec()
			}))
			disconnect_shard({
				reconnect = "auto"
			}, "Server didn't acknowledge previous heartbeat, possible lost connection")
		last_heartbeat_ack = false

	last_heartbeat_sent = OS.get_ticks_msec()
	send_ws(GatewayOPCodes.HEARTBEAT, seq, true)


func identify():
	status = "identifying"
	var payload = {
		token = token,
#		v = DiscordMetadata.GATEWAY_VERSION,
		large_threshold = client.options.get("large_threshold"),
		intents = client.options.intents,
		properties = {
			os = OS.get_name(),
			browser = "Discord.gd",
			device = "Discord.gd",
		}
	}
	if presence and presence.has("status"):
		payload.presence = presence
	send_ws(GatewayOPCodes.IDENTIFY, payload)


func send_ws(op, _data, priority = false):
	if ws and ws.get_connection_status() == WebSocketClient.CONNECTION_CONNECTED:
		var data = to_json({
			op = op,
			d = _data
		})
		ws.get_peer(1).put_packet(data.to_utf8())


func _on_ws_connection_closed(_was_clean_close: bool):
	print("connection _on_ws_connection_closed, ", _was_clean_close)


func _on_ws_connection_error():
	print("connection _on_ws_connection_error")


func _process(delta):
	if ws:
		ws.poll()
