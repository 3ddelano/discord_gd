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

# Fired when a user's avatar, discriminator or username changes
# @param user: [User] The updated user
# @param old_user: [Dictionary] The old user data. If the user was uncached, this will be null, otherwise it will contain username, discriminator and avatar.
signal user_update(user, old_user)
signal presence_update(member, old_presence)

# Fired when a user begins typing
# @param channel: [PrivateChannel] | [TextChannel] | [NewsChannel] | [Dictionary] The text channel the user is typing in. If the channel is not cached, this will be a Dictionary with an `id` key. No other property is guaranteed
# @param user: [User] | [Dictionary] The user. If the user is not cached, this will be a Dictionary with an `id` key. No other property is guaranteed
# @param member: [Member] The guild member, if typing in a guild channel, or `null`, if typing in a PrivateChannel
signal typing_start(channel, user, member)
signal message_create(message)

# Fired when a message is updated
# @param message: [Message] The updated message. If old_message is null, it is recommended to discard this event, since the message data will be very incomplete (only `id` and `channel` are guaranteed). If the channel isn't cached, `channel` will be a Dictionary with an `id` key
# @param old_message: [Dictionary] The old message data. If the message was cached, this will return the full old message. Otherwise, it will be null
# @param old_message.attachments: [Array] of [Dictionary] Array of attachments
# @param old_message.channel_mentions: [Array] of [String] Array of mentions channels' ids
# @param old_message.content: [String] Message content
# @param old_message.edited_timestamp: [int] Timestamp of latest message edit
# @param old_message.embeds: [Array] of [Dictionary] Array of embeds
# @param old_message.flags: [int] Old message flags
# @param old_message.mentioned_by: [Dictionary] Dictionary of if different things mention the bot user
# @param old_message.mentions: [Array] of [User] Array of mentioned users
# @param old_message.pinned: [bool] Whether the message was pinned or not
# @param old_message.role_mentions: [Array] of [String] Array of mentioned roles' ids
# @param old_message.tts: [bool] Whether or not to play the message using TTS
signal message_update(message, old_message)

# Fired when a cached message is deleted
# @param message: [Message] | [Dictionary] If the message is not cached, this will be a Dictionary with an `id` key. If the uncached message is from a guild, the message will also contain a `guild_id` key, and the channel will contain a `guild` with an `id` key. No other property is guaranteed
signal message_delete(message)

# Fired when a bulk delete occurs
# @param messages: [Array] of [Message] | [Array] of [Dictionary] An array of (potentially partial) message objects. If a message is not cached, it will be an object with `id` and `channel` keys. If the uncached messages are from a guild, the messages will also contain a `guild_id` key, and the channel will contain a `guild` with an `id` key. No other property is guaranteed
signal message_bulk_delete(messages)

# Fired when a guild becomes available
# @param guild: [Guild] The guild that became available
signal guild_available(guild)

# Fired when a guild is created. This happens when:
# - the client creates a guild
# - the client joins a guild
# @param guild: [Guild] The guild
signal guild_create(guild)

# Fired when an unavailable guild is created
# @param unavailable_guild: [UnavailableGuild] The unavailable guild
signal unavailble_guild_create(unavailable_guild)

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
var get_all_users_count = {}
var get_all_users_queue = {}
var get_all_users_length = 1


func _init(p_id: String, p_client).("Shard", {print_exclude = ["token"]}):
	id = int(p_id)
	client = p_client

	hard_reset()


	connect("debug", self, "_on_shard_debugwarnerror", ["debug"])
	connect("warn", self, "_on_shard_debugwarnerror", ["warn"])
	connect("error", self, "_on_shard_debugwarnerror", ["error"])

	return self

func _on_shard_debugwarnerror(msg, id, level):
	print(level, ", ", msg, ", ", id)

