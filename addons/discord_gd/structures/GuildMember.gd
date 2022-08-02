# Represents a Discord guild member
#
# `id`: The id of the member
class_name GuildMember extends DiscordBase

var activities: Array # The member's current activities
var avatar # [String] The hash of the member's guild avatar, or null if no guild avatar
var avatar_url: String setget , get_avatar_url # The URL of the user's avatar which can be either a JPG or GIF
# The member's per-client status
#
# client_status.web: [String] The member's status on web. Either "online", "idle", "dnd", or "offline". Will be "online" for bots
# client_status.desktop: [String] The member's status on desktop. Either "online", "idle", "dnd", or "offline". Will be "offline" for bots
# client_status.mobile: [String] The member's status on mobile. Either "online", "idle", "dnd", or "offline". Will be "offline" for bots
var client_status: Dictionary

var communication_disabled_until = null # [String] Timestamp of timeout expiry. If `null`, the member is not timed out
# The active game the member is playing
#
# game.name: [String] The name of the active game
# game.type: [String] The type of the active game (0 is default, 1 is Twitch, 2 is YouTube)
# game.url: [String] The url of the active game
var game: Dictionary setget , get_game

var guild # [Guild] The guild the member is in
var joined_at: String # Timestamp of when the member joined the guild
var mention: String setget , get_mention # A string that mentions the member
var nick = null # [String] The server nickname of the member
var pending: bool # Whether the member has passed the guild's Membership Screening requirements
var permissions: Permission setget , get_permissions # [Permission] The guild-wide permissions of the member
var premium_since: String # Timestamp of when the member boosted the guild
var roles: Array # [Array] of [String] An array of role ids this member is a part of
var status: String # The member's status. Either "online", "idle", "dnd", or "offline"
var user # [User] The user object of the member
var voice_state setget , get_voice_state # [VoiceState] The voice state of the member


func _init(p_dict, p_guild, p_client):
	var _id = p_dict.get("id", null)
	if _id == null:
		p_dict.id = p_dict.get("user", {}).get("id", null)
	._init(_id, "GuildMember")

	if guild == p_guild:
		user = p_guild.shard.client.users.get(p_dict.id)
		if not user and p_dict.get("user"):
			user = p_guild.shard.client.users.add(p_dict.user, p_guild.shard.client)
		if not user:
			DiscordUtils.perror("User associated with GuildMember not found: %s" % p_dict.id)
	elif p_dict.get("user"):
		if not p_client:
			user = User.new(p_dict.user, p_client)
		else:
			user = p_client.users.update(p_dict.user, p_client)
	else:
		user = null

	nick = null
	roles =  []
	update(p_dict)

	return self


func update(p_dict):
	if "status" in p_dict:
		status = p_dict.status
	if "joined_at" in p_dict:
		joined_at = p_dict.joined_at
	if "client_status" in p_dict:
		client_status = {
			web = "offline",
			desktop = "offline",
			mobile = "offline",
		}
		for k in p_dict.client_status:
			client_status[k] = p_dict.client_status[k]
	if "activities" in p_dict:
		activities = p_dict.activities
	if "premium_since" in p_dict:
		premium_since = p_dict.premium_since
	if "mute" in p_dict and guild:
		var state = guild.voice_states.get(id)
		if p_dict.get("channel_id") == null and not p_dict.get("mute") and not p_dict.get("deaf") and not p_dict.get("suppress"):
			guild.voice_states.delete(id)
		elif state:
			state.update(p_dict)
		elif p_dict.get("channel_id") or p_dict.get("mute") or p_dict.get("deaf") or p_dict.get("suppress"):
			guild.voice_states.update(p_dict)
	if "nick" in p_dict:
		nick = p_dict.nick
	if "roles" in p_dict:
		roles = p_dict.roles
	if "pending" in p_dict:
		pending = p_dict.pending
	if "roles" in p_dict:
		roles = p_dict.roles
	if "avatar" in p_dict:
		avatar = p_dict.avatar
	if "communication_disabled_until" in p_dict:
		communication_disabled_until = p_dict.communication_disabled_until

	return self


func get_avatar_url():
	if not avatar:
		if not user:
			return null
		return user.avatar_url
	return guild.shard.client._format_image(guild.shard.client.ENDPOINTS.GUILD_AVATAR % [guild.id, id, avatar])


func get_mention():
	return "<@!%s>" % id


func get_permissions():
	return guild.permissions_of(self)


func get_voice_state():
	if guild and guild.voice_states.has(id):
		return guild.voice_states.get(id)
	else:
		return VoiceState.new({
			id = id
		})


func get_game():
	if activities and activities.size() > 0:
		return activities[0]
	return null


# Add a role to the guild member
# @param role_id: [String] The id of the role
# @param reason: [String] The reason to be displayed in audit logs `optional`
# @returns [bool] | [HTTPResponse] if error
func add_role(p_role_id, p_reason = null):
	return guild.shard.client.add_guild_member_role(guild.id, id, p_role_id, p_reason)


# Ban the user from the guild
# @param delete_message_days: [int] Number of days to delete messages for, between 0-7 inclusive `optional`
# @param reason: [String] The reason to be displayed in audit logs `optional`
# @returns [bool] | [HTTPResponse] if error
func ban(p_delete_message_days = null, p_reason = null):
	return guild.shard.client.ban_guild_member(guild.id, id, p_delete_message_days, p_reason)


# Edit the guild member
# @param options: [Dictionary] The properties to edit (all properties are optional)
# @param options.channel_id: [String] The id of the voice channel to move the member to (must be in voice). Set to `null` to disconnect the member
# @param options.communication_disabled_until: [bool] When the user's timeout should expire. Set to `null` to instantly remove timeout
# @param options.deaf: [bool] Server deafen the user
# @param options.mute: [bool] Server mute the user
# @param options.nick: [String] Set the user's server nickname, "" to remove
# @param options.roles: [Array] of [String] The array of role ids the user should have
# @param reason: [String] The reason to be displayed in audit logs `optional`
# @returns [bool] | [HTTPResponse] if error
func edit(p_options = null, p_reason = null):
	return guild.shard.client.edit_guild_member(guild.id, id, p_options, p_reason)


# Kick the member from the guild
# @param reason: [String] The reason to be displayed in audit logs `optional`
# @returns [bool] | [HTTPResponse] if error
func kick(p_reason = null):
	return guild.shard.client.kick_guild_member(guild.id, id, p_reason)


# Remove a role from the guild member
# @param role_id: [String] The id of the role
# @param reason: [String] The reason to be displayed in audit logs `optional`
# @returns [bool] | [HTTPResponse] if error
func remove_role(p_role_id, p_reason = null):
	return guild.shard.client.remove_guild_member_role(guild.id, id, p_role_id, p_reason)


# Unan the user from the guild
# @param reason: [String] The reason to be displayed in audit logs `optional`
# @returns [bool] | [HTTPResponse] if error
func unban(p_reason = null):
	return guild.shard.client.unban_guild_member(guild.id, id, p_reason)


# @hidden
func to_dict(p_props = []) -> Dictionary:
	p_props.append_array([
		"activities",
		"communication_disabled_until",
		"joined_at",
		"nick",
		"pending",
		"premium_since",
		"roles",
		"status",
		"user",
		"voice_state",
	])

	return .to_dict(p_props)
