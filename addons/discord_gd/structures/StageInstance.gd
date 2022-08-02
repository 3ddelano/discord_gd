# Represents a Discord stage instance
#
# `id`: The id of the stage instance
class_name StageInstance extends DiscordBase

var client # [DiscordClient] The client who instantiated this stage instance
var channel # [StageChannel] | [Dictionary] The associated stage channel
var discoverable_disabled: bool # Whether or not stage discovery is disabled
var guild # [Guild] The guild of the associated stage channel
var privacy_level: int # The privacy level of the stage instance. 1 is public, 2 is guild only
var topic: String # The stage instance topic


func _init(p_dict, p_client).(p_dict.get("id", null), "StageInstance"):
	client = p_client

	channel = p_client.get_channel(p_dict.get("channel_id"))
	if not channel:
		channel = {id = p_dict.channel_id}
	guild = p_client.guilds.get(p_dict.get("guild_id"))
	if not guild:
		guild = {id = p_dict.guild_id}

	update(p_dict)

	return self


# @hidden
func update(p_dict):
	if "discoverable_disabled" in p_dict:
		discoverable_disabled = p_dict.discoverable_disabled
	if "privacy_level" in p_dict:
		privacy_level = p_dict.privacy_level
	if "topic" in p_dict:
		topic = p_dict.topic


# Delete the stage instance
# @returns [bool] | [HTTPResponse] if error
func delete() -> bool:
	return client.delete_stage_instance(id)


# Update the stage instance
# @param options: [Dictionary] The properties to edit (all properties are optional)
# @param options.topic: [String] The stage instance topic
# @param options.privacy_level: [int] How long the invite should last in seconds
# @returns [bool] | [HTTPResponse] if error
func edit(p_options = {}) -> StageInstance:
	return client.edit_stage_instance(channel.id, p_options)
