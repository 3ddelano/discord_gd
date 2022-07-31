# Handles API requests
class_name DiscordRequestHandler
extends Reference

var options = {
	agent = null,
	base_url = "",
# 	decode_reasons = true,
# 	disable_latency_compensation = false,
# 	latency_threshold =  30000,
# 	ratelimiter_offset = 0,
	request_timeout = 15000
}

var client = null
var user_agent = ""
# var ratelimits = {}
# var latency_ref = {}
# var global_block = false
# var ready_queue = []

func _init(p_client, p_options = {}) -> void:

	client = p_client


	options.agent = p_client.options.get("agent", null)
	options.base_url = DiscordMetadata.REST_URL

	# Apply custom option overrides
	for k in p_options:
		options[k] = p_options[k]

	# if p_client.options.get("latency_threshold"):
	# 	options.latency_threshold = p_client.options.get("latency_threshold")
	# if p_client.options.get("ratelimiter_offset"):
	# 	options.ratelimiter_offset = p_client.options.get("ratelimiter_offset")
	if p_client.options.get("request_timeout"):
		options.request_timeout = p_client.options.get("request_timeout")

	user_agent = "DiscordBot (https://github.com/3ddelano/discord.gd,%s)" % DiscordMetadata.LIBRARY_VERSION
	# ratelimits = {}

	# var raw_array = []
	# var time_offsets_array = []
	# for i in range(10):
	# 	raw_array.append(options.ratelimiter_offset)
	# 	time_offsets_array.append(0)

	# latency_ref = {
	# 	latency = options.ratelimiter_offset,
	# 	raw = raw_array,
	# 	time_offset = 0,
	# 	time_offsets = time_offsets_array,
	# 	last_time_offset_check = 0
	# }

	# if options.forceQueueing:
	# 	global_block = true
	# 	client.connect("shard_pre_ready", self, "_on_client_shard_pre_ready", [], CONNECT_ONESHOT)


# func _on_client_shard_pre_ready():
# 	global_unblock()


# func global_unblock():
# 	global_block = false
# 	while len(ready_queue) > 0:
# 		var func_ref: FuncRef = ready_queue.shift()
# 		func_ref.call_func()


func request(p_method: String, p_url: String, p_auth: bool = false, p_body = "", p_file = null, p_route = null, p_short = null):
	var method = HTTPClient.METHOD_GET
	match p_method:
		"POST":
			method = HTTPClient.METHOD_POST
		"PUT":
			method = HTTPClient.METHOD_PUT
		"PATCH":
			method = HTTPClient.METHOD_PATCH
		"DELETE":
			method = HTTPClient.METHOD_DELETE
		"HEAD":
			method = HTTPClient.METHOD_HEAD
		"OPTIONS":
			method = HTTPClient.METHOD_OPTIONS

	var headers = {
		"User-Agent": user_agent
	}
	var final_url = p_url
	var data = null # Raw data if files are provided

	if p_auth:
		headers.Authorization = client.token

	# Audit log sniping
	if p_body and typeof(p_body) == TYPE_DICTIONARY and p_body.get("reason"):
		var unencoded_reason = p_body.reason
		if options.get("decode_reasons"):
			if unencoded_reason.find("%") > -1 and not unencoded_reason.find(" ") > -1:
				unencoded_reason = unencoded_reason.http_unescape()

		headers["X-Audit-Log-Reason"] = unencoded_reason.http_escape()
		if (method != HTTPClient.METHOD_POST or not p_url.find("/prune") > -1) and (method != HTTPClient.METHOD_PUT or not p_url.find("/bans") > -1):
			p_body.erase("reason")
		else:
			p_body.reason = unencoded_reason

	# If file is provided, use multipart data
	if p_file:
		if typeof(p_file) == TYPE_DICTIONARY and p_file.get("content_type"):
			p_file = [p_file]

		if typeof(p_file) == TYPE_ARRAY:
			headers["Content-Type"] = "multipart/form-data; boundary==\"xx__boundary__xx\""
			var _file_count = 0
			data = PoolByteArray()
			for file in p_file:
				data.append_array("--xx__boundary__xx\r\n".to_utf8())
				data.append_array(
					("Content-Disposition: form-data; name=\"files[%s]\"; filename=\"%s\"\r\n" % [_file_count, file.filename]).to_utf8()
				)
				data.append_array(("Content-Type: %s\r\n\r\n" % file.content_type).to_utf8())
				data.append_array(file.contents)
				data.append_array("\r\n".to_utf8())
				_file_count += 1
			if p_body:
				data.append_array("--xx__boundary__xx\r\n".to_utf8())
				data.append_array("Content-Disposition: form-data; name=\"payload_json\"\r\n".to_utf8())
				data.append_array(to_json(p_body).to_utf8())
				data.append_array("\r\n".to_utf8())
			data.append_array("--xx__boundary__xx--\r\n".to_utf8())
	elif p_body:
		if method == HTTPClient.METHOD_GET or method == HTTPClient.METHOD_DELETE:
			var query_string = DiscordUtils.query_string_from_dict(p_body)
			final_url += "?" + query_string
		else:
			headers["Content-Type"] = "application/json"
			p_body = to_json(p_body)

	var http_request = HTTPRequest.new()
	client.add_child(http_request)
	var headers_arr = []
	for k in headers.keys():
		headers_arr.append("%s: %s" % [k, headers[k]])
	if data != null:
		http_request.call_deferred("request_raw", options.base_url + final_url, headers_arr, true, method, data)
	else:
		http_request.call_deferred("request", options.base_url + final_url, headers_arr, true, method, p_body)

	var resp = yield(http_request, "request_completed")
	http_request.queue_free()

	var res := HTTPResponse.new(resp[0], resp[1], resp[2], resp[3])

	if res.is_error() or res.is_no_content():
		# Got some error or 204
		return res

	var content_type = null
	for header in res.headers:
		if header.to_lower().begins_with("content-type: "):
			content_type = header.substr(14)
			break
	match content_type:
		"application/json":
			var json = res.get_json()
			return json
		"image/png", "image/jpg", "image/gif":
			return res.body
		_:
			return res
