# Hold a bunch of something
class_name DiscordCollection extends DiscordDataclass

var base_object: Script # [Script] The base class for all items
var base_object_path: String setget , _get_base_object_path
var limit: int # Max number of items to hold

var size: int setget , get_size

var _dict = {} # The internal Dictionary used to store the objects

# Construct a Collection
# @param base_object: [Script] The base class for all items
# @param limit: [int] Max number of items to hold (default is -1 i.e no limit)
# @returns self
func _init(p_base_object: Script, p_limit: int = -1, _name = "DiscordCollection").(_name):
	base_object = p_base_object
	limit = p_limit

	return self


# @hidden
func get_size() -> int:
	return _dict.size()


# Add an object to the collection
# @param obj: [Dictionary] | [Object] The object data
# @param extra: [Array] Any extra parameters the constructor may need `optional`
# @param replace: [bool] Whether to replace an existing object with the same id (default is false) `optional`
# @returns [Object] The existing or newly created object
func add(p_obj, p_extra: Array = [], p_replace: bool = false):
	if limit == 0:
		if p_obj is base_object:
			return p_obj
		else:
			var args = [p_obj]
			args.append_array(p_extra)
			return base_object.callv("new", args)

	if not "id" in p_obj:
		DiscordUtils.perror("Collection(%s):add:Missing obj.id" % _get_base_object_path())
		return null

	var existing = _dict.get(p_obj.id, null)
	if existing != null and not p_replace:
		return existing

	if not (p_obj is base_object):
		var args = [p_obj]
		args.append_array(p_extra)
		p_obj = base_object.callv("new", args)

	_dict[p_obj.id] = p_obj

	var size = _dict.size()
	if limit != -1 and size > limit:
		var keys = _dict.keys()
		var i = 0
		while size > limit:
			_dict.erase(keys[i])
			size -= 1
			i += 1

	return p_obj


# Remove an object
# @param obj: [Object] | [Dictionary] The object / obj.id
# @returns [Object]? The removed object, or `null` if nothing was removed
func remove(p_obj):
	var existing = _dict.get(p_obj.id, null)
	if existing == null:
		return null

	_dict.erase(p_obj.id)

	return p_obj


# Update an object
# @param obj: [Object] | [Dictionary] The updated object data
# @param extra: [Array] Any extra parameters the constructor may need `optional`
# {Boolean} [replace] Whether to replace an existing object with the same id `optional`
# @returns [Object] The updated object
func update(p_obj, p_extra: Array = [], p_replace: bool = false):
		if not p_obj.id and p_obj.id == "":
			DiscordUtils.perror("Collection(%s):update:Missing obj.id" % _get_base_object_path())

		var item = get(p_obj.id)
		if item == null:
			return add(p_obj, p_extra, p_replace)

		item.update(p_obj, p_extra)

		return item


# Returns true if all elements satisfy the condition
# @param func: [FuncRef] A function that takes an object and returns true or false
# @returns [bool] Whether or not all elements satisfied the condition
func every(p_func: FuncRef) -> bool:
	# TODO: add check p_func.is_valid()?
	for value in _dict.values():
		if not p_func.call_func(value):
			return false
	return true


# Returns true if at least one element satisfies the condition
# @param func: [FuncRef] A function that takes an object and returns true or false
# @returns [bool] Whether or not at least one element satisfied the condition
func some(p_func: FuncRef) -> bool:
	# TODO: add check p_func.is_valid()?
	for value in _dict.values():
		if p_func.call_func(value):
			return true
	return false


# Return all the objects that make the function evaluate true
# @param func: [FuncRef] A function that takes an object and returns true if it matches
# @returns [Array] of [Object] An array containing all the objects that matched
func filter(p_func: FuncRef) -> Array:
	# TODO: add check p_func.is_valid()?
	var ret = []
	for value in _dict.values():
		if p_func.call_func(value):
			ret.append(value)
	return ret


# Return the first object to make the function evaluate true
# @param func: [FuncRef] A function that takes an object and returns true if it matches
# @returns [Variant] The first matching object, or `null` if no match
func find(p_func: FuncRef):
	# TODO: add check p_func.is_valid()?
	for value in _dict.values():
		if p_func.call_func(value):
			return value
	return null


# Return an array with the results of applying the given function to each element
# @param func: [FuncRef] A function that takes an object and returns something
# @returns [Array] An array containing the results
func map(p_func: FuncRef) -> Array:
	# TODO: add check p_func.is_valid()?
	var ret = []
	for value in _dict.values():
		ret.append(p_func.call_func(value))
	return ret


# Get a random object from the collection
#
# Call `randomize()` or `seed()` before calling this method
# @returns [Object] he random object, or null if empty
func random():
	var values = _dict.values()
	if values.size() == 0:
		return null
	values.shuffle()
	return values[0]


# Returns a value resulting from applying a function to every element of the collection
# @param func: [FuncRef] A function that takes the previous value and the next item and returns a new value
# @param initial_value: [Variant] The initial value passed to the function
# @returns [Variant] The final result
func reduce(p_func: FuncRef, p_initial_value = null) -> Array:
	# TODO: add check p_func.is_valid()?
	var result = null
	var values = _dict.values()

	if values.size() == 0:
		return result

	if p_initial_value == null: result = values[0]
	else: result = p_initial_value

	for value in values:
		result = p_func.call_func(result, value)

	return result


func to_dict(p_props = []) -> Dictionary:
	var ret = {}

	for key in _dict.keys():
		var value = _dict[key]
		if value is DiscordDataclass:
			ret[key] = value.to_dict()
		else: ret[key] = value

	return ret


func _get_base_object_path() -> String:
	if not base_object:
		return ""
	return base_object.resource_path
