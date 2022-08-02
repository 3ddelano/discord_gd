# Represents a Discord role
#
# `id`: The id of the role
# `created_at`: Timestamp of the role's creation
class_name UnavailableGuild extends DiscordBase

var unavailable: bool # Whether the guild is unavailable or not
var shard # [Shard] The shard the owns the guild


# @hidden
func _init(p_dict, p_client).(p_dict.get("id"), "UnavailableGuild"):
	shard = p_client.shards.get(p_client.guild_shard_map[id])

	if "unavailable" in p_dict:
		unavailable = p_dict.unavailable

	return self


# @hidden
func to_dict(p_props = []) -> Dictionary:
	p_props.append("unavailable")
	return .to_dict(p_props)
