# Represents a Discord thread channel
#
# Also see, [NewsThreadChannel], [PublicThreadChannel], and [PrivateThreadChannel]
#
# See [GuildChannel] for extra properties
class_name ThreadChannel extends GuildChannel

var last_message_id = null # [String] The id of the last message in this channel
var member = null # [ThreadMember] Thread member for the current user, if they have joined the thread
var member_count: int # An approximate number of users in the thread (stops at 50)
var members: DiscordCollection # [DiscordCollection] of [ThreadMember] Members in this channel
var message_count: int # An approximate number of messages in the thread (stops at 50)
var messages: DiscordCollection # [DiscordCollection] of [Message] Messages in this channel
var owner_id: String # The id of the user that created the thread
var rate_limit_per_user: int # The ratelimit of the channel, in seconds. 0 means no ratelimit is enabled
var thread_metadata = null # [Dictionary] Metadata for the thread


# @hidden
func _init(p_dict, p_client, p_message_limit = -1, _name = "ThreadChannel").(p_dict, p_client, _name):

	var message_limit = p_message_limit
	if message_limit == -1:
		message_limit = client.options.message_limit
	messages = DiscordCollection.new(Message, message_limit)
	members = DiscordCollection.new(ThreadMember)
	last_message_id = p_dict.get("last_message_id")
	owner_id = p_dict.get("owner_id")

	update(p_dict)

	return self


func update(p_dict):
	.update(p_dict)

	if "member_count" in p_dict:
		member_count = p_dict.member_count
	if "message_count" in p_dict:
		message_count = p_dict.message_count
	if "rate_limit_per_user" in p_dict:
		rate_limit_per_user = p_dict.rate_limit_per_user
	if "thread_metadata" in p_dict:
		thread_metadata = {
			archived = p_dict.thread_metadata.get("archived"),
			auto_archive_duration = p_dict.thread_metadata.get("auto_archive_duration"),
			archive_timestamp = p_dict.thread_metadata.get("archive_timestamp"),
			locked = p_dict.thread_metadata.get("locked"),
		}
		# TODO: add create_timestamp to thread_metadata
		# TODO: is invitable also to be added to thread_metadata?

	if p_dict.get("member") != null:
		member = ThreadMember.new(p_dict.member, client)


# Add a reaction to a message
# @param message_id: [String] The id of the message
# @param reaction: [String] The reaction (Unicode string if Unicode emoji, `emoji_name:emoji_id` if custom emoji)
# @returns [bool] | [HTTPResponse] if error
func add_message_reaction(p_message_id: String, p_reaction: String) -> bool:
	return client.add_message_reaction(id, p_message_id, p_reaction)


# Create a message in the channel TODO: add docs
# @returns [Message] | [HTTPResponse] if error
func create_message(p_dict, p_files = []):
	return client.create_message(id, p_dict, p_files)


# Delete a message
# @param message_id: [String] The id of the message to delete
# @param reason: [String] The reason to be displayed in audit logs `optional`
# @returns [Message] | [HTTPResponse] if error
func delete_message(p_message_id: String, p_reason = null):
	return client.delete_message(id, p_message_id, p_reason)


# Bulk delete messages (bot accounts only)
# @param message_ids: [Array] of [String] List of message ids to delete
# @param reason: [String] The reason to be displayed in audit logs `optional`
# @returns [Message] | [HTTPResponse] if error
func delete_messages(p_message_id: String, p_reason = null):
	return client.delete_messages(id, p_message_id, p_reason)


# Edit a message TODO: add docs
# @returns [Message] | [HTTPResponse] if error
func edit_message(p_message_id: String, p_dict):
	return client.edit_message(id, p_message_id, p_dict)


# Get a list of members that are part of this thread channel
# @returns [Array] of [ThreadMember] | [HTTPResponse] if error
func get_members() -> Array:
	return client.get_thread_members(id)


# Get a previous message in the channel
# @param message_id: [String] The id of the message
# @returns [Message] | [HTTPResponse] if error
func get_message(p_message_id: String) -> Message:
	return client.get_message(id, p_message_id)


# Get a list of users who reacted with a specific reaction
# @param message_id: [String] The id of the message
# @param reaction: [String] The reaction (Unicode string if Unicode emoji, `emoji_name:emoji_id` if custom emoji)
# @param options: [Dictionary] Options for the request `optional`
# @param options.limit: [int] The maximum number of users to get (default is 100)
# @param options.after: [String] Get users after this user id
# @returns [Array] of [User] | [HTTPResponse] if error
func get_message_reaction(p_message_id: String, reaction: String, options = null) -> Array:
	return client.get_message_reaction(id, p_message_id, reaction, options)


# Get previous messages in the channel
# @param options: [Dictionary] Options for the request `optional`
# @param options.after: [String] Get messages after this message id
# @param options.around: [String] Get messages around this message id (does not work with limit > 100)
# @param options.before: [String] Get messages before this message id
# @param options.limit: [int] The max number of messages to get (default is 50)
# @returns [Array] of [Message] | [HTTPResponse] if error
func get_messages(options = null) -> Array:
	return client.get_messages(id, options)


# Get all the pins in the channel
# @returns [Array] of [Message] | [HTTPResponse] if error
func get_pins() -> Array:
	return client.get_pins(id)


# Join a thread
# @param user_id: [String] The user id of the user joining (default to "@me") `optional`
# @returns [bool] | [HTTPResponse] if error
func join(p_user_id: String = "@me") -> bool:
	return client.join_thread(id, p_user_id)


# Leave a thread
# @param user_id: [String] The user id of the user leaving (default to "@me") `optional`
# @returns [bool] | [HTTPResponse] if error
func leave(p_user_id: String = "@me") -> bool:
	return client.leave_thread(id, p_user_id)


# Pin a message
# @param message_id: [String] The id of the message
# @returns [bool] | [HTTPResponse] if error
func pin_message(p_message_id: String) -> bool:
	return client.pin_message(id, p_message_id)


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


# Unpin a message
# @param message_id: [String] The id of the message
# @returns [bool] | [HTTPResponse] if error
func unpin_message(p_message_id: String) -> bool:
	return client.unpin_message(id, p_message_id)


# @hidden
func to_dict(p_props = []) -> Dictionary:
	p_props.append_aray([
		"last_message_id",
		"member_count",
		"message_count",
		"messages",
		"owner_id",
		"rate_limit_per_user",
		"thread_metadata",
		"member",
	])
	return .to_dict(p_props)
