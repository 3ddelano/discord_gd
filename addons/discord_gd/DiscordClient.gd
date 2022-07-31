class_name DiscordClient extends Node

enum Intents {
	Guilds = 1 << 0,
	GuildMembers = 1 << 1,
	GuildBans = 1 << 2,
	GuildEmojisAndStickers = 1 << 3,
	GuildIntegrations = 1 << 4,
	GuildWebhooks = 1 << 5,
	GuildInvites = 1 << 6,
	GuildVoiceStates = 1 << 7,
	GuildPresences = 1 << 8,
	GuildMessages = 1 << 9,
	GuildMessageReactions = 1 << 10,
	GuildMessageTyping = 1 << 11,
	DirectMessages = 1 << 12,
	DirectMessageReactions = 1 << 13,
	DirectMessageTyping = 1 << 14
}

const IntentsAllNonPrivileged = Intents.Guilds | Intents.GuildBans | Intents.GuildEmojisAndStickers | Intents.GuildIntegrations | Intents.GuildWebhooks | Intents.GuildInvites | Intents.GuildVoiceStates | Intents.GuildMessages | Intents.GuildMessageReactions | Intents.GuildMessageTyping | Intents.DirectMessages | Intents.DirectMessageReactions | Intents.DirectMessageTyping

const IntentsAllPrivileged = Intents.GuildMembers | Intents.GuildPresences
const IntentsAll = IntentsAllNonPrivileged | IntentsAllPrivileged


# TODO: add options
var options = {
	bot = true,
	allowed_mentions = {
		users = true,
		roles = true
	},
	autoreconnect = true,
	compress = false,
	connection_timeout = 30000,
	default_image_format = "jpg",
	default_image_size = 128,
	disable_events = {},
#	first_shard_id = 0,
	get_all_users = false,
	guild_create_timeout = 2000,
	intents = IntentsAllNonPrivileged,
	large_threshold = 250,
	max_reconnect_attempts = INF,
	max_resume_attempts = 10,
#	max_shards = 1,
	message_limit = 100,
	opus_only = false,
	request_timeout = 15000,
	rest = {},
	rest_mode = false,
	seed_voice_connections = false,
#	shard_concurrency = "auto",
	ws = {},
	reconnect_delay = 10 # in seconds
}

var process_nodes = []

var token: String # Token from Discord used to login

var ready = false
var bot = false
var start_time = 0 # Milliseconds since bot connected
var last_connect = 0
var channel_guild_map = {}
var thread_guild_map = {}
var guilds = DiscordCollection.new(load("res://addons/discord_gd/structures/Guild.gd"))
var private_channel_map = {}
var private_channels = DiscordCollection.new(load("res://addons/discord_gd/structures/PrivateChannel.gd"))
#var guild_shard_map = {}
# var unavailable_guilds = DiscordCollection.new(load("res://addons/discord_gd/structures/UnavailableGuild.gd"))
var users = DiscordCollection.new(load("res://addons/discord_gd/structures/User.gd"))
var presence = {
	activities = null,
	afk = false,
	since = null,
	status = "offline"
}
# var voice_connections = VoiceConnectionManager.new()
var last_reconnect_delay = 0
var reconnect_attempts = 0
var uptime: int setget , _get_uptime
var request_handler: DiscordRequestHandler
var gateway_url: String
var shards: DiscordShardManager

func _init(p_token: String, p_options = {}):#.("DiscordClient"):

	token = p_token
	if not token.begins_with("Bot "):
		token = "Bot " + token

	for k in p_options:
		options[k] = p_options[k]

	bot = options.bot

	_format_allowed_mentions()

	request_handler = DiscordRequestHandler.new(self, options.rest)
	shards = DiscordShardManager.new(self)

