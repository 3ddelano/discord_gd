# Represents a Discord guild integration
#
# `id`: The id of the integration
class_name GuildIntegration extends DiscordBase

# Info on the integration account
#
# account.id: The id of the integration account
# account.name: The name of the integration account
var account: Dictionary

var application: Dictionary # The bot/OAuth2 application for Discord integrations. See the [Discord docs](https://discord.com/developers/docs/resources/guild#integration-application-object)
var enabled: bool # Whether the integration is enabled or not
var enable_emoticons: bool # Whether integration emoticons are enabled or not
var expire_behavior: int # Behavior of expired subscriptions
var expire_grace_period: int # Grace period for expired subscriptions
var name: String # The name of the integration
var revoked: bool # Whether or not the application was revoked
var role_id: String # The id of the role connected to the integration
var subscriber_count: int # Number of subscribers
var synced_at: int # Unix timestamp of last integration sync
var syncing: bool # Whether the integration is syncing or not
var type: String # The type of the integration
var user: User # The user connected to the integration

var guild # [Guild] The guild the integration is connected to

func _init(p_dict, p_guild).(p_dict.get("id", null), "GuildIntegration"):
	guild = p_guild
	name = p_dict.name
	type = p_dict.type

	if "role_id" in p_dict:
		role_id = p_dict.role_id
	if "user" in p_dict:
		user = guild.shard.client.users.add(p_dict.user, [guild.shard.client])

	if "account" in p_dict:
		account = p_dict.account
	update(p_dict)

	return self


func update(p_dict):
	enabled = p_dict.enabled
	if "syncing" in p_dict:
		syncing = p_dict.syncing
	if "expire_behavior" in p_dict:
		expire_behavior = p_dict.expire_behavior
	if "expire_grace_period" in p_dict:
		expire_grace_period = p_dict.expire_grace_period
	if "enable_emoticons" in p_dict:
		enable_emoticons = p_dict.enable_emoticons
	if "subscriber_count" in p_dict:
		subscriber_count = p_dict.subscriber_count
	if "synced_at" in p_dict:
		synced_at = p_dict.synced_at
	if "revoked" in p_dict:
		revoked = p_dict.revoked
	if "application" in p_dict:
		application = p_dict.application

	return self


# Delete the guild integration
# @returns [bool] | [HTTPResponse] if error
func delete() -> bool:
	return guild.shard.client.delete_guild_integration(guild.id, id)


# Edit the guild integration
# options: Dictionary The properties to edit
# options.expire_behavior: [String] What to do when a user's subscription runs out `optional`
# options.expire_grace_period: [String] How long before the integration's role is removed from an unsubscribed user `optional`
# options.enable_emoticons: [String] Whether to enable integration emoticons or not `optional`
# @returns [bool] | [HTTPResponse] if error
func edit(p_options: Dictionary) -> bool:
	return guild.shard.client.edit_guild_integration(guild.id, id, p_options)


# Force the guild integration to sync
# @returns [bool] | [HTTPResponse] if error
func sync() -> bool:
	return guild.shard.client.sync_guild_integration(guild.id, id)


# @hidden
func to_dict(p_props = []) -> Dictionary:
	p_props.append_array([
		"account",
		"application",
		"enabled",
		"enable_emoticons",
		"expire_behavior",
		"expire_grace_period",
		"name",
		"revoked",
		"role_id",
		"subscriber_count",
		"synced_at",
		"syncing",
		"type",
		"user",
	])

	return .to_dict(p_props)
