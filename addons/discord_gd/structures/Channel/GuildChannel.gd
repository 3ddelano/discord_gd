# Represents a Discord guild channel
#
# Also see, [CategoryChannel], [NewsChannel], [StoreChannel], [TextChannel], and [TextVoiceChannel]
class_name GuildChannel extends Channel


var guild # [Guild] The guild that owns the channel # TODO: add Guild static type
var name: String # The name of the channel
var nsfw: bool # Whether the channel is an NSFW channel or not
var parent_id # [String] The id of the category this channel belongs to or the channel id where the thread originated from (thread channels only)
var permission_overwrites: DiscordCollection # [Dictionary] of [PermissionOverwrites] in this channel
var position: int # The position of the channel


# @hidden
func _init(p_dict, p_client, _name = "GuildChannel").(p_dict, p_client, _name):
	# var GuildScript = load("res://addons/discord_gd/structures/Guild.gd")
	guild = client.guilds.get(p_dict.guild_id)
	if guild == null:
		# guild = GuildScript.new({id = p_dict.guild_id})
		guild = {id: p_dict.guild_id} # TODO: Try using Guild instead of simple Dictionary

	update(p_dict)

	return self

# @hidden
func update(p_dict):
	if "type" in p_dict:
		type = p_dict.type
	if "name" in p_dict:
		name = p_dict.name
	if "position" in p_dict:
		position = p_dict.position
	if "parent_id" in p_dict:
		parent_id = p_dict.parent_id
	if "nsfw" in p_dict:
		nsfw = p_dict.nsfw
	if "permission_overwrites" in p_dict:
		permission_overwrites = DiscordCollection.new(PermissionOverwrite)
		for overwrite in p_dict.permission_overwrites:
			permission_overwrites.add(overwrite)


# Delete the channel
# @param reason: [String] The reason for deleting this channel `optional`
# @returns [bool] | [HTTPResponse] is error
func delete(p_reason = null) -> bool:
	return client.delete_channel(id, p_reason)


# Delete a channel permission overwrite
# @param overwrite_id: [String] The id of the overwritten user or role
# @param reason: [String] The reason for deleting this channel `optional`
# @returns [bool]| [HTTPResponse] if error
func delete_permission(p_overwrite_id: String, p_reason = null) -> bool:
	return client.delete_channel_permission(id, p_overwrite_id, p_reason)


# Edit the channel's properties (all properties are `optional`)
# @param options: [Dictionary] The properties to edit
# @param options.archived: [bool] The archive status of the channel (thread channels only)
# @param options.auto_archive_duration: [int] The duration in minutes to automatically archive the thread after recent activity, either 60, 1440, 4320 or 10080 (thread channels only)
# @param options.bitrate: [int] The bitrate of the channel (guild voice channels only)
# @param options.default_auto_archive_duration: [int] The default duration of newly created threads in minutes to automatically archive the thread after inactivity (60, 1440, 4320, 10080) (guild text/news channels only)
# @param options.invitable: [bool] Whether non-moderators can add other non-moderators to the channel (private thread channels only)
# @param options.locked: [bool] The lock status of the channel (thread channels only)
# @param options.name: [String] The name of the channel
# @param options.nsfw: [bool] The nsfw status of the channel
# @param options.parent_id: [String] The ID of the parent channel category for this channel (guild text/voice channels only) or the channel ID where the thread originated from (thread channels only)
# @param options.permission_overwrites: [Array] of [PermissionOverwrite] An array containing permission overwrite objects
# @param options.position: [int] The sorting position of the channel
# @param options.rate_limit_per_user: [int] The time in seconds a user has to wait before sending another message (does not affect bots or users with manageMessages/manageChannel permissions) (guild text and thread channels only)
# @param options.rtc_region: [String] The RTC region ID of the channel (automatic if `null`) (guild voice channels only)
# @param options.topic: [String] The topic of the channel (guild text channels only)
# @param options.user_limit: [int] The channel user limit (guild voice channels only)
# @param options.video_quality_mode: [int] The camera video quality mode of the channel (guild voice channels only). `1` is auto, `2` is 720p
# @param reason: [String] The reason to be displayed in audit logs
# @returns `CategoryChannel` | `GroupChannel` | `TextChannel` | `TextVoiceChannel` | `NewsChannel` | `NewsThreadChannel` | `PrivateThreadChannel` | `PublicThreadChannel` | [HTTPResponse] if error
func edit(p_options, p_reason = null):
	return client.edit_channel(id, p_options, p_reason)


# Edit a channel permission overwrite
# @param overwrite_id: [String] The id of the overwritten user or role
# @param type: int The object type of the overwrite, either 1 for "member" or 0 for "role"
# @param allow: [int] The permissions number for allowed permissions `optional`
# @param deny: [int] The permissions number for denied permissions `optional`
# @param reason: [String] The reason to be displayed in audit logs `optional`
# @returns [PermissionOverwrite] | [HTTPResponse] if error
func edit_permission(p_overwrite_id: String, p_type: int, p_allow = -1, p_deny = -1, p_reason = null) -> PermissionOverwrite:
	return client.edit_channel_permission(id, p_overwrite_id, p_type, p_allow, p_deny,p_reason)


# Edit the channel's position
#
# Note that channel position numbers are lowest on top and highest at the bottom
# @param position: [int] The new position of the channel
# @param options: [Dictionary] Additional options when editing position `optional`
# @param options.lock_permissions: [bool] Whether to sync the permissions with the new parent if moving to a new category`optional`
# @param options.parent_id: [String] The new parent id (category channel) for the channel that is moved `optional`
# @returns [bool] | [HTTPResponse] if error
func edit_position(p_position, p_options = null) -> bool:
	return client.edit_channel_position(id, p_position, p_options)


# Get the channel-specific permissions of a member
# @param member: [String] | [GuildMember] The id of the member or a [GuildMember] member object
# @returns [Permission] | [HTTPResponse] if error
func permissions_of(p_member_id) -> Permission:
	var member = p_member_id
	if typeof(p_member_id) == TYPE_STRING:
		member = guild.members.get(p_member_id)

	var permission = guild.permissions_of(member).allow
	if permission & Permission.Permissions.ADMINISTRATOR:
		return Permission.new(Permission.ALL)

	var channel = self
	if "parent_id" in self and self.parent_id != null:
		channel = guild.channels.get(self.parent_id)

	var overwrite = channel.permission_ovewrites.get(guild.id)
	if overwrite != null:
		permission = (permission & ~overwrite.deny) | overwrite.allow
	var deny = 0
	var allow = 0
	for role_id in member.roles:
		overwrite = channel.permission_overwrites.get(role_id)
		if overwrite != null:
			deny |= overwrite.deny
			allow |= overwrite.allow

	permission = (permission & ~deny) | allow
	overwrite = channel.permission_overwrites.get(member.id)
	if overwrite != null:
		permission = (permission & ~overwrite.deny) | overwrite.allow

	return Permission.new(permission)


# @hidden
func to_dict(p_props = []) -> Dictionary:
	p_props.append_array([
		"name",
		"nsfw",
		"parent_id",
		"permission_overwrites",
		"position"
	])
	return .to_dict(p_props)
