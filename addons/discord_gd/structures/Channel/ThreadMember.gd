# Represents a Discord thread member
#
# `id`: The id of the thread member
class_name ThreadMember extends DiscordBase


var client # [DiscordClient] The client that initialized the thread member
var flags: int # The user-thread settings of this member
var guild_member # [GuildMember] The guild member that this thread member belongs to. This will never be present when fetching over REST
var join_timestamp: int # Timestamp of when the member joined the thread
var thread_id: String # The id of the thread this member is a part of

# @hidden
func _init(p_dict, p_client, _name = "ThreadMember").(p_dict.get("user_id", null), _name):
	client = p_client
	flags = p_dict.flags
	if p_dict.get("thread_id") != null:
		thread_id = p_dict.thread_id
	else:
		thread_id = p_dict.id
	join_timestamp = p_dict.join_timestamp

	if p_dict.get("guild_member") != null:
		var guild = client.guilds.get(client.thread_guild_map[thread_id])
		guild_member = guild.members.update(p_dict.guild_member, [guild])
		if p_dict.get("presence") != null:
			guild_member.update(p_dict.presence)

	update(p_dict)
	return self

# @hidden
func update(p_dict):
	if "flags" in p_dict:
		flags = p_dict.flags


# Remove the member from the thread
# @returns [bool] | [HTTPResponse]
func leave() -> bool:
	return client.leave_thread(thread_id, id)


# @hidden
func to_dict(p_props = []) -> Dictionary:
	p_props.append_array([
		"thread_id",
		"join_timestamp"
	])
	return .to_dict(p_props)
