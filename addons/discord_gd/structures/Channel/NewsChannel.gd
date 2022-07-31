# Represents a guild news channel
#
# See [TextChannel] for more properties and methods
class_name NewsChannel extends TextChannel


# @hidden
func _init(p_dict, p_client, p_message_limit = null).(p_dict, p_client, p_message_limit, "NewsChannel"):

	rate_limit_per_user = 0
	update(p_dict)

	return self


# @hidden
func update(p_dict):
	.update(p_dict)

	if "rate_limit_per_user" in p_dict:
		rate_limit_per_user = p_dict.rate_limit_per_user
	if "topic" in p_dict:
		topic = p_dict.topic
	if "default_auto_archive_duration" in p_dict:
		default_auto_archive_duration = p_dict.default_auto_archive_duration


# Crosspost a message to subscribed channels
# @param message_id: [String] The id of the message
# @returns [Message] | [HTTPResponse] if error
func crosspost_message(p_message_id: String) -> Message:
	return client.crosspost_message(id, p_message_id)


# Follow this channel in another channel. This creates a webhook in the target channel
# @param webhook_channel_id: [String] The id of the target channel
# @returns [Dictionary] A dictionary containing this channel's id and the new webhook's id | [HTTPResponse] if error
func follow(p_webhook_channel_id: String) -> Dictionary:
	return client.follow_channel(id, p_webhook_channel_id)


# @hidden
func to_dict(p_props = []) -> Dictionary:
	p_props.append_aray([
		"last_message_id",
		"last_pin_timestamp",
		"messages",
		"rate_limit_per_user",
		"topic",
	])
	return .to_dict(p_props)