#	if options.get("last_shard_id") == null and not DiscordUtils.var_is_str(options.get("max_shards"), "auto"):
#		options.last_shard_id = options.max_shards - 1

	# Resolve intents if provided an Array
	if typeof(options.get("intents")) == TYPE_ARRAY:
		var bitmask = 0
		for intent in options.intents:
			if typeof(intent) in [TYPE_REAL, TYPE_INT]:
				bitmask |= intent
			elif Intents[intent]:
				bitmask |= Intents[intent]
			else:
				DiscordUtils.perror("DisordClient:_init:Invalid intent: %s" % intent)
		options.intents = bitmask

	if options.get_all_users and !(options.intents & Intents.GuildMembers):
		DiscordUtils.perror("DiscordClient:_init:Cannot request all members without GuildMembers intent")

#	var shard_manager_options = {}
#	if typeof(options.get("shard_concurrency")) in [TYPE_INT, TYPE_REAL]:
#		shard_manager_options.concurrency = options.shard_concurrency



	return self


func login():
	if token == "":
		DiscordUtils.perror("DiscordClient:login:Invalid token provided")

	var data = ""
#	if DiscordUtils.var_is_str(options.max_shards, "auto") or (DiscordUtils.var_is_str(options.shard_concurrency, "auto") and bot):
	if bot:
		data = yield(get_bot_gateway(), "completed")
	else:
		data = yield(get_gateway(), "completed")

	if data is HTTPResponse and data.is_error():
		DiscordUtils.perror("DiscordClient:login:Error occured: " + str(data))
		return

	if data.get("url") == null or (DiscordUtils.var_is_str(options.get("max_shards"), "auto") and data.get("shards") == null):
		DiscordUtils.perror("DiscordClient:login:Invalid response from gateway REST call")

	var index_quesmark = data.url.find("?")
	if index_quesmark > -1:
		data.url = data.url.substr(0, index_quesmark)
	if not data.url.ends_with("/"):
		data.url += "/"

	gateway_url = data.url + "?v=%s&encoding=json" % [DiscordMetadata.GATEWAY_VERSION]
	print("spawning shard")
	shards.spawn(0)
#	if DiscordUtils.var_is_str(options.max_shards, "auto"):
#		if not data.get("shards"):
#			DiscordUtils.perror("DiscordClient:login:Failed to autoshard due to lack of data from Discord")
#			options.max_shards = 1
#		else:
#			options.max_shards = data.shards
#			if options.last_shard_id == null:
#				options.last_shard_id = data.shards - 1

#	if DiscordUtils.var_is_str(options.shard_concurrency, "auto") and data.get("session_start_limit") and typeof(data.session_start_limit.max_concurrency) in [TYPE_REAL, TYPE_INT]:
#		shards.set_concurrency(data.session_start_limit.max_concurrency)


# Get general and bot-specific info on connecting to the Discord gateway (e.g. connection ratelimit)
# @returns Dictionary | HTTPResponse if error
func get_bot_gateway() -> Dictionary:
	var data = yield(request_handler.request("GET", ENDPOINTS.GATEWAY_BOT, true), "completed")
	return data


func _format_allowed_mentions():
	if options.allowed_mentions == null:
		options.allowed_mentions = null

	var result = {
		parse = []
	}
	if options.allowed_mentions.get("everyone") == true:
		result.parse.append("everyone")

	if options.allowed_mentions.get("roles") == true:
		result.parse.append("roles")
	elif typeof(options.allowed_mentions.get("roles") == TYPE_ARRAY):
		result.roles = options.allowed_mentions.get("roles")

	if options.allowed_mentions.get("users") == true:
		result.parse.append("users")
	elif typeof(options.allowed_mentions.get("users") == TYPE_ARRAY):
		result.users = options.allowed_mentions.get("users")

	if options.allowed_mentions.get("replied_user") != null:
		result.replied_user = options.allowed_mentions.get("replied_user")

	options.allowed_mentions = result


