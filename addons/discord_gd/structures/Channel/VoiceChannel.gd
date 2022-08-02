# Represents a Discord guild voice channel
#
# See [GuildChannel] for extra properties and methods
class_name VoiceChannel extends GuildChannel

var bitrate: int # The bitrate of the channel
var rtc_region: String # The RTC region id of the channel (automatic when `null`)
var user_limit: int # The max number of users that can join the channel
var video_quality_mode: int # The camera video quality mode of the voice channel. `1` is auto, `2` is 720p
var voice_members:  DiscordCollection # [DiscordCollection] of [GuildMember] in this channel


# @hidden
func _init(p_dict, p_client, _name = "VoiceChannel").(p_dict, p_client, _name):
	voice_members = DiscordCollection.new(load("res://addons/discord_gd/structures/GuildMember.gd"))
	update(p_dict)

	return self


# @hidden
func update(p_dict):
	.update(p_dict)

	if "bitrate" in p_dict:
		bitrate = p_dict.bitrate
	if "rtc_region" in p_dict:
		rtc_region = p_dict.rtc_region
	if "user_limit" in p_dict:
		user_limit = p_dict.user_limit
	if "video_quality_mode" in p_dict:
		video_quality_mode = p_dict.video_quality_mode


# Create an invite for the channel (all properties are `optional`)
# @param options: [Dictionary] Invite generation options `optional`
# @param options.max_age: [int] How long the invite should last in seconds
# @param options.max_uses: [int] How many uses the invite should last for
# @param options.temporary: [bool] Whether the invite grants temporary membership or not
# @param options.unique: [bool] Whether the invite is unique or not
# @param reason: [String] The reason to be displayed in audit logs `optional`
# @returns [Invite] | [HTTPResponse] if error
func create_invite(p_options = {}, p_reason = null):
	return client.create_channel_invite(id, p_options, p_reason)


# Get all invites in the channel
# @returns [Array] of [Invite] | [HTTPResponse] if error
func get_invites() -> Array:
	return client.get_channel_invites(id)


# Join the channel
# @param options: [Dictionary] Voice connection options (all properties are optional)
# @param options.opus_only: [bool] Skip opus encoder initialization. You should not enable this unless you know what you are doing
# @param options.shared: [bool] Whether the VoiceConnection will be part of a SharedStream or not
# @param options.self_mute: [bool] Whether the bot joins the channel muted or not
# @param options.self_deaf: [bool] Whether the bot joins the channel deafened or not
# @returns [VoiceConnection]
func join(p_options = {}): # TODO: add static types and type if error
	return client.join_voice_channel(id, p_options)


# Leave the channel
func leave(): # TODO: add types for return error
	return client.leave_voice_channel(id)


# @hidden
func to_dict(p_props = []) -> Dictionary:
	p_props.append_array([
		"bitrate",
		"rtc_region",
		"user_limit",
		"video_quality_mode",
		"voice_members"
	])
	return .to_dict(p_props)
