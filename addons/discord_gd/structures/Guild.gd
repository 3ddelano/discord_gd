# Represents a Discord guild
#
# `id`: The id of the guild
# `created_at`: Timestamp of the guild's creation
class_name Guild extends DiscordBase

var client # [DiscordClient] The client that initialized the channel
var afk_channel_id = null # [String] The id of the AFK voice channel
var afk_timeout: int # The AFK timeout in seconds
var application_id = null # [String] The application id of the guild creator if it is bot-created
var approximate_member_count = null # [int] The approximate number of members in the guild (REST only)
var approximate_presence_count = null # [int] The approximate number of presences in the guild (REST only)
var auto_removed = null # [bool] Whether the guild was automatically removed from Discovery
var banner = null # [String] The hash of the guild banner image, or `null` if no banner (VIP only)
var banner_url = null # [String] The URL of the guild's banner image
var categories = null # [Array] of [TODO:] The guild's discovery categories
var channels: DiscordCollection # [DiscordCollection] of [GuildChannel] Channels in the guild
var default_notifications: int # The default notification settings for the guild. 0 is "All Messages", 1 is "Only @mentions"
var description = null # [String] The description for the guild (VIP only)
var discovery_splash = null # [String] The hash of the guild discovery splash image, or `null` if no discovery splash
var discovery_splash_url = null # [String] The URL of the guild's discovery splash image
var emoji_count = null # [int] The number of emojis on the guild
var emojis: Array # [Array] of [TODO:] An array of guild emoji objects
var explicit_content_filter: int # The explicit content filter level for the guild. 0 is off, 1 is on for people without roles, 2 is on for all
var features: Array # [Array] of [String] An array of guild feature strings
var icon = null # [String] The hash of the guild icon, or `null` if no icon
var icon_url = null # [String] The URL of the guild's icon
var joined_at: int # Timestamp of when the bot account joined the guild
var keywords = null # [Array] of [String] The guild's discovery keywords
var large: bool # Whether the guild is "large" by "some Discord standard"
var mfa_level: int # The admin 2FA level for the guild. 0 is not required, 1 is required
var max_members = null # [int] The maximum amount of members for the guild
var max_presences: int # The maximum number of people that can be online in a guild at once (returned from REST API only)
var max_video_channel_users = null # [int] The max number of users allowed in a video channel
var member_count: int # Number of members in the guild
var members: DiscordCollection # [DiscordCollection] of [GuildMember]  Members in the guild
var name: String # The name of the guild
var nsfw_level: int # The guild NSFW level designated by Discord
var owner_id: String # The id of the user that is the guild owner
var preferred_locale: String # Preferred "COMMUNITY" guild language used in server discovery and notices from Discord
var premium_progress_bar_enabled: bool # If the boost progress bar is enabled
var premium_subscription_count = null # [int] The total number of users currently boosting this guild
var premium_tier: int # Nitro boost level of the guild
var primary_category = null # [TODO:] The guild's primary discovery category
var primary_category_id = null # [String] The guild's primary discovery category id
var public_updates_channel_id = null # [String] id of the guild's updates channel if the guild has "COMMUNITY" features
var roles: DiscordCollection # [DiscordCollection] of [Role] Roles in the guild
var rules_channel_id = null # [String] The channel where "COMMUNITY" guilds display rules and/or guidelines
var shard # [Shard] The Shard that owns the guild
var splash = null # [String] The hash of the guild splash image, or null if no splash (VIP only)
var splash_url = null # [String] The URL of the guild's splash image
var stage_instances: DiscordCollection # [DiscordCollection] of [StageInstace] Stage instances in the guild
var stickers = null # [Array] of [TODO:] An array of guild sticker objects
var system_channel_flags: int # The flags for the system channel TODO: use BitField
var system_channel_id = null # [String] The id of the default channel for system messages (built-in join messages and boost messages)
var threads: DiscordCollection # [DiscordCollection] of [ThreadChannel] Threads that the current user has permission to view
var unavailable: bool # Whether the guild is unavailable or not
var vanity_url = null # [String] The vanity URL of the guild (VIP only)
var verification_level: int # The guild verification level
var voice_states: DiscordCollection # [DiscordCollection] of [VoiceState] Voice states in the guild
var welcome_screen = null # [TODO:] The welcome screen of a Community guild, shown to new members
var widget_channel_id = null # [int] The channel id that the widget will generate an invite to. REST only.
var widget_enabled = null # [bool] Whether the guild widget is enabled. REST only.
var default_message_notifications = null # [int] See [DiscordConstants.DefaultMessageNotificationLevels]
var vanity_url_code = null # [String] The vanity URL code of the guild
var nsfw: bool # Whether the guild is NSFW or not

