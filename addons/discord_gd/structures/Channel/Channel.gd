# Represents a Discord channel
#
# Also see, [CategoryChannel], [GroupChannel], [NewsChannel], [PrivateChannel], [TextChannel], and [TextVoiceChannel]
#
# `id`: The id of the channel
class_name Channel extends DiscordBase


var type: int # [ChannelTypes] The type of channel
var mention: String setget , get_mention # A string that mentions the channel
var client # [DiscordClient] The client that instantiated this channel


# @hidden
func _init(p_dict, p_client, _name = "Channel").(p_dict.get("id", null), _name):
	type = p_dict.get("type", -1)
	client = p_client
	return self


# @hidden
func get_mention() -> String:
	return "<#%s>" % id


# @hidden
static func from(p_dict, p_client):
	# TODO: after declaring channel classes

	match p_dict.get("type"):
		ChannelTypes.GUILD_TEXT:
			return load("res://addons/discord_gd/structures/Channel/TextChannel.gd").new(p_dict, p_client)
		ChannelTypes.DM:
			return load("res://addons/discord_gd/structures/Channel/PrivateChannel.gd").new(p_dict, p_client)
		ChannelTypes.GUILD_VOICE:
			return load("res://addons/discord_gd/structures/Channel/TextVoiceChannel.gd").new(p_dict, p_client)
		ChannelTypes.GUILD_NEWS:
			return load("res://addons/discord_gd/structures/Channel/NewsChannel.gd").new(p_dict, p_client)
		ChannelTypes.GUILD_CATEGORY:
			return load("res://addons/discord_gd/structures/Channel/CategoryChannel.gd").new(p_dict, p_client)
		ChannelTypes.GUILD_NEWS:
			return load("res://addons/discord_gd/structures/Channel/NewsChannel.gd").new(p_dict, p_client)
		ChannelTypes.GUILD_NEWS_THREAD:
			return load("res://addons/discord_gd/structures/Channel/NewsThreadChannel.gd").new(p_dict, p_client)
		ChannelTypes.GUILD_PUBLIC_THREAD:
			return load("res://addons/discord_gd/structures/Channel/PublicThreadChannel.gd").new(p_dict, p_client)
		ChannelTypes.GUILD_PRIVATE_THREAD:
			return load("res://addons/discord_gd/structures/Channel/PrivateThreadChannel.gd").new(p_dict, p_client)
		ChannelTypes.GUILD_STAGE_VOICE:
			return load("res://addons/discord_gd/structures/Channel/StageChannel.gd").new(p_dict, p_client)

	if "guild_id" in p_dict:
		if "last_message_id" in p_dict:
			p_client.emit_signal("warn", "Unknown guild text channel type: %s\n%s" % [p_dict.get("type", -1), str(p_dict)])
			return load("res://addons/discord_gd/structures/Channel/TextChannel.gd").new(p_dict, p_client)

		p_client.emit_signal("warn", "Unknown guild channel type: %s\n%s" % [p_dict.get("type", -1), str(p_dict)])
		return load("res://addons/discord_gd/structures/Channel/GuildChannel.gd").new(p_dict, p_client)
	else:
		p_client.emit_signal("warn", "Unknown channel type: %s\n%s" % [p_dict.get("type", -1), str(p_dict)])
		return load("res://addons/discord_gd/structures/Channel/GuildChannel.gd").new(p_dict, p_client)


# @hidden
func to_dict(p_props = []) -> Dictionary:
	p_props.append("type")
	return .to_dict(p_props)
