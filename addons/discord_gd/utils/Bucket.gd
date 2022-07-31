# Handle ratelimiting something
class_name Bucket extends Node

var interval: int # How long (in ms) to wait between clearing used tokens
var last_reset: int #  Timestamp of last token clearing
var last_send: int # Timestamp of last token consumption
var token_limit: int # The max number tokens the bucket can consume per interval
var tokens: int # How many tokens the bucket has consumed in this interval

var _queue: Array # The internal queue of Dictionary (priority: bool, func: [FuncRef])
var latency_ref
var reserved_tokens: int
var timeout # Node reference to timer


# Construct a Bucket
# @param token_limit: [int] The max number of tokens the bucket can consume per interval
# @param interval: [int] How long (in ms) to wait between clearing used tokens
# @param options: [Dictionary] Optional parameters `optional`
# @param options.latency_ref: [Object] A latency reference object
# @param options.latency_ref.latency: [int] Interval between consuming tokens
# @param options.reservedTokens: [int] How many tokens to reserve for priority operations
# @returns self
func _init(p_token_limit, p_interval, p_options = {}):
	token_limit = p_token_limit
	interval = p_interval
	if p_options.get("latency_ref") != null:
		latency_ref = p_options.latency_ref
	else:
		latency_ref = {latency =  0}
	last_reset = 0
	tokens = 0
	last_send = 0
	if p_options.get("reserved_tokens") != null:
		reserved_tokens = p_options.reserved_tokens
	else:
		reserved_tokens = 0

	_queue = []

	return self

func check():
	if timeout or _queue.size() > 0:
		return

	if last_reset + interval + token_limit * latency_ref.latency < OS.get_unix_time():
		last_reset = OS.get_unix_time()
		tokens = max(0, tokens - token_limit)

	var val
	var tokens_available = tokens < token_limit
	var unreserved_tokens_available = tokens < (token_limit - reserved_tokens)
	while _queue.size() > 0 and (unreserved_tokens_available || (tokens_available and _queue[0].priority)):
		tokens += 1
		tokens_available = tokens < token_limit
		unreserved_tokens_available = tokens < (token_limit - reserved_tokens)
		var item = _queue.pop_front()
		val = latency_ref.latency - OS.get_unix_time() + last_send
		if latency_ref.latency == 0 || val < 0:
			item.call_func("func")
			last_send = OS.get_unix_time()
		else:
			var timer = get_tree().create_timer(val / 1000)
			timer.connect("timeout", self, "_on_timer_timeout", [timer, item])
			last_send = OS.get_unix_time() + val

	if _queue.size() > 0 and not timeout:
		var check_inteval = latency_ref.latency
		if tokens >= token_limit:
			check_inteval = max(0, last_reset + interval + token_limit * latency_ref.latency - OS.get_unix_time())
		timeout = get_tree().create_timer(check_inteval / 1000)
		timeout.connect("timeout", self, "_on_timeout")


# Queue something in the Bucket
# @param func: [FuncRef] A callback to call when a token can be consumed
# @param priority: [bool] Whether or not the callback should use reserved tokens
func queue(p_func: FuncRef, p_priority = false):
	if p_priority:
		_queue.insert(0, {func = p_func, priority = true})
	else:
		_queue.append({func = p_func, priority = true})
	check()


func _on_timeout():
	check()
	timeout.queue_free()
	timeout = null


func _on_timer_timeout(timer, item):
	item.call_func("func")
	timer.queue_free()
	timer = null