# @hidden
func _init(p_dict, p_client).(p_dict.get("id", null), "Guild"):
	client = p_client

	if client.guild_shard_map.has(id):
		shard = client.shards.get(str(client.guild_shard_map[id]))
	elif client.options.shards != 0:
		shard = DiscordBase.getDiscordEpoch(p_dict.id) % client.options.maxShards
	else:
		shard = 0

	if "unavailable" in p_dict:
		unavailable = not not p_dict.unavailable
	if "joined_at" in p_dict:
		joined_at = p_dict.joined_at

	voice_states = DiscordCollection.new(VoiceState)
	channels = DiscordCollection.new(GuildChannel)
	threads = DiscordCollection.new(ThreadChannel)
	members = DiscordCollection.new(GuildMember)
#	stage_instances = DiscordCollection.new(StageInstance)
	if "member_count" in p_dict:
		member_count = int(p_dict.member_count)
#	roles = DiscordCollection.new(Role)

	if "application_id" in p_dict:
		application_id = p_dict.application_id
	if "widget_enabled" in p_dict:
		widget_enabled = p_dict.widget_enabled
	if "widget_channel_id" in p_dict:
		widget_channel_id = p_dict.widget_channel_id
	if "approximate_member_count" in p_dict:
		approximate_member_count = p_dict.approximate_member_count
	if "approximate_presence_count" in p_dict:
		approximate_presence_count = p_dict.approximate_presence_count
	if "auto_removed" in p_dict:
		auto_removed = p_dict.auto_removed
	if "emoji_count" in p_dict:
		emoji_count = p_dict.emoji_count
	if "primary_category_id" in p_dict:
		primary_category_id = p_dict.primary_category_id
	if "primary_category" in p_dict:
		primary_category = p_dict.primary_category
	if "categories" in p_dict:
		categories = p_dict.categories
	if "keywords" in p_dict:
		keywords = p_dict.keywords

	if "channels" in p_dict:
		for channel in p_dict.channels:
			channel.guild_id = id
			channel = Channel.from(channel, client)
			channel.guild = self
			channels.add(channel, [client])
			client.channel_guild_map[channel.id] = id

	if "threads" in p_dict:
		for thread in p_dict.threads:
			thread.guild_id = id
			thread = Channel.from(thread, client)
			thread.guild = self
			threads.add(thread, [client])
			client.thread_guild_map[thread.id] = id

	update(p_dict)

	return self

