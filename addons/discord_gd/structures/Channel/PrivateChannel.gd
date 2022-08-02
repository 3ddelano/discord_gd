# Represents a Discord private channel
#
# See [Channel] for extra properties
class_name PrivateChannel extends Channel

var last_message_id: String #  The id of the last message in this channel
var messages: DiscordCollection # [DiscordCollection] Collection of messages in this channel
var recipient: User # The recipient in this private channel (private channels only)
var rate_limit_per_user: int


# @hidden
func _init(p_dict, p_client).(p_dict, p_client, "PrivateChannel"):
	if "last_message_id" in p_dict:
		last_message_id = p_dict.last_message_id
	if "rate_limit_per_user" in p_dict:
		rate_limit_per_user = p_dict.rate_limit_per_user
	if type == ChannelTypes.DM or type == null:
		recipient = User.new(p_dict.recipients[0], p_client)
	messages = DiscordCollection.new(Message, client.options.message_limit)

	return self


# Add a reaction to a message
# @param message_id: [String] The id of the message
# @param reaction: [String] The reaction (Unicode string if Unicode emoji, `emoji_name:emoji_id` if custom emoji)
# @param user_id: [String] The id of the user to react as. Defaults to the bot user. `optional`
# @returns [bool] | [HTTPResponse] if error
func add_message_reaction(p_message_id, p_reaction, p_user_id = "@me") -> bool:
	return client.add_message_reaction(id, p_message_id, p_reaction, p_user_id)


# Create a message in the channel TODO: add docs
# @returns [Message] | [HTTPResponse] if error
func create_message(p_dict, p_files = []):
	return client.create_message(id, p_dict, p_files)


# Delete a message
# @param message_id: [String] The id of the message
# @param reason: [String] The reason to be displayed in audit logs `optional`
# @returns [bool] | [HTTPResponse] if error
func delete_message(p_message_id, p_reason = null) -> bool:
	return client.delete_message(id, p_message_id, p_reason)


# Edit a message TODO: add docs
# @returns [Message] | [HTTPResponse] if error
func edit_message(p_message_id: String, p_dict):
	return client.edit_message(id, p_message_id, p_dict)


# Get a previous message in the channel
# @param message_id: [String] The id of the message
# @returns [Message] | [HTTPResponse] if error
func get_message(p_message_id: String):
	return client.get_message(id, p_message_id)


# Get a list of users who reacted with a specific reaction
# @param message_id: [String] The id of the message
# @param reaction: [String] The reaction (Unicode string if Unicode emoji, `emoji_name:emoji_id` if custom emoji)
# @param options: [Dictionary] Options for the request (all properties are `optional`)
# @param options.limit: [int] The maximum number of users to get (default is 100)
# @param options.after: [String] Get users after this user id
# @returns [Array] of [User]
func get_message_reaction(p_message_id: String, reaction: String, options = null) -> Array:
	return client.get_message_reaction(id, p_message_id, reaction, options)


# Get previous messages in the channel
# @param options: [Dictionary] Options for the request `optional`
# @param options.after: [String] Get messages after this message id
# @param options.around: [String] Get messages around this message id (does not work with limit > 100)
# @param options.before: [String] Get messages before this message id
# @param options.limit: [int] The max number of messages to get (default is 50)
# @returns [Array] of [Message]
func get_messages(options = null) -> Array:
	return client.get_messages(id, options)


# Get all the pins in the channel
# @returns [Array] of [Message]
func get_pins() -> Array:
	return client.get_pins(id)


# Leave the channel
# @returns [bool] | [HTTPResponse] if error
func leave() -> bool:
	return client.delete_channel(id)


# Pin a message
# @param message_id: [String] The id of the message
# @returns [bool] | [HTTPResponse] if error
func pin_message(p_message_id: String) -> bool:
	return client.pin_message(id, p_message_id)


# Remove a reaction from a message
# @param message_id: [String] The id of the message
# @param reaction: [String] The reaction (Unicode string if Unicode emoji, `emoji_name:emoji_id` if custom emoji)
# @param user_id: [String] The id of the user to remove the reaction for (default is "@me") `optional`
# @returns [bool] | [HTTPResponse] if error
func remove_message_reaction(p_message_id: String, p_reaction: String, p_user_id = "@me") -> bool:
	return client.remove_message_reaction(id, p_message_id, p_reaction, p_user_id)


# Send typing status in the channel
# @returns [bool] | [HTTPResponse] if error
func send_typing() -> bool:
	return client.send_channel_typing(id)


# Unpin a message
# @param message_id: [String] The id of the message
# @returns [bool] | [HTTPResponse] if error
func unpin_message(p_message_id: String) -> bool:
	return client.unpin_message(id, p_message_id)



# @hidden
func to_dict(p_props = []) -> Dictionary:
	p_props.append_aray([
		"last_message_id",
		"messages",
		"recipient",
	])
	return .to_dict(p_props)
