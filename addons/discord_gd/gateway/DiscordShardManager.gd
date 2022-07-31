class_name DiscordShardManager extends DiscordCollection

var client # [DiscordClient]

#var options = {
#	concurrency = 1
#}

var connect_queue = []
var _connect_timer: Timer


func _init(p_client, p_options = {}).(Shard, -1, "DiscordShardManager"):
	client = p_client

#	for k in p_options:
#		options[k] = p_options[k]

	_connect_timer = Timer.new()
	client.add_child(_connect_timer)
	_connect_timer.wait_time = 0.5
	_connect_timer.one_shot = true
	_connect_timer.connect("timeout", self, "_on_connect_timer_timeout")

	return self


func connect_shard(shard):
	connect_queue.append(shard)
	try_connect_shard()
	_connect_timer.start()


func try_connect_shard():
	if connect_queue.size() == 0:
		return

	# TODO: handle connecting multiple shards
	var shard = connect_queue.pop_front()
	if not shard:
		return

	print("connecting shard")
	shard.connect_shard()
	_connect_timer.start()


func spawn(id):
	id = str(id)
	var shard = get(id)

	if not shard:
		shard = add(Shard.new(id, client))
		shard.connect("shard_ready", self, "_on_shard_ready", [shard])
		shard.connect("resume", self, "_on_shard_resume", [shard])
		shard.connect("disconnect", self, "_on_shard_disconnect", [shard])

	if shard.status == "disconnected":
			return connect_shard(shard)


func _ready_packet_cb(id):
	print("Shard %s is ready!" % id)
	try_connect_shard()


func _on_connect_timer_timeout():
	print("Shard timer timeout")
	try_connect_shard()


func _on_shard_ready(shard):
	client.emit_signal("shard_ready", shard.id)
	if not client.ready:
		return

	for other in _dict.values():
		if not other.ready:
			return

	client.ready = true
	client.start_time = OS.get_ticks_msec()
	client.emit_signal("client_ready")


func _on_shard_resume(shard):
	client.emit_signal("shard_resume", shard.id)
	if not client.ready:
		return
	for other in _dict.values():
		if not other.ready:
			return

	client.ready = true
	client.start_time = OS.get_ticks_msec()
	client.emit_signal("client_ready")


func _on_shard_disconnect(error, shard):
	client.emit_signal("shard_disconnect", error, shard.id)
	for other in _dict.values():
		if other.ready:
			return

	client.ready = false
	client.start_time = 0
	client.emit_signal("client_disconnect")