# @hidden
func update(p_dict):
	if "name" in p_dict:
		name = p_dict.name
	if "verification_level" in p_dict:
		verification_level = p_dict.verification_level
	if "splash" in p_dict:
		splash = p_dict.splash
	if "discovery_splash" in p_dict:
		discovery_splash = p_dict.discovery_splash
	if "banner" in p_dict:
		banner = p_dict.banner
	if "owner_id" in p_dict:
		owner_id = p_dict.owner_id
	if "icon" in p_dict:
		icon = p_dict.icon
	if "features" in p_dict:
		features = p_dict.features
	if "emojis" in p_dict:
		emojis = p_dict.emojis
	if "stickers" in p_dict:
		stickers = p_dict.stickers
	if "afk_channel_id" in p_dict:
		afk_channel_id = p_dict.afk_channel_id
	if "afk_timeout" in p_dict:
		afk_timeout = p_dict.afk_timeout
	if "default_message_notifications" in p_dict:
		default_message_notifications = p_dict.default_message_notifications
	if "mfa_level" in p_dict:
		mfa_level = p_dict.mfa_level
	if "large" in p_dict:
		large = p_dict.large
	if "max_presences" in p_dict:
		max_presences = p_dict.max_presences
	if "explicit_content_filter" in p_dict:
		explicit_content_filter = p_dict.explicit_content_filter
	if "system_channel_id" in p_dict:
		system_channel_id = p_dict.system_channel_id
	if "system_channel_flags" in p_dict:
		system_channel_flags = p_dict.system_channel_flags
	if "premium_progress_bar_enabled" in p_dict:
		premium_progress_bar_enabled = p_dict.premium_progress_bar_enabled
	if "premium_tier" in p_dict:
		premium_tier = p_dict.premium_tier
	if "premium_subscription_count" in p_dict:
		premium_subscription_count = p_dict.premium_subscription_count
	if "vanity_url_code" in p_dict:
		vanity_url_code = p_dict.vanity_url_code
	if "preferred_locale" in p_dict:
		preferred_locale = p_dict.preferred_locale
	if "description" in p_dict:
		description = p_dict.description
	if "max_members" in p_dict:
		max_members = p_dict.max_members
	if "public_updates_channel_id" in p_dict:
		public_updates_channel_id = p_dict.public_updates_channel_id
	if "rules_channel_id" in p_dict:
		rules_channel_id = p_dict.rules_channel_id
	if "max_video_channel_users" in p_dict:
		max_video_channel_users = p_dict.max_video_channel_users
	if "welcome_screen" in p_dict:
		welcome_screen = {
			description = p_dict.welcome_screen.get("description", null),
		}
		var welcome_channels = []
		if p_dict.welcome_screen.get("welcome_channels"):
			for channel in p_dict.welcome_screen.welcome_channels:
				welcome_channels.append({
					channel_id = channel.channel,
					description = channel.description,
					emoji_id = channel.emoji_id,
					emoji_name = channel.emoji_name
				})

	if "nsfw" in p_dict:
		nsfw = p_dict.nsfw

	if "nsfw_level" in p_dict:
		nsfw_level = p_dict.nsfw_level

# @hidden
func get_banner_url() -> String:
	if not banner:
		return ""
	return client._format_image(client.ENDPOINTS.BANNER % [id, banner])


# @hidden
func get_icon_url() -> String:
	if not icon:
		return ""
	return client._format_image(client.ENDPOINTS.GUILD_ICON % [id, icon])


# @hidden
func get_splash_url() -> String:
	if not discovery_splash:
		return ""
	return client._format_image(client.ENDPOINTS.GUILD_DISCOVERY_SPLASH % [id, discovery_splash])


# Add a role to a guild member
# @param member_id The id of the member
# @param role_id The id of the role to add
# @param reason The reason to be displayed in audit logs `optional`
# @returns [bool] | [HTTPResponse] if error
func add_member_role(p_member_id, p_role_id, p_reason = null) -> bool:
	return client.add_guild_member_role(id, p_member_id, p_role_id, p_reason)


# Ban a user from the guild
# @param user_id The id of the member
# @param delete_message_days The number of days to delete messages for, between 0-7 inclusive `optional`
# @param reason The reason to be displayed in audit logs `optional`
# @returns [bool] | [HTTPResponse] if error
func ban_member(p_user_id, p_delete_message_days = 0, p_reason = null) -> bool:
	return client.ban_guild_member(id, p_user_id, p_delete_message_days, p_reason)


# Create a channel in the guild
# @returns [CategoryChannel] | [TextChannel] | [TextVoiceChannel] | [HTTPResponse] if error
func create_channel(p_name, p_type, p_options = {}, p_reason = null) -> Channel:
	return client.create_channel(id, p_name, p_type, p_options, p_reason)


# Create a emoji in the guild
# @param options: [Dictionary] Emoji options
# @param options.image: [String] The base64 encoded string
# @param options.name: [String] The name of emoji
# @param options.roles: [Array] of [String] An array containing authorized role ids `optional`
# @param reason: [String] The reason to be displayed in audit logs `optional`
# @returns [Dictionary] | [HTTPResponse] if error
func create_emoji(p_options, p_reason = null) -> Dictionary:
	return client.create_emoji(id, p_options, p_reason)