func _format_image(p_url, p_format = null, p_size = null):
	if not p_format or not DiscordConstants.ImageFormats[p_format.to_lower()]:
		if p_url.find("/a_") > -1:
			p_format = "gif"
		else:
			p_format = options.default_image_format
	if not p_size or p_size < DiscordConstants.ImageSizeBoundaries.MINIMUM or p_size > DiscordConstants.ImageSizeBoundaries.MAXIMUM:
		p_size = options.default_image_size
	return "%s%s.%s?size=%s" % [ENDPOINTS.CDN_URL, p_url, p_format, p_size]


# Get a DM channel with a user, or create one if it does not exist
func get_dm_channel(p_user_id) -> PrivateChannel:
	if private_channel_map[p_user_id]:
		yield(get_tree(), "idle_frame")
		return private_channels.get(private_channel_map[p_user_id])

	var data = yield(request_handler.request("POST", ENDPOINTS.USER_CHANNELS % "@me", true, {
		recipients = [p_user_id],
		type = 1,
	}), "completed")

	if data is HTTPResponse and data.is_error():
		return data

	return PrivateChannel.new(data, self)

func get_emoji_guild(p_emoji_id):
	var data = yield(request_handler.request("GET", ENDPOINTS.CUSTOM_EMOJI_GUILD % p_emoji_id, true), "completed")

	if data is HTTPResponse and data.is_error():
		return data

	return Guild.new(data, self)


# Get info on connecting to the Discord gateway
# @returns Dictionary | HTTPResponse if error
func get_gateway():
	var data = yield(request_handler.request("GET", ENDPOINTS.GATEWAY), "completed")
	return data


# Get the audit log for a guild
# @returns [Dictionary](entries: [Array] of [GuildAuditLogEntry], integrations: [Array] of [PartialIntegration], threads: [Array] of [NewsThreadChannel] | [PrivateThreadChannel] | [PublicThreadChannel], users: [Array] of [User], webhooks: [Array] of [Webhook]) | HTTPResponse if error
func get_guild_audit_log(p_guild_id, p_options = {limit = 50}):
	var data = yield(request_handler.request("GET", ENDPOINTS.GUILD_AUDIT_LOG % p_guild_id, true, p_options), "completed")

	if data is HTTPResponse and data.is_error():
		return data

	var guild = guilds.get(p_guild_id)
	for i in data.users.size():
		data.users[i] = users.add(users[i], [self])
	for i in data.threads.size():
		data.threads[i] = guild.threads.update(data.threads[i], self)

	for i in data.entries.size():
		data.entries[i] = GuildAuditLogEntry.new(data.entries[i], guild)
	for i in data.integrations.size():
		data.integrations[i] = GuildIntegration.new(data.integrations[i], guild)

	return {
		entries = data.entries,
		integrations = data.integrations,
		threads = data.threads,
		users = data.users,
		webhooks = data.webhooks,
	}

	return data


func _get_uptime():
	return OS.get_ticks_msec() - start_time


func _process(delta: float) -> void:
	for node in process_nodes:
		if is_instance_valid(node):
			node._process(delta)
		else:
			process_nodes.erase(node)


