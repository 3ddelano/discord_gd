# Represents a bitfield of Discord user flags
#
# `STAFF`: Discord Employee
#
# `PARTNER`: Partnered Server Owner
#
# `HYPESQUAD`: HypeSquad Events Member
#
# `BUG_HUNTER_LEVEL_1`: Bug Hunter Level 1
#
# `HYPESQUAD_ONLINE_HOUSE_1`: House Bravery Member
#
# `HYPESQUAD_ONLINE_HOUSE_2`: House Brilliance Member
#
# `HYPESQUAD_ONLINE_HOUSE_3`: House Balance Member
#
# `PREMIUM_EARLY_SUPPORTER`: Early Nitro Supporter
#
# `TEAM_PSEUDO_USER`: User is a team
#
# `BUG_HUNTER_LEVEL_2`: Bug Hunter Level 2
#
# `VERIFIED_BOT`: Verified Bot
#
# `VERIFIED_DEVELOPER`: Early Verified Bot Developer
#
# `CERTIFIED_MODERATOR`: Discord Certified Moderator
#
# `BOT_HTTP_INTERACTIONS`: Bot uses only HTTP interactions and is shown in the online member list
class_name UserFlags extends BitField


# Default bit = 0
var default_bit = 0

enum FLAGS {
	STAFF = 1 << 0,
	PARTNER = 1 << 1,
	HYPESQUAD = 1 << 2,
	BUG_HUNTER_LEVEL_1 = 1 << 3,
	HYPESQUAD_ONLINE_HOUSE_1 = 1 << 6,
	HYPESQUAD_ONLINE_HOUSE_2 = 1 << 7,
	HYPESQUAD_ONLINE_HOUSE_3 = 1 << 8,
	PREMIUM_EARLY_SUPPORTER = 1 << 9,
	TEAM_PSEUDO_USER = 1 << 10,
	BUG_HUNTER_LEVEL_2 = 1 << 14,
	VERIFIED_BOT = 1 << 16,
	VERIFIED_DEVELOPER = 1 << 17,
	CERTIFIED_MODERATOR = 1 << 18,
	BOT_HTTP_INTERACTIONS = 1 << 19,
}


# @hidden
func _init(bits = default_bit).(bits): return self