func reset():
	connecting = false
	ready = false
	pre_ready = false

	# TODO: add remaining vars
	get_all_users_count = {}
	get_all_users_queue = {}
	get_all_users_length = 1


	latency = INF
	last_heartbeat_ack = false
	last_heartbeat_received = null
	last_heartbeat_sent = null
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
	if packet.t and not packet.t in ["READY", "GUILD_CREATE"]:
		print("on shard packet: ", JSON.print(packet, "\t", true))
	emit_signal("raw_packet", packet, id)

	if "s" in packet and packet.s != null:
		if packet.s > seq + 1 and ws and status != "resuming":
			emit_signal("warn", "Non-consecutive sequence (%s -> %s)" % [seq, packet.s], id)
		seq = packet.s

	var GatewayOPCodes = DiscordConstants.GatewayOPCodes

	match int(packet.op):
		GatewayOPCodes.DISPATCH:
			if client.options.disable_events.has(packet.t) and not client.options.disable_events[packet.t]:
				ws_event(packet)
		GatewayOPCodes.HEARTBEAT:
			heartbeat()
		GatewayOPCodes.INVALID_SESSION:
			seq = 0
			session_id = null
			emit_signal("warn", "Invalid session, reidentifying!", id)
			identify()
		GatewayOPCodes.RECONNECT:
			emit_signal("debug", "Reconnecting due to server request", id)
			disconnect_shard({
				reconnect = "auto"
			})
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
			if "username" in packet.d.user:
				var user = client.users.get(packet.d.user.id)
				var old_user = null

				if user and (user.username != packet.d.user.username || user.discriminator != packet.d.user.discriminator || user.avatar != packet.d.user.avatar):
					old_user = {
						username = user.username,
						discriminator = user.discriminator,
						avatar = user.avatar
					}

				if not user || old_user:
					user = client.users.update(packet.d.user, [client])
					emit_signal("user_update", user, old_user)
			var guild = client.guilds.get(packet.d.guild_id)
			if not guild:
				emit_signal("debug", "Rogue presence update: " + str(packet), id)
			else:
				var member = guild.members.get(packet.d.user.id)
				var old_presence = null
				if member:
					old_presence = {
						activities = member.activities,
						client_status = member.client_status,
						status = member.status
					}
				if (not member and packet.d.user.username) or old_presence:
					member = guild.members.update(packet.d, [guild])
					emit_signal("presence_update", member, old_presence)
		"VOICE_STATE_UPDATE":
			pass
		"TYPING_START":
			var member = null
			var guild = client.guilds.get(packet.d.guild_id)
			if guild:
				packet.d.member.id = packet.d.user_id
				member = guild.members.update(packet.d.member, [guild])
			var channel = client.get_channel(packet.d.channel_id)
			if not channel:
				channel = {id = packet.d.channel_id}
			var user = client.users.get(packet.d.user_id)
			if not user:
				user = {id = packet.d.user_id}
			emit_signal("typing_start", channel, user, member)
		"MESSAGE_CREATE":
			var channel = client.get_channel(packet.d.channel_id)
			if channel:
				channel.last_message_id = packet.d.id
				emit_signal("message_create", channel.messages.add(packet.d, [client]))
			else:
				emit_signal("message_create", Message.new(packet.d, [client]))
		"MESSAGE_UPDATE":
			var channel = client.get_channel(packet.d.channel_id)
			if not channel:
				packet.d.channel = {
					id = packet.d.channel_id
				}
				emit_signal("message_update", packet.d, null)
			else:
				var message = channel.messages.get(packet.d.id)
				var old_message = null
				if message:
					old_message = {
						attachments = message.attachments,
						channel_mentions = message.channel_mentions,
						content = message.content,
						edited_timestamp = message.edited_timestamp,
						embeds = message.embeds,
						flags = message.flags,
						mentioned_by = message.mentioned_by,
						mention_everyone = message.mention_everyone,
						pinnned = message.pinnned,
						role_mentions = message.role_mentions,
						tts = message.tts
					}
				if not "timestamp" in packet.d or not packet.d.timestamp:
					packet.d.channel = channel
					emit_signal("message_update", packet.d, null)
				else:
					emit_signal("message_update", channel.messages.update(packet.d, [client]), old_message)
		"MESSAGE_DELETE":
			var channel = client.get_channel(packet.d.channel_id)
			var removed_message = null
			if channel:
				removed_message = channel.messages.remove(packet.d)
			if not removed_message:
				removed_message = {
					id = packet.d.id,
					guild_id = packet.d.get("guild_id", null),
				}
				if channel:
					removed_message.channel = channel
				else:
					removed_message.channel = {
						id = packet.d.channel_id
					}
					if "guild_id" in packet.d:
						removed_message.channel.guild = {
							id = packet.d.guild_id
						}
			emit_signal("message_delete", removed_message)
		"MESSAGE_DELETE_BULK":
			var channel = client.get_channel(packet.d.channel_id)

			var removed_messages = []
			for msg_id in packet.d.ids:
				if channel:
					var ret = channel.messages.remove({id = msg_id})
					if ret:
						removed_messages.append(ret)
					else:
						removed_messages.append({
							id = msg_id,
							channel = {
								id = packet.d.channel_id,
								guild = {id = packet.d.guild_id} if packet.d.guild_id else null
							},
							guild_id = packet.d.get("guild_id", null)
						})
			emit_signal("message_bulk_delete", removed_messages)
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
			if not packet.d.get("unavailable", true):
				var guild = create_guild(packet.d)
				if ready:
					if client.unavailable_guilds.remove(packet.d):
						emit_signal("guild_available", guild)
					else:
						emit_signal("guild_create", guild)
				else:
					client.unavailable_guilds.remove(packet.d)
					# TODO: uncomment this
					# restart_guild_create_timeout()
			else:
				client.guild.remove(packet.d)
				emit_signal("unavailble_guild_create", client.unavailable_guilds.add(packet.d, [client]))
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
			var guild = client.guilds.get(packet.d.guild_id)
			if not guild:
				var msg = "missing"
				if client.unavailable_guilds.has(packet.d.guild_id):
					msg = "unavailable"
				emit_signal("debug", "Received GUILD_MEMBERS_CHUNK, but guild %s is %s" % [packet.d.guild_id, msg], id)
			else:
				var members = []
				for member in packet.d.members:
					member.id = member.user.id
					members.append(guild.members.add(member, [guild]))

				if "presences" in packet.d and packet.d.presences:
					for presence in packet.d.presences:
						var member = guild.members.get(presence.user.id)
						if member:
							member.update(presence)

				# TODO: complete this
				#if request_members_promise:

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
			else:
				client.user = client.users.update(ExtendedUser.new(packet.d.user, client), [])
				if not client.token.begins_with("Bot "):
					client.token = "Bot " + client.token
				if "_trace" in packet.d:
					discord_server_trace = packet.d._trace
				session_id = packet.d.session_id

				for guild in packet.d.guilds:
					if guild.get("unavailabe", false):
						client.guilds.remove(guild)
						client.unavailable_guilds.add(guild, [client], true)
					else:
						client.unavailable_guilds.remove(create_guild(guild))

				client.application = packet.d.application
				pre_ready = true
				emit_signal("shard_pre_ready", id)

				# TODO: uncomment these functions
				if client.unavailble_guilds.size() > 0 and packet.d.guilds.size() > 0:
					# restart_guild_create_timeout()
					pass
				else:
					# check_ready()
					pass
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
			# ignore these
			pass
		"GUILD_INTEGRATIONS_UPDATE":
			# ignore these
			pass
		"USER_SETTINGS_UPDATE":
			# ignore these
			pass
		"CHANNEL_PINS_ACK":
			# ignore these
			pass
		"INTERACTION_CREATE":
			pass
		_:
			emit_signal("unknown", packet, id)


