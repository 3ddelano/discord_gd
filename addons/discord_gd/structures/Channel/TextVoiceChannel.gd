# Represents a Discord text in voice channel
#
# See [VoiceChannel] for extra properties and methods
class_name TextVoiceChannel extends VoiceChannel

var messages: DiscordCollection # [DiscordCollection] Collection of messages in this channel
var last_message_id = null # [String] Id of the last message in this channel
var rate_limit_per_user = null # [int] The ratelimit of the channel, in seconds. 0 means no ratelimit is enabled

# @hidden
func _init(p_dict, p_client, _name = "TextVoiceChannel").(p_dict, p_client, _name):
	messages = DiscordCollection.new(load("res://addons/discord_gd/structures/Message.gd"))

	if "last_message_id" in p_dict:
		last_message_id = p_dict.last_message_id
	if "rate_limit_per_user" in p_dict:
		rate_limit_per_user = p_dict.rate_limit_per_user

	return self


# @hidden
func update(p_dict):
	.update(p_dict)

	if "rate_limit_per_user" in p_dict:
		rate_limit_per_user = p_dict.rate_limit_per_user


# Add a reaction to a message
# @param message_id: [String] The id of the message
# @param reaction: [String] The reaction (Unicode string if Unicode emoji, `emoji_name:emoji_id` if custom emoji)
# @param user_id: [String] The id of the user to react as. Defaults to the bot user. `optional`
# @returns [bool] | [HTTPResponse] if error
func add_message_reaction(p_message_id, p_reaction, p_user_id = "@me") -> bool:
	return client.add_message_reaction(id, p_message_id, p_reaction, p_user_id)


# Create an invite for the channel (all properties are `optional`)
# @param options: [Dictionary] Invite generation options `optional`
# @param options.max_age: [int] How long the invite should last in seconds
# @param options.max_uses: [int] How many uses the invite should last for
# @param options.temporary: [bool] Whether the invite grants temporary membership or not
# @param options.unique: [bool] Whether the invite is unique or not
# @param reason: [String] The reason to be displayed in audit logs `optional`
# @returns [Invite] | [HTTPResponse] if error
func create_invite(p_options = {}, p_reason = null):
	return client.create_channel_invite(id, p_options, p_reason)


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


# Bulk delete messages
# @param message_ids: [Array] of [String] Array of message ids to delete (more than 1)
# @param reason: [String] The reason to be displayed in audit logs `optional`
# @returns [bool] | [HTTPResponse] if error
func delete_messages(p_message_ids, p_reason = null) -> bool:
	return client.delete_messages(id, p_message_ids, p_reason)


# Edit a message TODO: add docs
# @returns [Message] | [HTTPResponse] if error
func edit_message(p_message_id: String, p_dict):
	return client.edit_message(id, p_message_id, p_dict)


# Get all invites in the channel
# @returns [Array] of [Invite] | [HTTPResponse] if error
func get_invites() -> Array:
	return client.get_channel_invites(id)


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


# Purge previous messages in the channel with an optional filter
# @param options: [Dictionary] Options for the request
# @param options.limit: [int] The max number of messages to search through, -1 for no limit
# @param options.after: [String] Get messages after this message id `optional`
# @param options.before: [String] Get messages before this message id `optional`
# @param options.filter: [FuncRef] Filter function that returns a boolean when passed a `Message` object `optional`
# @param options.reason: [String] The reason to be displayed in audit logs `optional`
# @returns [int] Resolves with the number of messages deleted | [HTTPResponse] if error
func purge(p_options) -> int:
	return client.purge_channel(id, p_options)


# Remove a reaction from a message
# @param message_id: [String] The id of the message
# @param reaction: [String] The reaction (Unicode string if Unicode emoji, `emoji_name:emoji_id` if custom emoji)
# @param user_id: [String] The id of the user to remove the reaction for (default is "@me") `optional`
# @returns [bool] | [HTTPResponse] if error
func remove_message_reaction(p_message_id: String, p_reaction: String, p_user_id = "@me") -> bool:
	return client.remove_message_reaction(id, p_message_id, p_reaction, p_user_id)


# Remove all reactions from a message for a single emoji
# @param message_id: [String] The id of the message
# @param reaction: [String] The reaction (Unicode string if Unicode emoji, `emoji_name:emoji_id` if custom emoji)
# @returns [bool] | [HTTPResponse] if error
func remove_message_reaction_emoji(p_message_id: String, p_reaction: String) -> bool:
	return client.remove_message_reaction_emoji(id, p_message_id, p_reaction)


# Remove all reactions from a message
# @param message_id: [String] The id of the message
# @returns [bool] | [HTTPResponse] if error
func remove_message_reactions(p_message_id: String) -> bool:
	return client.remove_message_reactions(id, p_message_id)


# Send typing status in the channel
# @returns [bool] | [HTTPResponse] if error
func send_typing() -> bool:
	return client.send_channel_typing(id)


# @hidden
func to_dict(p_props = []) -> Dictionary:
	p_props.append_array([
		"last_message_id",
		"messages",
		"rate_limit_per_user",
	])
	return .to_dict(p_props)
