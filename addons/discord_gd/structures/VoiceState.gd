# Represents a Discord member's voice state in a call/guild
#
# id: The id of the member
class_name VoiceState extends DiscordBase

var channel_id = null # [String] The id of the member's current voice channel
var deaf: bool # Whether the member is server deafened or not
var mute: bool # Whether the member is server muted or not
var request_to_speak_timestamp = null # [int] Timestamp of the member's latest request to speak
var self_deaf: bool # Whether the member is self deafened or not
var self_mute: bool # Whether the member is self muted or not
var self_stream: bool # Whether the member is streaming using "Go Live"
var self_video: bool # Whether the member's camera is enabled
var suppress: bool # Whether the member is suppressed or not
var session_id = null # [String] The id of the member's current voice session


# @hidden
func _init(p_dict).(p_dict.get("id", null), "VoiceState"):
	mute = false;
	deaf = false;
	request_to_speak_timestamp = null;
	self_mute = false;
	self_deaf = false;
	self_stream = false;
	self_video = false;
	suppress = false;

	update(p_dict)

	return self


func update(p_dict):
	if p_dict.get("channel_id") != null:
		channel_id = p_dict.channel_id
		if p_dict.get("session_id") != null:
			session_id = p_dict.session_id
		else:
			session_id = p_dict.channel_id
	else:
		channel_id = null
		session_id = null

	if p_dict.get("mute") != null:
		mute = p_dict.mute
	if p_dict.get("deaf") != null:
		deaf = p_dict.deaf
	if p_dict.get("request_to_speak_timestamp") != null:
		request_to_speak_timestamp = p_dict.request_to_speak_timestamp
	if p_dict.get("self_mute") != null:
		self_mute = p_dict.self_mute
	if p_dict.get("self_deaf") != null:
		self_deaf = p_dict.self_deaf
	if p_dict.get("self_video") != null:
		self_video = p_dict.self_video
	if p_dict.get("self_stream") != null:
		self_stream = p_dict.self_stream
	if p_dict.get("suppress") != null: # Bots ignore this
		suppress = p_dict.suppress


# @hidden
func to_dict(p_props = []) -> Dictionary:
	p_props.append_array([
		"channel_id",
		"deaf",
		"mute",
		"request_to_speak_timestamp",
		"self_deaf",
		"self_mute",
		"self_stream",
		"self_video",
		"session_id",
		"suppress",
	])
	return .to_dict(p_props)