func resume():
	status = "resuming"
	send_ws(DiscordConstants.GatewayOPCodes.RESUME, {
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
	send_ws(DiscordConstants.GatewayOPCodes.HEARTBEAT, seq, true)


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
	send_ws(DiscordConstants.GatewayOPCodes.IDENTIFY, payload)


func send_ws(op, _data, priority = false):
	if ws and ws.get_connection_status() == WebSocketClient.CONNECTION_CONNECTED:
		var data = to_json({
			op = op,
			d = _data
		})
		ws.get_peer(1).put_packet(data.to_utf8())


func create_guild(p_guild):
	client.guild_shard_map[p_guild.id] = id
	var guild = client.guilds.add(p_guild, [client], true)

	print("-----called here")
	print(p_guild)
	print(client.options.get_all_users)
	print(guild.members.size)
	print(guild.member_count)

	if client.options.get("get_all_users") and guild.members.size < guild.member_count:
		get_guild_members(guild.id, {
			presences = client.options.intents & DiscordConstants.Intents.GUILD_PRESENCES if client.options.get("intents") else false
		})
	return guild


func get_guild_members(p_guild_id, p_timeout = null):
	if get_all_users_count.has(p_guild_id):
		DiscordUtils.perror("Shard %s: Cannot request all members while an existing request is processing" % id)
		return
	get_all_users_count[p_guild_id] = true
	# Using intents, request one guild at a time
	if client.options.get("intents"):
		if not client.options.intents & DiscordConstants.Intents.GUILD_MEMBERS:
			DiscordUtils.perror("Shard %s: Cannot request all members without GUILD_MEMBERS intent" % id)
		request_guild_members([p_guild_id], p_timeout)
	else:
		# 4096 - "{\"op\":8,\"d\":{\"guild_id\":[],\"query\":\"\",\"limit\":0}}".length + 1 for lazy comma offset
		if get_all_users_length + 3 + p_guild_id.length > 4048:
			request_guild_members(get_all_users_queue)
			get_all_users_queue = [p_guild_id]
			get_all_users_length = 1 + p_guild_id.length + 3
		else:
			get_all_users_queue.append(p_guild_id)
			get_all_users_length += p_guild_id.length + 3


func request_guild_members(p_guild_id, p_options = {}):
	var opts = {
		guild_id = p_guild_id,
		limit = p_options.get("limit", 0),
		user_ids = p_options.get("user_ids", null),
		query = p_options.get("query", null),
		nonce = str(OS.get_ticks_usec()) + str(randf()),
		presences = p_options.get("presences", null)
	}
	if not opts.user_ids and not opts.query:
		opts.query = ""
	if not opts.query and not opts.user and (client.options.get("intents") and not (client.options.intents & DiscordConstants.Intents.GUILD_MEMBERS)):
		DiscordUtils.perror("Shard %s: Cannot request all members without GUILD_MEMBERS intent" % id)
		return
	if opts.presences and (client.options.get("intents") and not client.options.intents & DiscordConstants.Intents.GUILD_PRESENCES):
		DiscordUtils.perror("Shard %s: Cannot request members presences without GUILD_PRESENCES intent" % id)
		return

	print("requesting guild members: ", opts)
	send_ws(DiscordConstants.GatewayOPCodes.REQUEST_GUILD_MEMBERS, opts)


func _on_ws_connection_closed(was_clean_close: bool):
	print("shard connection closed")
	emit_signal("debug", "WS disconnected: was_clean_close = %s" % was_clean_close)

	var reconnect = "auto"
	disconnect_shard({reconnect = reconnect}, "WS disconnected")


func _on_ws_connection_error():
	print("shard connection _on_ws_connection_error")


func _process(delta):
	if ws:
		ws.poll()
