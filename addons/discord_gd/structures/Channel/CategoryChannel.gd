# Represents a Discord guild category channel
#
# See [GuildChannel] for extra properties and methods
class_name CategoryChannel extends GuildChannel

var channels: DiscordCollection setget , get_channels # [DiscordCollection] of [GuildChannel] A collection of guild channels that are part of this category

# @hidden
func _init(p_dict, p_client).(p_dict, p_client, "CategoryChannel"):
	return self

func get_channels() -> DiscordCollection:
	var ret = DiscordCollection.new(load("res://addons/discord_gd/res://addons/discord_gd/structures/Channel/GuildChannel.gd"))

	if guild and guild.channels:
		for channel in guild.channels:
			if channel.parent_id == id:
				ret.add(channel)

	return ret