const ENDPOINTS = {
    ORIGINAL_INTERACTION_RESPONSE = "/webhooks/%s/%s",
    COMMAND = "/applications/%s/commands/%s",
    COMMANDS = "/applications/%s/commands",
    COMMAND_PERMISSIONS = "/applications/%s/guilds/%s/commands/%s/permissions",
    CHANNEL = "/channels/%s",
    CHANNEL_BULK_DELETE = "/channels/%s/messages/bulk-delete",
    CHANNEL_CALL_RING = "/channels/%s/call/ring",
    CHANNEL_CROSSPOST = "/channels/%s/messages/%s/crosspost",
    CHANNEL_FOLLOW = "/channels/%s/followers",
    CHANNEL_INVITES = "/channels/%s/invites",
    CHANNEL_MESSAGE_REACTION = "/channels/%s/messages/%s/reactions/%s",
    CHANNEL_MESSAGE_REACTION_USER = "/channels/%s/messages/%s/reactions/%s/%s",
    CHANNEL_MESSAGE_REACTIONS = "/channels/%s/messages/%s/reactions",
    CHANNEL_MESSAGE = "/channels/%s/messages/%s",
    CHANNEL_MESSAGES = "/channels/%s/messages",
    CHANNEL_MESSAGES_SEARCH = "/channels/%s/messages/search",
    CHANNEL_PERMISSION = "/channels/%s/permissions/%s",
    CHANNEL_PERMISSIONS = "/channels/%s/permissions",
    CHANNEL_PIN = "/channels/%s/pins/%s",
    CHANNEL_PINS = "/channels/%s/pins",
    CHANNEL_RECIPIENT = "/channels/%s/recipients/%s",
    CHANNEL_TYPING = "/channels/%s/typing",
    CHANNEL_WEBHOOKS = "/channels/%s/webhooks",
    CHANNELS = "/channels",
    CUSTOM_EMOJI_GUILD = "/emojis/%s/guild",
    DISCOVERY_CATEGORIES = "/discovery/categories",
    DISCOVERY_VALIDATION = "/discovery/valid-term",
    GATEWAY ="/gateway",
    GATEWAY_BOT ="/gateway/bot",
    GUILD = "/guilds/%s",
    GUILD_AUDIT_LOGS = "/guilds/%s/audit-logs",
    GUILD_BAN = "/guilds/%s/bans/%s",
    GUILD_BANS = "/guilds/%s/bans",
    GUILD_CHANNELS = "/guilds/%s/channels",
    GUILD_COMMAND = "/applications/%s/guilds/%s/commands/%s",
    GUILD_COMMAND_PERMISSIONS = "/applications/%s/guilds/%s/commands/permissions",
    GUILD_COMMANDS = "/applications/%s/guilds/%s/commands",
    GUILD_DISCOVERY = "/guilds/%s/discovery-metadata",
    GUILD_DISCOVERY_CATEGORY = "/guilds/%s/discovery-categories/%s",
    GUILD_EMOJI = "/guilds/%s/emojis/%s",
    GUILD_EMOJIS = "/guilds/%s/emojis",
    GUILD_INTEGRATION = "/guilds/%s/integrations/%s",
    GUILD_INTEGRATION_SYNC = "/guilds/%s/integrations/%s/sync",
    GUILD_INTEGRATIONS = "/guilds/%s/integrations",
    GUILD_INVITES = "/guilds/%s/invites",
    GUILD_VANITY_URL = "/guilds/%s/vanity-url",
    GUILD_MEMBER = "/guilds/%s/members/%s",
    GUILD_MEMBER_NICK = "/guilds/%s/members/%s/nick",
    GUILD_MEMBER_ROLE = "/guilds/%s/members/%s/roles/%s",
    GUILD_MEMBERS = "/guilds/%s/members",
    GUILD_MEMBERS_SEARCH = "/guilds/%s/members/search",
    GUILD_MESSAGES_SEARCH = "/guilds/%s/messages/search",
    GUILD_PREVIEW = "/guilds/%s/preview",
    GUILD_PRUNE = "/guilds/%s/prune",
    GUILD_ROLE = "/guilds/%s/roles/%s",
    GUILD_ROLES = "/guilds/%s/roles",
    GUILD_STICKER = "/guilds/%s/stickers/%s",
    GUILD_STICKERS = "/guilds/%s/stickers",
    GUILD_TEMPLATE = "/guilds/templates/%s",
    GUILD_TEMPLATES = "/guilds/%s/templates",
    GUILD_TEMPLATE_GUILD = "/guilds/%s/templates/%s",
    GUILD_VOICE_REGIONS = "/guilds/%s/regions",
    GUILD_WEBHOOKS = "/guilds/%s/webhooks",
    GUILD_WELCOME_SCREEN = "/guilds/%s/welcome-screen",
    GUILD_WIDGET = "/guilds/%s/widget.json",
    GUILD_WIDGET_SETTINGS = "/guilds/%s/widget",
    GUILD_VOICE_STATE = "/guilds/%s/voice-states/%s",
    GUILDS = "/guilds",
    INTERACTION_RESPOND = "/interactions/%s/%s/callback",
    INVITE = "/invites/%s",
    OAUTH2_APPLICATION = "/oauth2/applications/%s",
    STAGE_INSTANCE = "/stage-instances/%s",
    STAGE_INSTANCES = "/stage-instances",
    STICKER = "/stickers/%s",
    STICKER_PACKS = "/sticker-packs",
    THREAD_MEMBER = "/channels/%s/thread-members/%s",
    THREAD_MEMBERS = "/channels/%s/thread-members",
    THREAD_WITH_MESSAGE = "/channels/%s/messages/%s/threads",
    THREAD_WITHOUT_MESSAGE = "/channels/%s/threads",
    THREADS_ACTIVE = "/channels/%s/threads/active",
    THREADS_ARCHIVED = "/channels/%s/threads/archived/%s",
    THREADS_ARCHIVED_JOINED = "/channels/%s/users/@me/threads/archived/private",
    THREADS_GUILD_ACTIVE = "/guilds/%s/threads/active",
    USER = "/users/%s",
    USER_BILLING = "/users/%s/billing",
    USER_BILLING_PAYMENTS = "/users/%s/billing/payments",
    USER_BILLING_PREMIUM_SUBSCRIPTION = "/users/%s/billing/premium-subscription",
    USER_CHANNELS = "/users/%s/channels",
    USER_CONNECTIONS = "/users/%s/connections",
    USER_CONNECTION_PLATFORM = "/users/%s/connections/%s/%s",
    USER_GUILD = "/users/%s/guilds/%s",
    USER_GUILDS = "/users/%s/guilds",
    USER_MFA_CODES = "/users/%s/mfa/codes",
    USER_MFA_TOTP_DISABLE = "/users/%s/mfa/totp/disable",
    USER_MFA_TOTP_ENABLE = "/users/%s/mfa/totp/enable",
    USER_NOTE = "/users/%s/note/%s",
    USER_PROFILE = "/users/%s/profile",
    USER_RELATIONSHIP = "/users/%s/relationships/%s",
    USER_SETTINGS = "/users/%s/settings",
    USERS = "/users",
    VOICE_REGIONS = "/voice/regions",
    WEBHOOK = "/webhooks/%s",
    WEBHOOK_MESSAGE = "/webhooks/%s/%s/messages/%s",
    WEBHOOK_SLACK = "/webhooks/%s/slack",
    WEBHOOK_TOKEN = "/webhooks/%s/%s",
    WEBHOOK_TOKEN_SLACK = "/webhooks/%s/%s/slack",

    # CDN Endpoints
    ACHIEVEMENT_ICON = "/app-assets/%s/achievements/%s/icons/%s",
    APPLICATION_ASSET = "/app-assets/%s/%s",
    APPLICATION_ICON = "/app-icons/%s/%s",
    BANNER = "/banners/%s/%s",
    CHANNEL_ICON = "/channel-icons/%s/%s",
    CUSTOM_EMOJI = "/emojis/%s",
    DEFAULT_USER_AVATAR = "/embed/avatars/%s",
    GUILD_AVATAR = "/guilds/%s/users/%s/avatars/%s",
    GUILD_DISCOVERY_SPLASH = "/discovery-splashes/%s/%s",
    GUILD_ICON = "/icons/%s/%s",
    GUILD_SPLASH = "/splashes/%s/%s",
    ROLE_ICON = "/role-icons/%s/%s",
    TEAM_ICON = "/team-icons/%s/%s",
    USER_AVATAR = "/avatars/%s/%s",

    # Client Endpoints
    MESSAGE_LINK = "/channels/%s/%s/%s",
}

