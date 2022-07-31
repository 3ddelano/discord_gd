# Represents a Discord User
#
# `id`: The id of the User
# `created_at`: Timestamp of the user's creation
class_name User extends DiscordBase

var client # [DiscordClient]
var accent_color: int # The user's banner color, or null if no banner color (REST only)
var avatar: String # The hash of the user's avatar, or null if no avatar
var avatar_url: String setget , get_avatar_url# The URL of the user's avatar which can be either a JPG or GIF
var banner: String # The hash of the user's banner, or null if no banner (REST only)
var banner_url: String setget , get_banner_url # The URL of the user's banner
var bot: bool # Whether the user is an OAuth bot or not
var default_avatar: String setget , get_default_avatar # The hash for the default avatar of a user if there is no avatar set
var default_avatar_url: String setget , get_default_avatar_url # The URL of the user's default avatar
var discriminator: String # The discriminator of the user
var mention: String setget , get_mention # A string that mentions the user
var public_flags: int # Publicly visible flags for this user
var static_avatar_url: String # The URL of the user's avatar (always a JPG)
var system: bool # Whether the user is an official Discord system user (e.g. urgent messages)
var username: String # The username of the user


# @hidden
func _init(p_dict, p_client, _name = "User").(p_dict.get("id", null), _name):
	client = p_client

	if "bot" in p_dict:
		bot = not not p_dict.bot
	if "system" in p_dict:
		system = not not p_dict.system

	update(p_dict)

	return self


func update(p_dict):
	if "avatar" in p_dict:
		avatar = p_dict.avatar
	if "username" in p_dict:
		username = p_dict.username
	if "discriminator" in p_dict:
		discriminator = p_dict.discriminator
	if "public_flags" in p_dict:
		public_flags = p_dict.public_flags
	if "banner" in p_dict:
		banner = p_dict.banner
	if "accent_color" in p_dict:
		accent_color = p_dict.accent_color


# @hidden
func get_avatar_url() -> String:
	if avatar:
		return client._format_image(client.ENDPOINTS.USER_AVATAR % [id, avatar])
	else:
		return default_avatar_url


# @hidden
func get_banner_url() -> String:
	if not banner:
		return ""
	return client._format_image(client.ENDPOINTS.BANNER % [id, banner])


# @hidden
func get_default_avatar() -> String:
	return str(discriminator % 5)


# @hidden
func get_default_avatar_url():
	return "%s%s.png" % [DiscordMetadata.CDN_URL, client.ENDPOINTS.DEFAULT_USER_AVATAR % default_avatar]


# @hidden
func get_mention() -> String:
	return "<@%s>" % id


func static_avatar_url() -> String:
	if not avatar:
		return get_default_avatar_url()
	return client._format_image(client.ENDPOINTS.USER_AVATAR % [id, avatar], "jpg")


func dynamic_avatar_url(p_format, p_size) -> String:
	if not avatar:
		return get_default_avatar_url()
	return client._format_image(client.ENDPOINTS.USER_AVATAR % [id, avatar], p_format, p_size)


func dynamic_banner_url(p_format, p_size) -> String:
	if not banner:
		return ""
	return client._format_image(client.ENDPOINTS.BANNER % [id, banner], p_format, p_size)


func get_dm_channel():
	return client.get_dm_channel(id)


# @hidden
func to_dict(p_props = []) -> Dictionary:
	p_props.append_array([
		"accent_color",
		"avatar",
		"banner",
		"bot",
		"discriminator",
		"public_flags",
		"system",
		"username",
	])
	return .to_dict(p_props)
