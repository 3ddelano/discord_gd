# Represents a Discord guild audit log entry describing a moderation action
#
# `id`: The id of the audit log entry
class_name GuildAuditLogEntry extends DiscordBase

var action_type: int # The action type of the entry. See [DiscordConstants.AuditLogActions] for more details

# [Dictionary] The properties of the targeted object after the action was taken
#
# For example, if a channel was renamed from `#general` to `#tomata`, this would be `{name: "tomato"}`
var after = null

# [Dictionary] The properties of the targeted object before the action was taken
#
# For example, if a channel was renamed from `#general` to `#tomato`, this would be `{name: "general"}`
var before = null

# [CategoryChannel] | [TextChannel] | [TextVoiceChannel] | [NewsThreadChannel] | [PrivateThreadChannel] | [PublicThreadChannel] | [StageChannel] The channel targeted in the entry, action types 26 (MEMBER_MOVE), 72/74/75 (MESSAGE_DELETE/PIN/UNPIN) and 83/84/85 (STAGE_INSTANCE_CREATE/UPDATE/DELETE) only
var channel: Channel

# The number of entities targeted
#
# For example, for action type 26 (MEMBER_MOVE), this is the number of members that were moved/disconnected from the voice channel
var count: int

var delete_member_days: int # The number of days of inactivity to prune for, action type 21 (MEMBER_PRUNE) only
var guild: Guild # The guild containing the entry

# [GuildMember] | [Dictionary] The member described by the permission overwrite, action types 13-15 (CHANNEL\_OVERWRITE\_CREATE/UPDATE/DELETE) only. If the member is not cached, this could be a Dictionary {id: String}
var member

var members_removed: int # The number of members pruned from the server, action type 21 (MEMBER_PRUNE) only

# [Message] | [Dictionary] The message that was (un)pinned, action types 74/75 (MESSAGE_PIN/UNPIN) only. If the message is not cached, this will be an object with an `id` key. No other property is guaranteed.
var message

var reason = null # [String] The reason for the action

# [Role] | [Dictionary] The role described by the permission overwrite, action types 13-15 (CHANNEL\_OVERWRITE\_CREATE/UPDATE/DELETE) only. If the role is not cached, this could be a Dictionary {id: String, name: String}
var role

# [CategoryChannel] | [Guild] | [Member] | [Invite] | [Role] | [Object] | [TextChannel] | [TextVoiceChannel] | [NewsChannel] The object of the action target
#
# If the item is not cached, this property will be null
#
# If the action targets a guild, this could be a Guild object
#
# If the action targets a guild channel, this could be a CategoryChannel, TextChannel, or TextVoiceChannel object
#
# If the action targets a member, this could be a Member object
#
# If the action targets a role, this could be a Role object
#
# If the action targets an invite, this is an Invite object
#
# If the action targets a webhook, this is null
#
# If the action targets a emoji, this could be an emoji object
#
# If the action targets a sticker, this could be a sticker object
#
# If the action targets a message, this is a User object
var target setget , get_target

var target_id = null # [String] The id of the action target
var user: User # The user that performed the action


func _init(p_dict, p_guild).(p_dict.get("id", null), "GuildAuditLogEntry"):

	guild = p_guild
	if "action_type" in p_dict:
		action_type = p_dict.action_type
	if "reason" in p_dict:
		reason = p_dict.reason

	user = guild.shard.client.users.get(p_dict.user_id)
	before = null
	after = null

	if p_dict.get("changes", false):
		before = {}
		after = {}
		for change in p_dict.changes:
			if "old_value" in change:
				before[change.key] = change.old_value
			if "new_value" in change:
				after[change.key] = change.new_value

	if "target_id" in p_dict:
		target_id = p_dict.target_id
	if p_dict.get("options", {}):
		if p_dict.options.get("count"):
			count = int(p_dict.options.count)

		if p_dict.options.get("channel_id"):
			if action_type >= 83:
				channel = guild.threads.get(p_dict.options.channel_id)
			else:
				channel = guild.channels.get(p_dict.options.channel_id)
			if p_dict.options.get("message_id"):
				if channel:
					message = channel.messages.get(p_dict.options.message_id)
				else:
					message = {id: p_dict.options.message_id}
		if p_dict.options.get("delete_member_days"):
			delete_member_days = int(p_dict.options.delete_member_days)
			members_removed = int(p_dict.options.members_removed)

		if p_dict.options.get("type"):
			if str(p_dict.options.type) == "1":
				member = guild.members.get(p_dict.options.id)
				if member == null:
					member = {id: p_dict.options.id}
			elif str(p_dict.options.type) == "0":
				role = guild.roles.get(p_dict.options.id)
				if role == null:
					role = {id: p_dict.options.id, name = p_dict.options.role_name}

	return self


# @hidden
func get_target():
	if action_type < 10: # Guild
		return guild
	elif action_type < 20: # Channel
		if guild:
			return guild.channels.get(target_id)
		return null
	elif action_type < 30: # Member
		if action_type in [DiscordConstants.AuditLogActions.MEMBER_MOVE, DiscordConstants.AuditLogActions.MEMBER_DISCONNECT]:
			return null
		if guild:
			return guild.members.get(target_id)
		return null
	elif action_type < 40: # Role
		if guild:
			return guild.roles.get(target_id)
		return null
	elif action_type < 50: # Invite
		var changes = after
		if action_type == DiscordConstants.AuditLogActions.INVITE_DELETE:
			changes = before

		return Invite.new({
			code = changes.get("code", null),
			channel = changes.get("channel", null),
			guild = guild,
			uses = changes.get("uses", null),
			max_uses = changes.get("max_uses", null),
			max_ages = changes.get("max_ages", null),
			temporary = changes.get("temporary", null),
		}, guild, guild.shard.client)
	elif action_type < 60: # Webhook
		return null # Get it yourself
	elif action_type < 70: # Emoji
		if guild:
			for emoji in guild.emojis:
				if emoji.id == target_id:
					return emoji
		return null
	elif action_type < 80: # Message
		if guild:
			return guild.shard.client.users.get(target_id)
		else:
			return null
	elif action_type < 83: # Integrations
		return null
	elif action_type < 90: # Stage Instances
		if guild:
			return guild.threads.get(target_id)
		else:
			return null
	elif action_type < 100: # Sticker
		if guild:
			for sticker in guild.stickers:
				if sticker.id == target_id:
					return sticker
		return null
	else:
		DiscordUtils.perror("GuildAuditLogEntry:target:Unrecognized action type: " + str(action_type))


# @hidden
func to_dict(p_props = []) -> Dictionary:
	p_props.append_array([
		"action_type",
		"after",
		"before",
		"channel",
		"count",
		"delete_member_days",
		"member",
		"members_removed",
		"reason",
		"role",
		"target_id",
		"user",
	])

	return .to_dict(p_props)
