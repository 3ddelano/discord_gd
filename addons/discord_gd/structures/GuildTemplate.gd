# Represents a Discord guild template
class_name GuildTemplate extends DiscordDataclass

var client # [DiscordClient] The client who instantiated this guild template

var code: String # The template code
var created_at: int # Timestamp of template creation
var creator: User # User that created the template
var description: String # The template description
var is_dirty: bool # Whether the template has unsynced changes
var name: String # The template name
var serialized_source_guild # [Guild] The guild snapshot this template contains
var source_guild # [Guild] | [Dictionary] The guild this template is based on. If the guild is not cached, this will be a Dictionary with `id` key. No other property is guaranteed
var updated_at: int # Timestamp of template update
var usage_count: int # Number of times this template has been used


func _init(p_dict, p_client).("GuildTemplate"):
	client = p_client

	if "code" in p_dict:
		code = p_dict.code
	if "created_at" in p_dict:
		created_at = p_dict.created_at
	if "creator" in p_dict:
		creator = p_dict.creator
	if "description" in p_dict:
		description = p_dict.description
	if "is_dirty" in p_dict:
		is_dirty = p_dict.is_dirty
	if "name" in p_dict:
		name = p_dict.name
	if "serialized_source_guild" in p_dict:
		serialized_source_guild = p_dict.serialized_source_guild
	if "source_guild" in p_dict:
		source_guild = p_dict.source_guild
	if "updated_at" in p_dict:
		updated_at = p_dict.updated_at
	if "usage_count" in p_dict:
		usage_count = p_dict.usage_count

	return self


# Create a guild based on this template. This can only be used with bots in less than 10 guilds
# @param name: [String] The name of the guild
# @param [icon]: [String] The 128x128 icon as a base64 data URI `optional`
# @returns [Guild] | [HTTPResponse] if error
func create_guild(p_name: String, p_icon = null):
	return client.create_guild_from_template(code, p_name, p_icon)


# Delete this template
# @returns [GuildTemplate] | [HTTPResponse] if error
func delete():
	return client.delete_guild_template(source_guild.id, code)

# Edit this template
# @param options: [Dictionary] The properties to edit `optional`
# @param options.name: [String] The name of the template `optional`
# @param options.description: [String] The description for the template. Set to `null` to remove the description `optional`
# @returns [GuildTemplate] | [HTTPResponse] if error
func edit(p_options = {}):
	return client.edit_guild_template(source_guild.id, code, p_options)


# Force this template to sync to its guild's current state
# @returns [GuildTemplate] | [HTTPResponse] if error
func sync():
	return client.sync_guild_template(source_guild.id, code)


# @hidden
func to_dict(p_props = []) -> Dictionary:
	p_props.append_array([
		"code",
		"created_at",
		"creator",
		"description",
		"is_dirty",
		"name",
		"serialized_source_guild",
		"source_guild",
		"updated_at",
		"usage_count",
	])

	return .to_dict(p_props)
