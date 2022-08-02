# Represents a Discord Invite
#
# Some properties are only available when fetching invites from channels, which requires the Manage Channel permission.
#
# `id`: The id of the Invite
# `created_at`: Timestamp of invite creation
class_name Invite extends DiscordBase

var client # [DiscordClient] The client who instantiated this invite

# [NewsChannel] | [TextVoiceChannel] | [GroupChannel] | [StageChannel] | [Dictionary] The channel to which the invite belongs
#
# channel.id: [String] The ID of the invite's channel
# channel.name: [String] The name of the invite's channel `optional`
# channel.type: [int] The type of the invite's channel
# channel.icon: [String] The icon of a channel (group dm) `optional`
var channel = null

var code: String # The invite code
var guild # [Guild] The guild to which the invite belongs
var inviter: User # [User] The invite creator
var max_age: int # How long the invite lasts in seconds
var max_uses: int # The max number of invite uses
var member_count: int # The approximate member count for the guild
var presence_count: int # The approximate presence count for the guild
var stage_instance # [Dictionary] The active public stage instance data for the stage channel this invite is for
var target_application_id: String # The target application id
var target_type: int # The type of the target application
var target_user: User # The user whose stream is displayed for the invite (voice channel only)
var temporary: bool # Whether the invite grants temporary membership or not
var uses: int # The number of invite uses


# @hidden
func _init(p_dict, p_client).(p_dict.get("id", null), "Invite"):
	client = p_client

	if "code" in p_dict:
		code = p_dict["code"]

	if "guild" in p_dict and client.guilds.get(p_dict.guild.id):
		channel = client.guilds.get(p_dict.guild.id).channels.update(p_dict.channel, [client])
	else:
		channel = p_dict.channel

	if "guild" in p_dict:
		if client.guilds.get(p_dict.guild.id):
			guild = client.guilds.update(p_dict.guild, [client])
		else:
			guild = load("res://addons/discord_gd/structures/Guild.gd").new(p_dict.guild, client)

	if "inviter" in p_dict:
		inviter = client.users.add(p_dict.inviter, client)

	if "uses" in p_dict:
		uses = p_dict.uses
	if "max_uses" in p_dict:
		max_uses = p_dict.max_uses
	if "max_age" in p_dict:
		max_age = p_dict.max_age
	if "temporary" in p_dict:
		temporary = p_dict.temporary
	if "created_at" in p_dict:
		created_at = p_dict.created_at
	if "approximate_presence_count" in p_dict:
		presence_count = p_dict.approximate_presence_count
	if "approximate_member_count" in p_dict:
		member_count = p_dict.approximate_member_count
	if "stage_instance" in p_dict:
		var members = []
		for i in p_dict.stage_instance.members.size():
			p_dict.stage_instance.members[i].id = p_dict.stage_instance.members[i].user.id
			members.append(guild.members.update(p_dict.stage_instance.members[i], [guild]))

		stage_instance = {
			members = members,
			participant_count = p_dict.stage_instance.get("participant_count"),
			speaker_count = p_dict.stage_instance.get("speaker_count"),
			topic = p_dict.stage_instance.get("topic"),
		}
	if "target_application" in p_dict and "id" in p_dict.target_application:
		target_application_id = p_dict.target_application.id
	if "target_type" in p_dict:
		target_type = p_dict.target_type
	if "target_user" in p_dict:
		target_user = client.users.update(p_dict.target_user, [client])

	return self


# Delete the invite
# @param reason: [String] The reason to be displayed in audit logs `optional`
# @returns [bool] | [HTTPResponse] if error
func delete(p_reason = null) -> bool:
	return client.delete_invite(code, p_reason)


# @hidden
func to_dict(p_props = []) -> Dictionary:
	p_props.append_array([
		"channel",
		"code",
		"created_at",
		"guild",
		"max_age",
		"max_uses",
		"member_count",
		"presence_count",
		# "revoked",
		"temporary",
		"uses",
	])
	return .to_dict(p_props)
