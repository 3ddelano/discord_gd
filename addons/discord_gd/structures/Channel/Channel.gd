# Represents a Discord channel
#
# Also see, [CategoryChannel], [GroupChannel], [NewsChannel], [PrivateChannel], [TextChannel], and [TextVoiceChannel]
#
# `id`: The id of the channel
class_name Channel extends DiscordBase


var type: int # [ChannelTypes] The type of channel
var mention: String setget , get_mention # A string that mentions the channel
var client # [DiscordClient] The client that initialized the channel


# @hidden
func _init(p_dict, p_client, _name = "Channel").(p_dict.get("id", null), _name):
	type = p_dict.get("type", -1)
	client = p_client
	return self


# @hidden
func get_mention() -> String:
	return "<#%s>" % id


# @hidden
static func from(data, client):
	# TODO: after declaring channel classes
	pass


# @hidden
func to_dict(p_props = []) -> Dictionary:
	p_props.append("type")
	return .to_dict(p_props)
