# Represents a Discord Message
#
# `id`: The id of the Message
# created_at: Timestamp of message creation
class_name Message extends DiscordBase

var activity = null # [Dictionary] The activity specified in the message `optional`
var application = null # [Dictionary] The application of the activity in the message `optional`
var application_id = null # [String] The id of the interaction's application `optional`
var attachments: Array # [Array] of [Dictionary] Array of attachments
var author: User # The message author
var channel # [PrivateChannel] | [TextChannel] | [NewsChannel] | [Dictionary] The channel the message is in. Can be partial with only the id if the channel is not cached.
var channel_mentions: Array # [Array] of [String] Array of mentions channels' ids

# var command = null # [Command] The Command used in the Message, if any (CommandClient only) `optional`

var components: Array # [Array] of [Dictionary] An array of component objects
var content: String # Message content
var edited_timestamp = null # [int] Timestamp of latest message edit `optional`
var embeds: Array # [Array] of [Dictionary] Array of embeds
var flags: int # Message flags (see constants)
var guild_id: String # The id of the guild this message is in (`null` if in DMs)
var jump_link: String # The url used by Discord clients to jump to this message
var member = null # [GuildMember] The message author with server-specific data `optional`
var mention_everyone: bool # Whether the message mentions everyone/here or not
var mentions: Array # [Array] of [User] Array of mentioned users

# [Dictionary] A dictionary containing the reference to the original message if it is a crossposted message or reply `optional`
#
# Properties
# message_id: [String] The id of the original message this message was crossposted `optional`
# channel_id: [String] The id of the channel this message was crossposted from
# guild_id: [String] The id of the guild this message was crossposted from `optional`
var message_reference = null

# [Dictionary] A dictionary containing info about the interaction the message is responding to, if applicable `optional`
#
# Properties
# id: [String] The id of the interaction
# type: [int] The type of interaction
# name: [String] The name of the command
# user: [String] The user who invoked the interaction
# member: [GuildMember] The member who invoked the interaction `optional`
var interaction = null
var pinned: bool # Whether the message is pinned or not

# var prefix = null # [String] The prefix used in the Message, if any (CommandClient only) `optional`

var reactions: Dictionary # A dictionary containing the reactions on the message. Each key is a reaction emoji and each value is a dictionary with properties `me` (bool) and `count` (int) for that specific reaction emoji.
var referenced_message = null # [Message] The message that was replied to `optional`
var role_mentions: Array # [Array] of [String] Array of mentioned roles' ids
var sticker_items: Array # [Array] of [Dictionary] The stickers sent with the message `optional`
var timestamp: int # Timestamp of message creation
var tts: bool # Whether to play the message using TTS or not
var type: int # The type of the message
var webhook_id = null # [String] Id of the webhook that sent the message `optional`
var client = null # [DiscordClient] The client who instantiated the message

var hit

# @hidden
func _init(p_dict, p_client).(p_dict.get("id", null), "Message"):
	client = p_client
	type = p_dict.get("type", 0)
	timestamp = p_dict.get("timestamp", 0)
	channel = p_client.get_channel(p_dict.channel_id)
	if not channel:
		channel = {id = p_dict.channel_id}
	content = ""
	hit = not not p_dict.get("hit", false)
	reactions = {}
	guild_id = p_dict.get("guild_id", null)
	webhook_id = p_dict.get("webhook_id", null)

	return self


# @hidden
func get_mention() -> String:
	return "<#%s>" % id


# @hidden
static func from(data, client):
	# TODO: after declaring Message classes
	pass


# @hidden
func to_dict(p_props = []) -> Dictionary:
	p_props.append("type")
	return .to_dict(p_props)
