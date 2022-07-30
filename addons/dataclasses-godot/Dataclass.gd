# Copyright 2022 Delano Lourenco
# https://github.com/3ddelano/dataclasses-godot
# MIT License
# See License.md
class_name Dataclass, "res://addons/dataclasses-godot/DataclassIcon.svg"
extends Reference


const __DEFAULT_OPTIONS__ = {
	# Whether to sort properties when printing
	"sort_keys": true,

	# Whether to include properties with null values in the to_dict() method
	"include_null_in_dict": true,

	# Whether to include properties with null values when printing
	"include_null_in_print": true,

	# Whether to print properties on newlines when printing
	"print_newline": false,

	# Names of properties to exclude when printing
	"print_exclude": []
}


func from_dict(p_dict: Dictionary):
	for key in p_dict:
		if not key in self:
			printerr("Dataclass:from_dict: Error: Key \"%s\" not found in dataclass \"%s\"" % [key, __name__])
			continue

		# Check for types match
		var typeof_expected = typeof(get(key))
		var typeof_received = typeof(p_dict[key])
		if typeof_expected != TYPE_NIL and typeof_received != typeof_expected and (
			(not typeof_expected in [TYPE_INT, TYPE_REAL]) and
			(not typeof_received in [TYPE_INT, TYPE_REAL])
		):
			printerr("Dataclass:from_dict: Warning: Key \"%s\" has type %s but expected type %s in dataclass \"%s\"" % [key, __type_to_string(typeof_received) , __type_to_string(typeof_expected), __name__])
		set(key, p_dict[key])

	return self


func to_dict() -> Dictionary:
	var ret = {}
	var all_props = __get_props()
	for prop in all_props:
		var value = get(prop.name)
		if value != null or __options__.include_null_in_dict:
			ret[prop.name] = value

	return ret



var __name__: String
var __options__: Dictionary


func _init(p_name: String, p_options: Dictionary = {}):
	__name__ = p_name
	__options__ = __DEFAULT_OPTIONS__.duplicate()
	set_meta("is_dataclass", true)

	# Override options
	for key in p_options:
		__options__[key] = p_options[key]

	return self


func get_class() -> String:
	return __name__


func __get_props() -> Array:
	var all_props = get_property_list()
	all_props.pop_front()
	all_props.pop_front()
	all_props.pop_front()
	all_props.pop_front()
	all_props.pop_front()
	all_props.pop_front()

	if __options__.sort_keys:
		all_props.sort_custom(_PropertySorterAlphabetical, "sort_ascending")

	return all_props


func __type_to_string(p_type: int, p_capital = true) -> String:
	if p_capital:
		return ["NIL", "BOOL", "INT", "REAL", "STRING", "VECTOR2", "RECT2", "VECTOR3", "TRANSFORM2D", "PLANE", "QUAT", "AABB", "BASIS", "TRANSFORM", "COLOR", "NODE_PATH", "RID", "OBJECT", "DICTIONARY", "ARRAY", "RAW_ARRAY", "INT_ARRAY", "REAL_ARRAY", "STRING_ARRAY", "VECTOR2_ARRAY", "VECTOR3_ARRAY", "COLOR_ARRAY", "MAX"][p_type]

	return ["Nil", "Bool", "Int", "Real", "String", "Vector2", "Rect2", "Vector3", "Transform2D", "Plane", "Quat", "AABB", "Basis", "Transform", "Color", "NodePath", "RID", "Object", "Dictionary", "Array", "RawArray", "IntArray", "RealArray", "StringArray", "Vector2Array", "Vector3Array", "ColorArray", "Max"][p_type]


func __variant_to_string(value, indent_level = 0) -> String:
	var type = typeof(value)

	var newline = ""
	var tab = ""
	var dict_join = ", "
	if __options__.print_newline:
		tab = "\t"
		newline = "\n"
		dict_join = ",\n"

	match type:
		TYPE_STRING:
			return "\"" + value.c_escape() + "\""
		TYPE_NIL, TYPE_INT, TYPE_REAL, TYPE_BOOL:
			return value
		TYPE_QUAT, TYPE_VECTOR2, TYPE_RECT2, TYPE_VECTOR3, TYPE_TRANSFORM2D, TYPE_BASIS:
			return "%s%s"  % [__type_to_string(type, false), value]
		TYPE_RID:
			return "RID(%s)" % value.get_id()
		TYPE_OBJECT:
			if value == null:
				return "Object(null)"
			elif not value is Script and value.get_meta("is_dataclass"):
				return str(value).indent(tab.repeat(indent_level)).trim_prefix(tab.repeat(indent_level))

			return str(value)
		TYPE_DICTIONARY:
			var keys = value.keys()
			var dict_string = PoolStringArray()
			for key in keys:
				dict_string.append("%s: %s" % [key, __variant_to_string(value[key], 0)])

			dict_string = "{" + newline + dict_string.join(dict_join).indent(tab) + newline + "}"

			return dict_string.indent(tab.repeat(indent_level)).trim_prefix(tab.repeat(indent_level))
		TYPE_ARRAY, TYPE_RAW_ARRAY, TYPE_INT_ARRAY, TYPE_REAL_ARRAY, TYPE_STRING_ARRAY, TYPE_VECTOR2_ARRAY, TYPE_VECTOR3_ARRAY, TYPE_COLOR_ARRAY:
			var ret = PoolStringArray()
			for elm in value:
				ret.append(__variant_to_string(elm, 1))
			ret = "[" + ret.join(", ") + "]"
			if type == TYPE_ARRAY: return ret

			return __type_to_string(type, false) + "(" + ret + ")"
		_:
			return "%s(%s)"  % [__type_to_string(type, false), value]


func _to_string() -> String:
	var all_props = __get_props()

	var props = PoolStringArray()
	for prop in all_props:
		if prop.name in __options__.print_exclude:
			continue
		var value = get(prop.name)
		var type = typeof(value)
		if value != null or __options__.include_null_in_print:
			props.append("%s = %s" % [prop.name, __variant_to_string(value, 1)])

	var separator = ", "
	var newline = ""
	var newline_end = ""
	if __options__.print_newline:
		newline = "\n\t"
		newline_end = "\n"
	return __name__ + "(" + newline + props.join(separator + newline) + newline_end + ")"
