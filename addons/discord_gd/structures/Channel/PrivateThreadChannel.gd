# Represents a Discord private thread channel
#
# See [ThreadChannel] for extra properties
#
# thread_metadata.locked: [bool] Whether the thread is locked
class_name PrivateThreadChannel extends ThreadChannel

# @hidden
func _init(p_dict, p_client, p_message_limit = -1).(p_dict, p_client, p_message_limit, "PrivateThreadChannel"):
	update(p_dict)

	return self

func update(p_dict: Dictionary):
	.update(p_dict)

	if "thread_metadata" in p_dict:
		thread_metadata = {
			archived = p_dict.thread_metadata.get("archived"),
			auto_archive_duration = p_dict.thread_metadata.get("auto_archive_duration"),
			archive_timestamp = p_dict.thread_metadata.get("archive_timestamp"),
			locked = p_dict.thread_metadata.get("locked"),
			invitable = p_dict.thread_metadata.get("invitable"),
			create_timestamp = p_dict.thread_metadata.get("create_timestamp"),
		}
		# TODO: add create_timestamp to thread_metadata
