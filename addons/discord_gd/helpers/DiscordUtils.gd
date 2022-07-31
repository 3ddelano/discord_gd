# Helper methods for Discord.gd
class_name DiscordUtils

# Duck type check if any variable is a given string
static func var_is_str(variable, string) -> bool:
	return typeof(variable) == TYPE_STRING and variable == string

# Get a property from an object if not null else default
static func get_or_default(obj, property, default):
	if property in obj and obj[property] != null:
		return obj[property]
	return default


# Set a property of an object if not null
static func set_if_not_null(obj, property, value):
	if value != null:
		obj[property] = value


# Convert a [Dictionary] to a URL query string
static func query_string_from_dict(p_dict: Dictionary) -> String:
	return HTTPClient.new().query_string_from_dict(p_dict)


# Helper to print errors
static func perror(p_var):
	printerr(p_var)


# Assign the to_dict() of a [DiscordDataclass] inside a [Dictionary]
static func try_dataclass_to_dict(p_dict: Dictionary, p_key: String):
	if p_dict.has(p_key) and p_dict[p_key] != null:
		p_dict[p_key] = p_dict[p_key].to_dict()


# Assign the bitfield of a [BitField] inside a [Dictionary]
static func try_bitfield_to_int(p_dict: Dictionary, p_key: String, p_to_str = false):
	if p_dict.has(p_key) and p_dict[p_key] != null:
		p_dict[p_key] = p_dict[p_key].bitfield
		if p_to_str: p_dict[p_key] = str(p_dict[p_key])


# Assign the to_dict() of an [Array] of [DiscordDataclass] inside a [Dictionary]
static func try_array_dataclass_to_dict(p_dict: Dictionary, p_key: String):
	if p_dict.has(p_key) and p_dict[p_key] != null:
		for i in p_dict[p_key].size():
			p_dict[p_key][i] = p_dict[p_key][i].to_dict()


# Convert an [Array] of [Dictinanry] to [Array] of [DiscordFile] inside a [Dictionary]
static func try_files_from_dict(p_dict: Dictionary, p_key: String, p_output_array):
	if p_dict.has(p_key) and p_dict[p_key] != null:
		p_output_array = []
		for data in p_dict[p_key]:
			if typeof(data) == TYPE_OBJECT and data.get_class() != "DiscordFile":
				perror("DiscordUtils:try_files_from_dict:Got non DiscordFile in files array: %s" % data)
			else:
				p_output_array.append(data)


static func datetime_to_iso_string(p_datetime: Dictionary, p_timezone: String = "+0000") -> String:
	return "%d-%02d-%02dT%02d:%02d:%02d%s" % [p_datetime.year, p_datetime.month, p_datetime.day, p_datetime.hour, p_datetime.minute, p_datetime.second, p_timezone]