# Create a guild sticker
# options: [Dictionary] Sticker options
# options.description: [String] The description of the sticker `optional`
# options.file: [DiscordFile] | [Dictionary] A file object
# options.file.filename: [String] The name of the file with extension
# options.file.contents: [PoolBufferArray] A buffer containing file data
# options.file.content_type: [String] The MIME type of the file
# options.name: [String] The name of the sticker
# options.tags: [String] The Discord name of a unicode emoji representing the sticker's expression
# [reason] The reason to be displayed in audit logs
# @returns [Dictionary] | [HTTPResponse] if error
func create_sticker(p_options, p_reason = {}) -> Dictionary:
	return client.create_sticker(id, p_options, p_reason)


# Create a template for this guild
# name: [String] The name of the template
# description: [String] The description for the template `optional`
# @returns [GuildTemplate] | [HTTPResponse] if error
func create_template(p_name, p_description = null) -> GuildTemplate:
	return client.create_template(id, p_name, p_description)


# Delete the guild (bot user must be owner)
# @returns [bool] | [HTTPResponse] if error
func delete() -> bool:
	return client.delete_guild(id)


# Delete a emoji in the guild
# @param emoji_id: [String] The id of the emoji
# @param reason: [String] The reason to be displayed in the audit logs `optional`
# @returns [bool] | [HTTPResponse] if error
func delete_emoji(p_emoji_id, p_reason = null) -> bool:
	return client.delete_guild_emoji(id, p_emoji_id, p_reason)


# Delete a guild integration
# @param integration_id: [String] The id of the integration
# @param reason: [String] The reason to be displayed in the audit logs `optional`
# @returns [bool] | [HTTPResponse] if error
func delete_integration(p_integration_id, p_reason = null) -> bool:
	return client.delete_guild_integration(id, p_integration_id, p_reason)


# Delete a role in the guild
# @param role_id: [String] The id of the role
# @param reason: [String] The reason to be displayed in the audit logs `optional`
# @returns [bool] | [HTTPResponse] if error
func delete_role(p_role_id, p_reason = null) -> bool:
	return client.delete_guild_role(id, p_role_id, p_reason)


# Delete a guild sticker
# @param sticker_id: [String] The id of the sticker
# @param reason: [String] The reason to be displayed in the audit logs `optional`
# @returns [bool] | [HTTPResponse] if error
func delete_sticker(p_sticker_id, p_reason = null) -> bool:
	return client.delete_guild_sticker(id, p_sticker_id, p_reason)


# Delete a guild template
# @param template_id: [String] The id of the template
# @returns [bool] | [HTTPResponse] if error
func delete_template(p_code) -> bool:
	return client.delete_guild_template(id, p_code)


# Get the guild's banner with the given format and size
# @param format: [String] The filetype of the icon ("png", "jpg", "jpeg", "gif" or "webp") `optional`
# @param size: [String] The size of the icon (any power of two between 16 and 4096) `optional`
# @returns [String] | [HTTPResponse] if error
func dynamic_banner_url(p_format = null, p_size = null) -> String:
	if not banner:
		return ""
	return client._format_image(client.ENDPOINTS.BANNER % [id, banner], p_format, p_size)


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
		"afk_channel_id",
		"afk_timeout",
		"application_id",
		"approximate_member_count",
		"approximate_presence_count",
		"auto_removed",
		"banner",
		"categories",
		"channels",
		"default_notifications",
		"description",
		"discovery_splash",
		"emoji_count",
		"emojis",
		"explicit_content_filter",
		"features",
		"icon",
		"joined_at",
		"keywords",
		"large",
		"max_members",
		"max_presences",
		"max_video_channel_users",
		"member_count",
		"members",
		"mfa_level",
		"name",
		"owner_id",
		"pending_voice_states",
		"preferred_locale",
		"premium_progress_bar_enabled",
		"premium_subscription_count",
		"premium_tier",
		"primary_category",
		"primary_category_id",
		"public_updates_channel_id",
		"roles",
		"rules_channel_id",
		"splash",
		"stickers",
		"system_channel_flags",
		"system_channel_id",
		"unavailable",
		"vanity_url",
		"verification_level",
		"voice_states",
		"welcome_screen",
		"widget_channel_id",
		"widget_enabled",
	])
	return .to_dict(p_props)
