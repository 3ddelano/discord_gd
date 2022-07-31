# Represents a Discord guild preview
#
# `id`: The id of the guild
class_name GuildPreview extends DiscordBase

var client # [DiscordClient] The client who instantiated this guild preview

var approximate_member_count: int # The approximate number of members in the guild
var approximate_presence_count: int # The approximate number of presences in the guild
var description: String # The description for the guild (VIP only)
var discovery_splash: String # The hash of the guild discovery splash image, or null if no splash
var discovery_splash_url: String # The URL of the guild's discovery splash image
var emojis: Array # [Array] of [Dictionary] An array of guild emojis
var features: Array # [Array] of [String] An array of guild feature strings
var icon: String # The hash of the guild icon, or null if no icon
var icon_url: String setget , get_icon_url # The URL of the guild's icon
var name: String # The name of the guild
var splash: String # The hash of the guild splash image, or null if no splash (VIP only)
var splash_url: String # The URL of the guild's splash image

func _init(p_dict, p_client).(p_dict.get("id", null), "GuildPreview"):
	client = p_client
	if "name" in p_dict:
		name = p_dict.name
	if "icon" in p_dict:
		icon = p_dict.icon
	if "description" in p_dict:
		description = p_dict.description
	if "splash" in p_dict:
		splash = p_dict.splash
	if "discovery_splash" in p_dict:
		discovery_splash = p_dict.discovery_splash
	if "features" in p_dict:
		features = p_dict.features
	if "approximate_member_count" in p_dict:
		approximate_member_count = p_dict.approximate_member_count
	if "approximate_presence_count" in p_dict:
		approximate_presence_count = p_dict.approximate_presence_count
	if "emojis" in p_dict:
		emojis = p_dict.emojis

	return self


# @hidden
func get_icon_url() -> String:
	if not icon:
		return ""
	return client._format_image(client.ENDPOINTS.GUILD_ICON % [id, icon])


# @hidden
func get_splash_url() -> String:
	if not splash:
		return ""
	return client._format_image(client.ENDPOINTS.GUILD_SPLASH % [id, splash])


# @hidden
func get_discovery_splash_url() -> String:
	if not discovery_splash:
		return ""
	return client._format_image(client.ENDPOINTS.GUILD_DISCOVERY_SPLASH % [id, discovery_splash])


# Get the guild's discovery splash with the given format and size
# @param format: [String] The filetype of the icon ("png", "jpg", "jpeg", "gif" or "webp") `optional`
# @param size: [String] The size of the icon (any power of two between 16 and 4096) `optional`
# @returns [String] | [HTTPResponse] if error
func dynamic_discovery_splash_url(p_format = null, p_size = null) -> String:
	if not discovery_splash:
		return ""
	return client._format_image(client.ENDPOINTS.GUILD_DISCOVERY_SPLASH % [id, discovery_splash], p_format, p_size)


# Get the guild's icon with the given format and size
# @param format: [String] The filetype of the icon ("png", "jpg", "jpeg", "gif" or "webp") `optional`
# @param size: [String] The size of the icon (any power of two between 16 and 4096) `optional`
# @returns [String] | [HTTPResponse] if error
func dynamic_icon_url(p_format = null, p_size = null) -> String:
	if not icon:
		return ""
	return client._format_image(client.ENDPOINTS.GUILD_ICON % [id, icon], p_format, p_size)


# Get the guild's splash with the given format and size
# @param format: [String] The filetype of the icon ("png", "jpg", "jpeg", "gif" or "webp") `optional`
# @param size: [String] The size of the icon (any power of two between 16 and 4096) `optional`
# @returns [String] | [HTTPResponse] if error
func dynamic_splash_url(p_format = null, p_size = null) -> String:
	if not splash:
		return ""
	return client._format_image(client.ENDPOINTS.GUILD_SPLASH % [id, splash], p_format, p_size)


# @hidden
func to_dict(p_props = []) -> Dictionary:
	p_props.append_array([
		"approximate_member_count",
		"approximate_presence_count",
		"description",
		"discovery_splash",
		"emojis",
		"features",
		"icon",
		"name",
		"splash",
	])

	return .to_dict(p_props)
