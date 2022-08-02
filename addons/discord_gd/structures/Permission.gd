# Represents a calculated permissions number
class_name Permission extends DiscordBase

var allow: int # The allowed permissions number
var deny: int # The denied permissions number
var json: Dictionary setget , _get_json # A dictionary where true means allowed, false means denied (not included in json means not explicitly set)

enum Permissions {
	CreateInstantInvite = 1 << 0,
	KickMembers = 1 << 1,
	BanMembers = 1 << 2,
	Administrator = 1 << 3,
	ManageChannels = 1 << 4,
	ManageGuild = 1 << 5,
	AddReactions = 1 << 6,
	ViewAuditLog = 1 << 7,
	VoicePrioritySpeaker = 1 << 8,
	VoiceStream = 1 << 9,
	ViewChannel = 1 << 10,
	SendMessages = 1 << 11,
	SendTTSMessages = 1 << 12,
	ManageMessages = 1 << 13,
	EmbedLinks = 1 << 14,
	AttachFiles = 1 << 15,
	ReadMessageHistory = 1 << 16,
	MentionEveryone = 1 << 17,
	UseExternalEmojis = 1 << 18,
	ViewGuildInsights = 1 << 19,
	VoiceConnect = 1 << 20,
	VoiceSpeak = 1 << 21,
	VoiceMuteMembers = 1 << 22,
	VoiceDeafenMembers = 1 << 23,
	VoiceMoveMembers = 1 << 24,
	VoiceUseVAD = 1 << 25,
	ChangeNickname = 1 << 26,
	ManageNicknames = 1 << 27,
	ManageRoles = 1 << 28,
	ManageWebhooks = 1 << 29,
	ManageEmojisAndStickers = 1 << 30,
	UseApplicationCommands = 1 << 31,
	VoiceRequestToSpeak = 1 << 32,
	ManageEvents = 1 << 33,
	ManageThreads = 1 << 34,
	CreatePublicThreads = 1 << 35,
	CreatePrivateThreads = 1 << 36,
	UseExternalStickers = 1 << 37,
	SendMessagesInThreads = 1 << 38,
	StartEmbeddedActivities = 1 << 39,
	ModerateMembers = 1 << 40
}

const PermissionsAllGuild = Permissions.KickMembers | Permissions.BanMembers | Permissions.Administrator | Permissions.ManageChannels | Permissions.ManageGuild | Permissions.ViewAuditLog | Permissions.ViewGuildInsights | Permissions.ChangeNickname | Permissions.ManageNicknames | Permissions.ManageRoles | Permissions.ManageWebhooks | Permissions.ManageEmojisAndStickers | Permissions.ManageEvents | Permissions.ModerateMembers

const PermissionsAllText = Permissions.CreateInstantInvite | Permissions.ManageChannels | Permissions.AddReactions | Permissions.ViewChannel | Permissions.SendMessages | Permissions.SendTTSMessages | Permissions.ManageMessages | Permissions.EmbedLinks | Permissions.AttachFiles | Permissions.ReadMessageHistory | Permissions.MentionEveryone | Permissions.UseExternalEmojis | Permissions.ManageRoles | Permissions.ManageWebhooks | Permissions.UseApplicationCommands | Permissions.ManageThreads | Permissions.CreatePublicThreads | Permissions.CreatePrivateThreads | Permissions.UseExternalStickers | Permissions.SendMessagesInThreads

const PermissionsAllVoice = Permissions.CreateInstantInvite | Permissions.ManageChannels | Permissions.VoicePrioritySpeaker | Permissions.VoiceStream | Permissions.ViewChannel | Permissions.VoiceConnect | Permissions.VoiceSpeak | Permissions.VoiceMuteMembers | Permissions.VoiceDeafenMembers | Permissions.VoiceMoveMembers | Permissions.VoiceUseVAD | Permissions.ManageRoles | Permissions.VoiceRequestToSpeak | Permissions.StartEmbeddedActivities

const PermissionsAll = PermissionsAllGuild | PermissionsAllText | PermissionsAllVoice


# @hidden
func _init(_allow, _deny = 0, _id = null, _name = "Permission").(_id, _name):
	allow = int(_allow)
	deny = int(_deny)

	return self


func _get_json():
	json = {}
	for perm in Permissions.keys():
		if allow & Permissions[perm]:
			json[perm] = true
		elif deny & Permissions[perm]:
			json[perm] = false
	return json


# Check if this permission allows a specific permission
# @param p_permission: [String] | [int] The name of the permission, or bit of permissions
# @returns [bool] Whether the permission allows the specified permission
func has(p_permission) -> bool:
	if typeof(p_permission) in [TYPE_REAL, TYPE_INT]:
		return (allow & p_permission) == p_permission
	else:
		return !!(allow & Permissions[p_permission])


# @hidden
func to_dict(p_props = []) -> Dictionary:
	p_props.append_array([
		"allow",
		"deny",
	])
	return .to_dict(p_props)
