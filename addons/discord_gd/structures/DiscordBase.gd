# Provides utilities for working with many Discord objects
class_name DiscordBase extends DiscordDataclass


var id: String # A Discord snowflake identifying the object
var created_at: int setget , _get_created_at # A unix timestamp of object creation


# Create a new object
# @returns self
func _init(p_id = null, _name = "DiscordBase").(_name):
	if p_id != null:
		if not typeof(id) in [TYPE_STRING, TYPE_INT, TYPE_REAL]:
			DiscordUtils.perror("DiscordBase:_init:id must be a string or int, but got: %s" % p_id)
		id = str(p_id)

	return self


func _get_created_at() -> int:
	return __get_created_at(id)


static func __get_created_at(p_id: String):
	return __get_discord_epoch(p_id) + 1420070400000


static func __get_discord_epoch(p_id: String):
	return floor(int(p_id) / 4194304)


# @hidden
func to_dict(p_props = []) -> Dictionary:
	var dict = {}
	if id.is_valid_integer():
		dict.id = id
		dict.created_at = _get_created_at()

	for prop in p_props:
		var value = get(prop)
		var type = typeof(value)

		if value == null:
			DiscordUtils.perror("%s:to_dict:Skipped null value for prop: %s" % [__name__, prop])
			continue
		elif type in [TYPE_BOOL, TYPE_INT, TYPE_REAL, TYPE_STRING, TYPE_DICTIONARY]:
			dict[prop] = value
		elif type == TYPE_ARRAY:
			dict[prop] = value.duplicate(true)
		elif type == TYPE_OBJECT and value.has_method("to_dict"):
			dict[prop] = value.to_dict()
		else:
			DiscordUtils.perror("%s:to_dict:Got invalid type: %s for prop: %s, value: %s" % [__name__, type, prop, value])

	return dict
