# Represents a Discord role
#
# `id`: The id of the role
# `created_at`: Timestamp of the role's creation
class_name Role extends DiscordBase

var color: int # [int] The hex color of the role in base 10
var hoist: bool # [bool] Whether users with this role are hoisted in the user list or not
var icon: String # [String] The hash of the role's icon, or null if no icon
var icon_url: String setget , get_icon_url # [String] The URL of the role's icon
var json: Dictionary setget , get_json # [Dictionary] Generates a JSON representation of the role permissions
var guild # [Guild] The guild that owns the role
var managed: bool # [bool] Whether a guild integration manages this role or not
var mention: String setget , get_mention # [String] A string that mentions the role
var mentionable: bool # [bool] Whether the role is mentionable or not
var name: String # [String] The name of the role
var permissions: Permission # [String] The permissions representation of the role
var position: int # [int] The position of the role

# [Dictionary] The tags of the role
# tags.bot_id: [String] The id of the bot associated with the role
# tags.integration_id: [String] The id of the integration associated with the role
# tags.premium_subscriber: [bool] Whether the role is the guild's premium subscriber role
var tags: Dictionary

var unicode_emoji: String # Unicode emoji for the role


# @hidden
func _init(p_dict, p_guild).(p_dict.get("id"), "Role"):
	guild = p_guild

	return self


func update(p_dict):
	if "name" in p_dict:
		name = p_dict.name
	if "mentionable" in p_dict:
		mentionable = p_dict.mentionable
	if "managed" in p_dict:
		managed = p_dict.managed
	if "hoist" in p_dict:
		hoist = p_dict.hoist
	if "color" in p_dict:
		color = p_dict.color
	if "position" in p_dict:
		position = p_dict.position
	if "permissions" in p_dict:
		permissions = Permission.new(int(p_dict.permissions))
	if "tags" in p_dict:
		tags = p_dict.tags
		if tags.get("premium_subscriber") == null:
			tags.premium_subscriber = true
	if "icon" in p_dict:
		icon = p_dict.icon
	if "unicode_emoji" in p_dict:
		unicode_emoji = p_dict.unicode_emoji


# @hidden
func get_icon_url() -> String:
	if not icon:
		return ""
	return guild.shard.client._format_image(guild.shard.client.ENDPOINTS.ROLE_ICON % [id, icon])


# @hidden
func get_json() -> Dictionary:
	return permissions.json


# @hidden
func get_mention() -> String:
	return "<@&%s>" % id


# Delete the role
# @param reason: [String] The reason to be displayed in audit logs `optional`
# @returns [bool] | [HTTPResponse] if error
func delete(p_reason = null) -> bool:
	return guild.shard.client.delete_role(guild.id, id, p_reason)


# Edit the guild role
# @param options: [Dictionary] The properties to edit (all properties are optional)
# @param options.color: [int] The hex color of the role, in number form (ex: 0x3da5b3 or 4040115)
# @param options.hoist: [bool] Whether to hoist the role in the user list or not
# @param options.icon: [String] The role icon as a base64 data URI
# @param options.mentionable: [bool] Whether the role is mentionable or not
# @param options.name: [String] The name of the role
# @param options.permissions: [String] The role permissions number
# @param options.unicodeEmoji: [String] The role's unicode emoji
# @param reason: [String] The reason to be displayed in audit logs `optional`
# @returns [Role] | [HTTPResponse] if error
func edit(p_options = {}, p_reason = null) -> Role:
	return guild.shard.client.edit_role(guild.id, id, p_options, p_reason)


# Edit the role's position
#
# @param position: [int] The new position of the channel
# @param reason: [int] The new position of the channel `optional`
# @returns [bool] | [HTTPResponse] if error
func edit_position(p_position: int, p_reason = null) -> bool:
	return guild.shard.client.edit_role_position(guild.id, id, p_position, p_reason)


# @hidden
func to_dict(p_props = []) -> Dictionary:
	p_props.append_array([
		"color",
		"hoist",
		"icon",
		"managed",
		"mentionable",
		"name",
		"permissions",
		"position",
		"tags",
		"unicode_emoji",
	])
	return .to_dict(p_props)
