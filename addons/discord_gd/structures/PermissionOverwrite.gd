# Represents a Discord permission overwrite
#
# `id`: The id of the overwrite
class_name PermissionOverwrite extends Permission

var type: int # The type of the overwrite, either 1 for "member" or 0 for "role"


# @hidden
func _init(p_dict).(p_dict.get("allow"), p_dict.get("deny"), p_dict.get("id"), "PermissionOverwrite"):
	return self


# @hidden
func to_dict(p_props = []) -> Dictionary:
	p_props.append("type")
	return .to_dict(p_props)
