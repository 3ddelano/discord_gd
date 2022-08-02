# Represents a Discord guild stage channel
#
# See [VoiceChannel] for extra properties and methods
class_name StageChannel extends VoiceChannel

var topic: String # The topic of the channel

# @hidden
func _init(p_dict, p_client, _name = "StageChannel").(p_dict, p_client, _name):
	voice_members = DiscordCollection.new(load("res://addons/discord_gd/structures/GuildMember.gd"))
	update(p_dict)

	if "topic" in p_dict:
		topic = p_dict["topic"]

	return self


# Create a stage instance
# @param options: [Dictionary] Stage instance options
# @param options.topic: [String] The stage instance topic
# @param options.privacy_level: [int] How long the invite should last in seconds `optional`
# @param reason: [String] The reason to be displayed in audit logs `optional`
# @returns [StageInstance] | [HTTPResponse] if error
func create_instance(p_options = {}, p_reason = null): # TODO: add send_start_notification
	return client.create_stage_instance(id, p_options, p_reason)


# Delete the stage instace for this channel
# @param reason: [String] The reason to be displayed in audit logs `optional`
# @returns [bool] | [HTTPResponse] if error
func delete_instance(p_reason = null) -> bool:
	return client.delete_stage_instance(id, p_reason)


# Update the stage instace for this channel
# @param options: [Dictionary] The properties to edit (all properties are optional)
# @param options.topic: [String] The stage instance topic
# @param options.privacy_level: [int] The privacy level of the stage instance. 1 is public, 2 is guild only
# @param reason: [String] The reason to be displayed in audit logs `optional`
# @returns [StageInstance] | [HTTPResponse] if error
func edit_instance(p_options, p_reason = null):
	return client.edit_stage_instance(id, p_options, p_reason)


# Get the stage instance for this channel
# @returns [StageInstance] | [HTTPResponse] if error
func get_instance():
	return client.get_stage_instance(id)


# @hidden
func to_dict(p_props = []) -> Dictionary:
	p_props.append("topic")
	return .to_dict(p_props)
