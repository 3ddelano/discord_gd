# Represents a Discord public thread channel
#
# See [ThreadChannel] for extra properties
class_name PublicThreadChannel extends ThreadChannel


# @hidden
func _init(p_dict, p_client, p_message_limit = -1).(p_dict, p_client, p_message_limit, "PublicThreadChannel"):
	return self
