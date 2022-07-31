# Represents a permission overwrite
#
# `id`: The id of the overwrite
class_name PermissionOverwrite extends Permission

var type: int # The type of the overwrite, either 1 for "member" or 0 for "role"


# @hidden
func _init(p_dict).(p_dict.get("allow"), p_dict.get("deny"), p_dict.get("id"), "PermissionOverwrite"):
	return self
