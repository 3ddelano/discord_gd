# Ratelimit requests and release in sequence
#
# TODO: add latencyref
class_name SequentialBucket extends Node

var limit: int # How many tokens the bucket can consume in the current interval
var processing # Whether the queue is being processed
var remaining: int # How many tokens the bucket has left in the current interval
var reset: int # Timestamp of next reset

var _queue: Array # The internal queue of Dictionary (priority: bool, func: [FuncRef])
var latency_ref
var last

# Construct a SequentialBucket
# @param limit : [int] The max number of tokens the bucket can consume per interval
# @param latency_ref: [Object] A latency reference object
# @param latency_ref.latency: [int] Interval between consuming tokens
# @returns self
func _init(p_limit, p_latency_ref = {latency = 0}):
	limit = p_limit
	remaining = p_limit
	reset = 0
	processing = false
	latency_ref = p_latency_ref
	_queue = []

	return self

func check(override):
	if _queue.size() == 0:
		if processing:
			processing.queue_free()
			processing = null
		return
	if processing and not override:
		return
	var now = OS.get_unix_time()
	var offset = latency_ref.latency
	if not reset || reset < now - offset:
		reset = now - offset
		remaining = limit

	last = now
	if remaining <= 0:
		processing = get_tree().create_timer((max(0, reset - now + offset) + 1)/1000)
		processing.connect("timeout", self, "_on_timer_timeout")
		return

	remaining -= 1
	processing = true
	var elm: FuncRef = _queue.pop_front()
	elm.call_func(funcref(self, "_callback"))


# Queue something in the SequentialBucket
# @param func: [FuncRef] A function to call when a token can be consumed. The function will be passed a callback argument, which must be called to allow the bucket to continue to work
func queue(p_func: FuncRef, p_short = false):
	if p_short:
		_queue.insert(0, p_func)
	else:
		_queue.append(p_func)
	check(false)


func _callback():
	if _queue.size() > 0:
		check(true)
	else:
		processing = false

func _on_timer_timeout():
	check(true)
	processing.queue_free()
	processing = null
