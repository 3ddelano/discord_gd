# Dataclass to be used by Discord objects
class_name DiscordDataclass extends Dataclass


# @hidden
func _init(p_name: String, p_options: Dictionary = {}).(p_name, p_options):
	# Override default options
	__options__.include_null_in_dict = false
	__options__.include_null_in_print = false
	__options__.print_newline = true


	# -----
	# Custom functionality
	# -----

	# Nullable properties that are set to null by the user
	# Use a setter method to set __options__.set_props[prop_name] = true
	__options__.set_props = {}


# @hidden
func to_dict(p_props = []) -> Dictionary:
	var dict = .to_dict()
	#var set_props = __options__.set_props.keys()

	# Force set each of the manually set props
	#for prop in set_props: dict[prop] = get(prop)
	#dict = dict.duplicate(true)

	dict = {}
	for prop in p_props:
		dict[prop] = get(prop)

	return dict.duplicate(true)
