# Class managing REST actions of the Discord API.
class_name DiscordRESTClient
extends Node


# Sets the authorization token of the bot
func set_token(token: String) -> void:
	_auth_header = "Authorization: Bot %s" % token


#! ----------
#! AuditLog
#! ----------


## Get the audit logs for the given guild
##
## Needs the `VIEW_AUDIT_LOG` permission
## @returns [AuditLog] | [HTTPResponse] if error
#func get_guild_audit_log(p_guild_id: String, p_params = {}) -> AuditLog:
#	if typeof(p_params) == TYPE_DICTIONARY:
#		p_params = GetGuildAuditLogParams.new().from_dict(p_params)
#	elif not p_params is GetGuildAuditLogParams:
#		DiscordUtils.perror("DiscordRESTClient:get_guild_audit_log:params must be a Dictionary or GetGuildAuditLogParams")
#
#	var endpoint = ENDPOINTS.GUILD_AUDIT_LOGS % p_guild_id
#	var query_string = DiscordUtils.query_string_from_dict(p_params.to_dict())
#	if query_string: endpoint += "?" + query_string
#
#	var data = yield(_send_request(endpoint), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	return AuditLog.new().from_dict(data)
#
#
##! ----------
##! AutoModeration
##! ----------
#
#
## Get a list of auto moderation rules for the given guild
##
## Needs the `MANAGE_GUILD` permission
## @returns [Array] of [AutoModerationRule] | [HTTPResponse] if error
#func get_guild_auto_moderation_rules(p_guild_id: String) -> Array:
#	var data = yield(_send_request(ENDPOINTS.GUILD_AUTO_MODERATION_RULES % p_guild_id), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	var ret = []
#	for elm in data:
#		ret.append(AutoModerationRule.new().from_dict(elm))
#	return ret
#
#
## Get a single auto moderation rule
##
## Needs the `MANAGE_GUILD` permission
## @returns [AutoModerationRule] | [HTTPResponse] if error
#func get_guild_auto_moderation_rule(p_guild_id: String, p_rule_id: String) -> Array:
#	var data = yield(_send_request(ENDPOINTS.GUILD_AUTO_MODERATION_RULE % [p_guild_id, p_rule_id]), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	return AutoModerationRule.new().from_dict(data)
#
#
## Creates a new auto moderation rule
##
## Needs the `MANAGE_GUILD` permission
## @returns [AutoModerationRule] | [HTTPResponse] if error
#func create_guild_auto_moderation_rule(p_guild_id: String, p_params = {}) -> AutoModerationRule:
#	if typeof(p_params) == TYPE_DICTIONARY:
#		p_params = CreateGuildAutoModerationRuleParams.new().from_dict(p_params)
#	elif not p_params is CreateGuildAutoModerationRuleParams:
#		DiscordUtils.perror("DiscordRESTClient:create_guild_auto_moderation_rule:params must be a Dictionary or CreateGuildAutoModerationRuleParams")
#	var data = yield(_send_post_request(ENDPOINTS.GUILD_AUTO_MODERATION_RULES % p_guild_id, p_params.to_dict()), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	return AutoModerationRule.new().from_dict(data)
#
#
## Modify an existing auto moderation rule
##
## Needs the `MANAGE_GUILD` permission
## @returns [AutoModerationRule] | [HTTPResponse] if error
#func modify_guild_auto_moderation_rule(p_guild_id: String, p_rule_id: String, p_params = {}) -> AutoModerationRule:
#	if typeof(p_params) == TYPE_DICTIONARY:
#		p_params = ModifyGuildAutoModerationRuleParams.new().from_dict(p_params)
#	elif not p_params is ModifyGuildAutoModerationRuleParams:
#		DiscordUtils.perror("DiscordRESTClient:modify_guild_auto_moderation_rule:params must be a Dictionary or ModifyGuildAutoModerationRuleParams")
#	var data = yield(_send_patch_request(ENDPOINTS.GUILD_AUTO_MODERATION_RULE % [p_guild_id, p_rule_id], p_params.to_dict()), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	return AutoModerationRule.new().from_dict(data)
#
#
## Deletes an existing auto moderation rule
##
## Needs the `MANAGE_GUILD` permission
## @returns [bool] | [HTTPResponse] if error
#func delete_guild_auto_moderation_rule(p_guild_id: String, p_rule_id: String) -> bool:
#	var data = yield(_send_delete_request(ENDPOINTS.GUILD_AUTO_MODERATION_RULE % [p_guild_id, p_rule_id]), "completed")
#	if data is HTTPResponse:
#		if data.is_error():
#			return data
#		return data.is_no_content()
#	return false
#
#
##! ----------
##! Channel
##! ----------
#
#
## Get a channel.
##
## If the channel is a thread, a [ThreadMember] object is included in the returned result.
## @returns [Channel] | [HTTPResponse] if error
#func get_channel(p_channel_id: String) -> Channel:
#	var data = yield(_send_request(ENDPOINTS.CHANNEL % p_channel_id), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	return Channel.new().from_dict(data)
#
#
## Modify a channel's settings
## @returns [Channel] | [HTTPResponse] if error
#func modify_channel(p_channel_id: String, p_params = {}) -> Channel:
#	if typeof(p_params) == TYPE_DICTIONARY:
#		p_params = ModifyChannelParams.new().from_dict(p_params)
#	elif not p_params is ModifyChannelParams:
#		DiscordUtils.perror("DiscordRESTClient:modify_channel:params must be a Dictionary or ModifyChannelParams")
#	var data = yield(_send_patch_request(ENDPOINTS.CHANNEL % p_channel_id, p_params.to_dict()), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	return Channel.new().from_dict(data)
#
#
## Delete a channel, or close a private message
##
## Needs the `MANAGE_CHANNELS` permission for the guild, or `MANAGE_THREADS` if the channel is a thread
## @returns [Channel] | [HTTPResponse] if error
#func delete_channel(p_channel_id: String) -> Channel:
#	var data = yield(_send_delete_request(ENDPOINTS.CHANNEL % p_channel_id), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	return Channel.new().from_dict(data)
#
#
## Get the messages for a channel
##
## If operating on a guild channel, this endpoint needs the `VIEW_CHANNEL` permission to be present on the current user. If the current user is missing the `READ_MESSAGE_HISTORY` permission in the channel then this will return no messages (since they cannot read the message history)
## @returns [Array] of [Message] | [HTTPResponse] if error
#func get_channel_messages(p_channel_id: String, p_params = {}) -> Array:
#	if typeof(p_params) == TYPE_DICTIONARY:
#		p_params = GetChannelMessagesParams.new().from_dict(p_params)
#	elif not p_params is GetChannelMessagesParams:
#		DiscordUtils.perror("DiscordRESTClient:get_channel_messages:params must be a Dictionary or GetChannelMessagesParams")
#
#	var endpoint = ENDPOINTS.CHANNEL_MESSAGES % p_channel_id
#	var query_string = DiscordUtils.query_string_from_dict(p_params.to_dict())
#	if query_string: endpoint += "?" + query_string
#
#	var data = yield(_send_request(endpoint), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	var ret = []
#	for elm in data:
#		ret.append(Message.new().from_dict(elm))
#	return ret
#
#
## Get a specifc message in a channel
##
## If operating on a guild channel, this endpoint needs the `READ_MESSAGE_HISTORY` permission to be present on the current user
## @returns [Array] of [Message] | [HTTPResponse] if error
#func get_channel_message(p_channel_id: String, p_message_id: String) -> Message:
#	var data = yield(_send_request(ENDPOINTS.CHANNEL_MESSAGE % [p_channel_id, p_message_id]), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	return Message.new().from_dict(data)
#
#
## Get all pinned messages in the channel
## @returns [Array] of [Message] | [HTTPResponse] if error
#func get_pinned_messages(p_channel_id: String) -> Array:
#	var data = yield(_send_request(ENDPOINTS.CHANNEL_PINS % p_channel_id), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	var ret = []
#	for elm in data:
#		ret.append(Message.new().from_dict(elm))
#	return ret
#
#
## Pin a message in a channel
##
## Needs the `MANAGE_MESSAGES` permission
## @returns [bool] | [HTTPResponse] if error
#func pin_message(p_channel_id: String, p_message_id: String) -> bool:
#	var data = yield(_send_put_request(ENDPOINTS.CHANNEL_PIN % [p_channel_id, p_message_id]), "completed")
#	if data is HTTPResponse:
#		if data.is_error():
#			return data
#		return data.is_no_content()
#	return false
#
#
## Unpin a message in a channel
##
## Needs the `MANAGE_MESSAGES` permission
## @returns [bool] | [HTTPResponse] if error
#func unpin_message(p_channel_id: String, p_message_id: String) -> bool:
#	var data = yield(_send_delete_request(ENDPOINTS.CHANNEL_PIN % [p_channel_id, p_message_id]), "completed")
#	if data is HTTPResponse:
#		if data.is_error():
#			return data
#		return data.is_no_content()
#	return false
#
#
## Post a message to a guild text or DM channel TODO: file uploads
##
## Limitations
## - When operating on a guild channel, the current user must have the `SEND_MESSAGES` permission
## - When sending a message with tts (text-to-speech) set to true, the current user must have the `SEND_TTS_MESSAGES` permission
## - When creating a message as a reply to another message, the current user must have the `READ_MESSAGE_HISTORY` permission
## - The referenced message must exist and cannot be a system message
## - The maximum request size when sending a message is 8MiB
## - For the `embed` field, you can set every field except type (it will be rich regardless of if you try to set it), provider, video, and any height, width, or proxy_url values for images
## @returns [Message] | [HTTPResponse] if error
#func create_message(p_channel_id: String, p_params = {}) -> Message:
#	if typeof(p_params) == TYPE_DICTIONARY:
#		p_params = CreateMessageParams.new().from_dict(p_params)
#	elif not p_params is CreateMessageParams:
#		DiscordUtils.perror("DiscordRESTClient:create_message:params must be a Dictionary or CreateMessageParams")
#
#	var multipart_form_dict = _parse_files_from_dict(p_params.to_dict())
#	var data = yield(_send_multipart_form_request(ENDPOINTS.CHANNEL_MESSAGES % p_channel_id, multipart_form_dict), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	return Message.new().from_dict(data)
#
#
## Crosspost a message in a News Channel to following channels
##
## Needs the `SEND_MESSAGES` permission, if the current user sent the message, or additionally the `MANAGE_MESSAGES` permission, for all other messages, to be present for the current user
## @returns [Message] | [HTTPResponse] if error
#func crosspost_message(p_channel_id: String, p_message_id: String) -> Message:
#	var data = yield(_send_post_request(ENDPOINTS.CHANNEL_MESSAGE_CROSSPOST % [p_channel_id, p_message_id]), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	return Message.new().from_dict(data)
#
#
## Edit a previously sent message
##
## The fields `content`, `embeds`, and `flags` can be edited by the original message author. Other users can only edit `flags` and only if they have the `MANAGE_MESSAGES` permission in the corresponding channel. When specifying flags, ensure to include all previously set flags/bits in addition to ones that you are modifying (unsupported flag changes are currently ignored without error)
## @returns [Message] | [HTTPResponse] if error
#func edit_message(p_channel_id: String, p_message_id: String, p_params = {}) -> Message:
#	if typeof(p_params) == TYPE_DICTIONARY:
#		p_params = EditMessageParams.new().from_dict(p_params)
#	elif not p_params is EditMessageParams:
#		DiscordUtils.perror("DiscordRESTClient:edit_message:params must be a Dictionary or EditMessageParams")
#
#	var multipart_form_dict = _parse_files_from_dict(p_params.to_dict())
#	var data = yield(_send_multipart_form_request(ENDPOINTS.CHANNEL_MESSAGE % [p_channel_id, p_message_id], multipart_form_dict, HTTPClient.METHOD_PATCH), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	return Message.new().from_dict(data)
#
#
## Delete a message
##
## If operating on a guild channel and trying to delete a message that was not sent by the current user, needs the `MANAGE_MESSAGES` permission
## @returns [bool] | [HTTPResponse] if error
#func delete_message(p_channel_id: String, p_message_id: String) -> bool:
#	var data = yield(_send_delete_request(ENDPOINTS.CHANNEL_MESSAGE % [p_channel_id, p_message_id]), "completed")
#	if data is HTTPResponse:
#		if data.is_error():
#			return data
#		return data.is_no_content()
#	return false
#
#
## Delete multiple messages in a single request (bulk delete)
##
## Can only be used on guild channels and needs the `MANAGE_MESSAGES` permission
##
## Any message Ids given that do not exist or are invalid will count towards the minimum and maximum message count (currently 2 and 100 respectively)
##
## *Will not delete messages older than 2 weeks, and will fail with a 400 BAD REQUEST [HTTPResponse] if any message provided is older than that or if any duplicate message Ids are provided*
##
## @returns [bool] | [HTTPResponse] if error
#func delete_messages(p_channel_id: String, p_message_ids: Array) -> bool:
#	var data = yield(_send_post_request(ENDPOINTS.CHANNEL_MESSAGES_BULKDELETE % p_channel_id, {messages = p_message_ids}), "completed")
#	if data is HTTPResponse:
#		if data.is_error():
#			return data
#		return data.is_no_content()
#	return false
#
#
## Edit the channel permission overwrites for a user or role in a channel. Only usable for guild channels
##
## Needs the `MANAGE_ROLES` permission. Only permissions your bot has in the guild or parent channel (if applicable) can be allowed/denied (unless your bot has a `MANAGE_ROLES` overwrite in the channel)
## @returns [bool] | [HTTPResponse] if error
#func edit_channel_permissions(p_channel_id: String, p_overwrite_id: String, p_params = {}) -> bool:
#	if typeof(p_params) == TYPE_DICTIONARY:
#		p_params = EditChannelPermissionsParams.new().from_dict(p_params)
#	elif not p_params is EditChannelPermissionsParams:
#		DiscordUtils.perror("DiscordRESTClient:edit_channel_permissions:params must be a Dictionary or EditChannelPermissionsParams")
#	var data = yield(_send_put_request(ENDPOINTS.CHANNEL_PERMISSIONS % [p_channel_id, p_overwrite_id], p_params.to_dict()), "completed")
#	if data is HTTPResponse:
#		if data.is_error():
#			return data
#		return data.is_no_content()
#	return false
#
#
## Delete a channel permission overwrite for a user or role in a channel. Only usable for guild channels
##
## Needs the `MANAGE_ROLES` permission
## @returns [bool] | [HTTPResponse] if error
#func delete_channel_permissions(p_channel_id: String, p_overwrite_id: String) -> bool:
#	var data = yield(_send_delete_request(ENDPOINTS.CHANNEL_PERMISSIONS % [p_channel_id, p_overwrite_id]), "completed")
#	if data is HTTPResponse:
#		if data.is_error():
#			return data
#		return data.is_no_content()
#	return false
#
#
## Get a list of invites (with metadata) for a given channel
##
## Needs the `MANAGE_CHANNELS` permission
## @returns [Array] of [Invite] | [HTTPResponse] if error
#func get_channel_invites(p_channel_id: String) -> Array:
#	var data = yield(_send_request(ENDPOINTS.CHANNEL_INVITES % p_channel_id), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	var ret = []
#	for elm in data:
#		ret.append(Invite.new().from_dict(elm))
#	return ret
#
#
## Create a new invite for a given channel. Only usable for guild channels
##
## Needs the `CREATE_INSTANT_INVITE` permission
## @returns [Invite] | [HTTPResponse] if error
#func create_channel_invite(p_channel_id: String, p_params = {}) -> Invite:
#	if typeof(p_params) == TYPE_DICTIONARY:
#		p_params = CreateChannelInviteParams.new().from_dict(p_params)
#	elif not p_params is CreateChannelInviteParams:
#		DiscordUtils.perror("DiscordRESTClient:create_channel_invite:params must be a Dictionary or CreateChannelInviteParams")
#	var data = yield(_send_post_request(ENDPOINTS.CHANNEL_INVITES % p_channel_id, p_params.to_dict()), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	return Invite.new().from_dict(data)
#
#
## Create a reaction for the message.
##
## Needs the `READ_MESSAGE_HISTORY` permission to be present on the current user. Additionally, if nobody else has reacted to the message using this emoji, needs the `ADD_REACTIONS` permission to be present on the current user
##
## For custom emojis, specify the emoji in the format `name:id`
## @returns [bool] | [HTTPResponse] if error
#func create_reaction(p_channel_id: String, p_message_id: String, p_emoji: String) -> bool:
#	var data = yield(_send_put_request(ENDPOINTS.REACTIONS_EMOJI_ME % [p_channel_id, p_message_id, p_emoji.percent_encode()]), "completed")
#	if data is HTTPResponse:
#		if data.is_error():
#			return data
#		return data.is_no_content()
#	return false
#
#
## Delete a reaction the current user has made for the message
##
## For custom emojis, specify the emoji in the format `name:id`
## @returns [bool] | [HTTPResponse] if error
#func delete_own_reaction(p_channel_id: String, p_message_id: String, p_emoji: String) -> bool:
#	var data = yield(_send_delete_request(ENDPOINTS.REACTIONS_EMOJI_ME % [p_channel_id, p_message_id, p_emoji.percent_encode()]), "completed")
#	if data is HTTPResponse:
#		if data.is_error():
#			return data
#		return data.is_no_content()
#	return false
#
#
## Delete another user's reaction from a message
##
## Needs the `MANAGE_MESSAGES` permission to be present on the current user.
##
## For custom emojis, specify the emoji in the format `name:id`
## @returns [bool] | [HTTPResponse] if error
#func delete_user_reaction(p_channel_id: String, p_message_id: String, p_emoji: String, p_user_id: String) -> bool:
#	var data = yield(_send_delete_request(ENDPOINTS.REACTIONS_EMOJI_USER % [p_channel_id, p_message_id, p_emoji.percent_encode(), p_user_id]), "completed")
#	if data is HTTPResponse:
#		if data.is_error():
#			return data
#		return data.is_no_content()
#	return false
#
#
## Get a list of users that reacted with this emoji.
##
## For custom emojis, specify the emoji in the format `name:id`
## @returns [Array] of [User] | [HTTPResponse] if error
#func get_reactions(p_channel_id: String, p_message_id: String, p_emoji: String, p_params = {}) -> bool:
#	if typeof(p_params) == TYPE_DICTIONARY:
#		p_params = GetReactionsParams.new().from_dict(p_params)
#	elif not p_params is GetReactionsParams:
#		DiscordUtils.perror("DiscordRESTClient:get_reactions:params must be a Dictionary or GetReactionsParams")
#
#	var endpoint = ENDPOINTS.REACTIONS_EMOJI
#	var query_string = DiscordUtils.query_string_from_dict(p_params.to_dict())
#	if query_string: endpoint += "?" + query_string
#
#	var data = yield(_send_request(endpoint % [p_channel_id, p_message_id, p_emoji.percent_encode()]), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	var ret = []
#	for elm in data:
#		ret.append(User.new().from_dict(elm))
#
#	return ret
#
#
## Deletes all reactions on a message or all reactions for a given emoji if specified.
##
## Needs the `MANAGE_MESSAGES` permission to be present on the current user.
##
## For custom emojis, specify the emoji in the format `name:id`
## @returns [bool] | [HTTPResponse] if error
#func delete_reactions(p_channel_id: String, p_message_id: String, p_emoji: String = "") -> bool:
#	var endpoint = ENDPOINTS.REACTIONS % [p_channel_id, p_message_id]
#	if p_emoji.length() > 0:
#		endpoint = ENDPOINTS.REACTIONS_EMOJI % [p_channel_id, p_message_id, p_emoji]
#
#	var data = yield(_send_delete_request(endpoint), "completed")
#	if data is HTTPResponse:
#		if data.is_error():
#			return data
#		return data.is_no_content()
#	return false
#
#
## Follow a News Channel to send messages to a target channel
##
## Needs the MANAGE_WEBHOOKS permission in the target channel.
## @returns [FollowedChannel] | [HTTPResponse] if error
#func follow_news_channel(p_channel_id: String, p_webhook_channel_id: String) -> FollowedChannel:
#	var data = yield(_send_post_request(ENDPOINTS.CHANNEL_FOLLOWERS % p_channel_id, {webhook_channel_id = p_webhook_channel_id}), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	return FollowedChannel.new().from_dict(data)
#
#
## Trigger a typing indicator for the specified channel
##
## Generally bots should not implement this route. However, if a bot is responding to a command and expects the computation to take a few seconds, this endpoint may be called to let the user know that the bot is processing their message.
## @returns [FollowedChannel] | [HTTPResponse] if error
#func trigger_typing(p_channel_id: String) -> bool:
#	var data = yield(_send_post_request(ENDPOINTS.CHANNEL_TYPING % p_channel_id), "completed")
#	if data is HTTPResponse:
#		if data.is_error():
#			return data
#		return data.is_no_content()
#	return false
#
#
## Adds a recipient to a Group DM using their access token
## @returns [bool] | [HTTPResponse] if error
#func group_dm_add_recipient(p_channel_id: String, p_user_id: String, p_params = {}) -> bool:
#	if typeof(p_params) == TYPE_DICTIONARY:
#		p_params = GroupDmAddRecipientParams.new().from_dict(p_params)
#	elif not p_params is GroupDmAddRecipientParams:
#		DiscordUtils.perror("DiscordRESTClient:get_channel_messages:params must be a Dictionary or GetChannelMessagesParams")
#	var data = yield(_send_put_request(ENDPOINTS.CHANNEL_RECIPIENT % [p_channel_id, p_user_id], p_params.to_dict()), "completed")
#	if data is HTTPResponse:
#		if data.is_error():
#			return data
#		return data.is_no_content()
#	return false
#
#
## Removes a recipient to a Group DM using their access token
## @returns [bool] | [HTTPResponse] if error
#func group_dm_remove_recipient(p_channel_id: String, p_user_id: String) -> bool:
#	var data = yield(_send_delete_request(ENDPOINTS.CHANNEL_RECIPIENT % [p_channel_id, p_user_id]), "completed")
#	if data is HTTPResponse:
#		if data.is_error():
#			return data
#		return data.is_no_content()
#	return false
#
#
## Creates a new thread from an existing message
##
## When called on a `GUILD_TEXT` channel, creates a `GUILD_PUBLIC_THREAD`. When called on a `GUILD_NEWS` channel, creates a `GUILD_NEWS_THREAD`. Does not work on a `GUILD_FORUM` channel. The id of the created thread will be the same as the id of the source message, and as such a message can only have a single thread created from it.
## @returns [Channel] | [HTTPResponse] if error
#func start_thread_from_message(p_channel_id: String, p_message_id: String, p_params = {}) -> Channel:
#	if typeof(p_params) == TYPE_DICTIONARY:
#		p_params = StartThreadWithMessageParams.new().from_dict(p_params)
#	elif not p_params is StartThreadWithMessageParams:
#		DiscordUtils.perror("DiscordRESTClient:start_thread_from_message:params must be a Dictionary or StartThreadWithMessageParams")
#	var data = yield(_send_post_request(ENDPOINTS.CHANNEL_MESSAGE_THREADS % [p_channel_id, p_message_id], p_params.to_dict()), "completed")
#
#	if data is HTTPResponse and data.is_error():
#		return data
#	return Channel.new().from_dict(data)
#
#
## Creates a new thread that is not connected to an existing message.
##
## @returns [Channel] | [HTTPResponse] if error
#func start_thread(p_channel_id: String, p_params = {}) -> Channel:
#	if typeof(p_params) == TYPE_DICTIONARY:
#		p_params = StartThreadParams.new().from_dict(p_params)
#	elif not p_params is StartThreadParams:
#		DiscordUtils.perror("DiscordRESTClient:start_thread:params must be a Dictionary or StartThreadParams")
#	var data = yield(_send_post_request(ENDPOINTS.CHANNEL_THREADS % p_channel_id, p_params.to_dict()), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	return Channel.new().from_dict(data)
#
#
## Creates a new thread in a forum channel, and sends a message within the created thread
##
## The current user must have the `SEND_MESSAGES` permission (`CREATE_PUBLIC_THREADS` is ignored)
## @returns [Channel] | [HTTPResponse] if error
#func start_thread_in_forum(p_channel_id: String, p_params = {}) -> Channel:
#	if typeof(p_params) == TYPE_DICTIONARY:
#		p_params = StartThreadInForumParams.new().from_dict(p_params)
#	elif not p_params is StartThreadInForumParams:
#		DiscordUtils.perror("DiscordRESTClient:start_thread_in_forum:params must be a Dictionary or StartThreadInForumParams")
#
#	var params_dict = p_params.to_dict()
#	if params_dict.message.has("files"):
#		var files = params_dict.message.files
#		params_dict.files = files
#		params_dict.message.erase("files")
#	var multipart_form_dict = _parse_files_from_dict(params_dict)
#	var data = yield(_send_multipart_form_request(ENDPOINTS.CHANNEL_THREADS % p_channel_id, multipart_form_dict), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	return Channel.new().from_dict(data)
#
#
## Get a list of all [ThreadMember] of members of the thread
## @returns [Array] of [ThreadMember] | [HTTPResponse] if error
#func get_thread_members(p_channel_id: String) -> Array:
#	var data = yield(_send_request(ENDPOINTS.CHANNEL_THREADMEMBERS % p_channel_id), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	var ret = []
#	for elm in data:
#		ret.append(ThreadMember.new().from_dict(elm))
#	return ret
#
#
## Get a [ThreadMember] for the specified user if they are a member of the thread, returns a 404 [HTTPResponse] otherwise
## @returns [ThreadMember] | [HTTPResponse] if error
#func get_thread_member(p_channel_id: String, p_user_id: String) -> ThreadMember:
#	var data = yield(_send_request(ENDPOINTS.CHANNEL_THREADMEMBERS_USER % [p_channel_id, p_user_id]), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	return ThreadMember.new().from_dict(data)
#
#
## Adds another member to a thread
##
## Needs the ability to send messages in the thread, also needs the thread to be not archived
## @returns [bool] | [HTTPResponse] if error
#func add_thread_member(p_channel_id: String, p_user_id: String) -> bool:
#	var data = yield(_send_put_request(ENDPOINTS.CHANNEL_THREADMEMBERS_USER % [p_channel_id, p_user_id]), "completed")
#	if data is HTTPResponse:
#		if data.is_error():
#			return data
#		return data.is_no_content()
#	return false
#
#
## Removes another member from a thread
##
## Needs the `MANAGE_THREADS` permission, or the creator of the thread if it is a `GUILD_PRIVATE_THREAD`, also needs the thread to be not archived
## @returns [bool] | [HTTPResponse] if error
#func remove_thread_member(p_channel_id: String, p_user_id: String) -> bool:
#	var data = yield(_send_delete_request(ENDPOINTS.CHANNEL_THREADMEMBERS_USER % [p_channel_id, p_user_id]), "completed")
#	if data is HTTPResponse:
#		if data.is_error():
#			return data
#		return data.is_no_content()
#	return false
#
#
## Adds the current user to a thread
##
## Needs the thread to be not archived
## @returns [bool] | [HTTPResponse] if error
#func join_thread(p_channel_id: String) -> bool:
#	var data = yield(_send_put_request(ENDPOINTS.CHANNEL_THREADMEMBERS_ME % p_channel_id), "completed")
#	if data is HTTPResponse:
#		if data.is_error():
#			return data
#		return data.is_no_content()
#	return false
#
#
## Removes the current user from a thread
##
## Needs the thread to be not archived
## @returns [bool] | [HTTPResponse] if error
#func leave_thread(p_channel_id: String) -> bool:
#	var data = yield(_send_delete_request(ENDPOINTS.CHANNEL_THREADMEMBERS_ME % p_channel_id), "completed")
#	if data is HTTPResponse:
#		if data.is_error():
#			return data
#		return data.is_no_content()
#	return false
#
#
## Get a list of archived threads in the channel that are public
##
## When called on a `GUILD_TEXT` channel, returns threads of type `GUILD_PUBLIC_THREAD`. When called on a `GUILD_NEWS` channel returns threads of type `GUILD_NEWS_THREAD`. Threads are ordered by `archive_timestamp`, in descending order
##
## Needs the `READ_MESSAGE_HISTORY` permission
## @returns [GetArchivedThreadsResponse] | [HTTPResponse] if error
#func get_public_archived_threads(p_channel_id: String, p_params = {}) -> GetArchivedThreadsResponse:
#	if typeof(p_params) == TYPE_DICTIONARY:
#		p_params = GetArchivedThreadsParams.new().from_dict(p_params)
#	elif not p_params is GetArchivedThreadsParams:
#		DiscordUtils.perror("DiscordRESTClient:get_public_archived_threads:params must be a Dictionary or GetArchivedThreadsParams")
#
#	var endpoint = ENDPOINTS.CHANNEL_THREADS_ARCHIVED_PUBLIC % p_channel_id
#	var query_string = DiscordUtils.query_string_from_dict(p_params.to_dict())
#	if query_string: endpoint += "?" + query_string
#
#	var data = yield(_send_request(endpoint), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	return GetArchivedThreadsResponse.new().from_dict(data)
#
#
## Get a list of archived threads in the channel that are of type `GUILD_PRIVATE_THREAD`
##
## Threads are ordered by `archive_timestamp`, in descending order
##
## Needs both the `READ_MESSAGE_HISTORY` and `MANAGE_THREADS` permissions
## @returns [GetArchivedThreadsResponse] | [HTTPResponse] if error
#func get_private_archived_threads(p_channel_id: String, p_params = {}) -> GetArchivedThreadsResponse:
#	if typeof(p_params) == TYPE_DICTIONARY:
#		p_params = GetArchivedThreadsParams.new().from_dict(p_params)
#	elif not p_params is GetArchivedThreadsParams:
#		DiscordUtils.perror("DiscordRESTClient:get_private_archived_threads:params must be a Dictionary or GetArchivedThreadsParams")
#
#	var endpoint = ENDPOINTS.CHANNEL_THREADS_ARCHIVED_PRIVATE % p_channel_id
#	var query_string = DiscordUtils.query_string_from_dict(p_params.to_dict())
#	if query_string: endpoint += "?" + query_string
#
#	var data = yield(_send_request(endpoint), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	return GetArchivedThreadsResponse.new().from_dict(data)
#
#
## Get a list of archived threads in the channel that are of type `GUILD_PRIVATE_THREAD` and the user has joined
##
## Threads are ordered by their `id`, in descending order
##
## Needs the `READ_MESSAGE_HISTORY`
## @returns [GetArchivedThreadsResponse] | [HTTPResponse] if error
#func get_joined_private_archived_threads(p_channel_id: String, p_params = {}) -> GetArchivedThreadsResponse:
#	if typeof(p_params) == TYPE_DICTIONARY:
#		p_params = GetJoinedPrivateArchivedThreadsParams.new().from_dict(p_params)
#	elif not p_params is GetJoinedPrivateArchivedThreadsParams:
#		DiscordUtils.perror("DiscordRESTClient:get_joined_private_archived_threads:params must be a Dictionary or GetJoinedPrivateArchivedThreadsParams")
#
#	var endpoint = ENDPOINTS.CHANNEL_USERS_ME_THREADS_ARCHIVED_PRIVATE % p_channel_id
#	var query_string = DiscordUtils.query_string_from_dict(p_params.to_dict())
#	if query_string: endpoint += "?" + query_string
#
#	var data = yield(_send_request(endpoint), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	return GetArchivedThreadsResponse.new().from_dict(data)
#
#
##! ----------
##! Emoji
##! ----------
#
#
## Get a list of [Emoji] for the given guild
## @returns [Array] of [Emoji] | [HTTPResponse] if error
#func get_guild_emojis(p_guild_id: String) -> Array:
#	var data = yield(_send_request(ENDPOINTS.GUILD_EMOJIS % p_guild_id), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	var ret = []
#	for elm in data:
#		ret.append(Emoji.new().from_dict(elm))
#	return ret
#
#
## Get a spefic emoji in the given guild
## @returns [Emoji] | [HTTPResponse] if error
#func get_guild_emoji(p_guild_id: String, p_emoji_id: String) -> Emoji:
#	var data = yield(_send_request(ENDPOINTS.GUILD_EMOJI % [p_guild_id, p_emoji_id]), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	return Emoji.new().from_dict(data)
#
#
## Create a new emoji for the guild
##
## Needs the `MANAGE_EMOJIS_AND_STICKERS` permission
## @returns [Emoji] | [HTTPResponse] if error
#func create_guild_emoji(p_guild_id: String, p_params = {}) -> Emoji:
#	if typeof(p_params) == TYPE_DICTIONARY:
#		p_params = CreateGuildEmojiParams.new().from_dict(p_params)
#	elif not p_params is CreateGuildEmojiParams:
#		DiscordUtils.perror("DiscordRESTClient:create_guild_emoji:params must be a Dictionary or CreateGuildEmojiParams")
#
#	var data = yield(_send_post_request(ENDPOINTS.GUILD_EMOJIS % p_guild_id, p_params.to_dict()), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	return Emoji.new().from_dict(data)
#
#
## Modify an existing emoji in a guild
##
## Needs the `MANAGE_EMOJIS_AND_STICKERS` permission
## @returns [Emoji] | [HTTPResponse] if error
#func modify_guild_emoji(p_guild_id: String, p_emoji_id: String, p_params = {}) -> Emoji:
#	if typeof(p_params) == TYPE_DICTIONARY:
#		p_params = ModifyGuildEmojiParams.new().from_dict(p_params)
#	elif not p_params is ModifyGuildEmojiParams:
#		DiscordUtils.perror("DiscordRESTClient:modify_guild_emoji:params must be a Dictionary or ModifyGuildEmojiParams")
#	var data = yield(_send_patch_request(ENDPOINTS.GUILD_EMOJI % [p_guild_id, p_emoji_id], p_params.to_dict()), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	return Emoji.new().from_dict(data)
#
#
## Delete an existing emoji in a guild
##
## Needs the `MANAGE_EMOJIS_AND_STICKERS` permission
## @returns [bool] | [HTTPResponse] if error
#func delete_guild_emoji(p_guild_id: String, p_emoji_id: String) -> bool:
#	var data = yield(_send_delete_request(ENDPOINTS.GUILD_EMOJI % [p_guild_id, p_emoji_id]), "completed")
#	if data is HTTPResponse:
#		if data.is_error():
#			return data
#		return data.is_no_content()
#	return false
#
#
##! ----------
##! Guild
##! ----------
#
#
## Get a guild with given id
##
## If `with_counts` is set to true, this method will also return `approximate_member_count` and `approximate_presence_count` for the guild
## @returns [Guild] | [HTTPResponse] if error
#func get_guild(p_guild_id: String, p_with_counts = false) -> Guild:
#	var endpoint = ENDPOINTS.GUILD % p_guild_id
#	if p_with_counts == true:
#		var query_string = DiscordUtils.query_string_from_dict({with_counts = true})
#		if query_string: endpoint += "?" + query_string
#
#	var data = yield(_send_request(endpoint), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	return Guild.new().from_dict(data)
#
#
## Get a guild preview for the guild with given id
##
## If the user is not in the guild, then the guild must be lurkable
## @returns [Guild] | [HTTPResponse] if error
#func get_guild_preview(p_guild_id: String) -> GuildPreview:
#	var data = yield(_send_request(ENDPOINTS.GUILD_PREVIEW % p_guild_id), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	return GuildPreview.new().from_dict(data)
#
#
## Create a new guild
##
## Can be used only by bots in less than 10 guilds
## @returns [Guild] | [HTTPResponse] if error
#func create_guild(p_params = {}) -> Guild:
#	if typeof(p_params) == TYPE_DICTIONARY:
#		p_params = CreateGuildParams.new().from_dict(p_params)
#	elif not p_params is CreateGuildParams:
#		DiscordUtils.perror("DiscordRESTClient:create_guild:params must be a Dictionary or CreateGuildParams")
#	var data = yield(_send_post_request(ENDPOINTS.GUILDS, p_params.to_dict()), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	return Guild.new().from_dict(data)
#
#
## Modify a guild's settings
##
## Needs the `MANAGE_GUILD` permission. Attempting to add or remove the `COMMUNITY` guild feature needs the `ADMINISTRATOR` permission
## @returns [Guild] | [HTTPResponse] if error
#func modify_guild(p_guild_id: String, p_params = {}) -> Guild:
#	if typeof(p_params) == TYPE_DICTIONARY:
#		p_params = ModifyGuildParams.new().from_dict(p_params)
#	elif not p_params is ModifyGuildParams:
#		DiscordUtils.perror("DiscordRESTClient:modify_guild:params must be a Dictionary or ModifyGuildParams")
#	var data = yield(_send_patch_request(ENDPOINTS.GUILD % p_guild_id, p_params.to_dict()), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	return Guild.new().from_dict(data)
#
#
## Deletes a guild permanently
##
## Current user must be owner
## @returns [bool] | [HTTPResponse] if error
#func delete_guild(p_guild_id: String) -> bool:
#	var data = yield(_send_delete_request(ENDPOINTS.GUILD % p_guild_id), "completed")
#	if data is HTTPResponse:
#		if data.is_error():
#			return data
#		return data.is_no_content()
#	return false
#
#
## Get a list of guild channels. Does not include threads
##
## @returns [Array] of [Channel] | [HTTPResponse] if error
#func get_guild_channels(p_guild_id: String) -> Array:
#	var data = yield(_send_request(ENDPOINTS.GUILD_CHANNELS % p_guild_id), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	var ret = []
#	for elm in data:
#		ret.append(Channel.new().from_dict(elm))
#	return ret
#
#
## Create a new channel in a guild
##
## Needs the `MANAGE_CHANNELS` permission. If setting permission overwrites, only permissions your bot has in the guild can be allowed/denied. Setting `MANAGE_ROLES` permission in channels is only possible for guild administrators
## @returns [Channel] | [HTTPResponse] if error
#func create_guild_channel(p_guild_id: String, p_params = {}) -> Channel:
#	if typeof(p_params) == TYPE_DICTIONARY:
#		p_params = CreateGuildChannelParams.new().from_dict(p_params)
#	elif not p_params is CreateGuildChannelParams:
#		DiscordUtils.perror("DiscordRESTClient:create_guild_channel:params must be a Dictionary or CreateGuildChannelParams")
#	var data = yield(_send_post_request(ENDPOINTS.GUILD_CHANNELS % p_guild_id, p_params.to_dict()), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	return Channel.new().from_dict(data)
#
#
## Modify the settings for a set of channels in a guild
##
## Needs the `MANAGE_CHANNELS` permission
## @returns [bool] | [HTTPResponse] if error
#func modify_guild_channels(p_guild_id: String, p_params = {}) -> bool:
#	if typeof(p_params) == TYPE_DICTIONARY:
#		p_params = ModifyGuildChannelsParams.new().from_dict(p_params)
#	elif not p_params is ModifyGuildChannelsParams:
#		DiscordUtils.perror("DiscordRESTClient:modify_guild_channels:params must be a Dictionary or ModifyGuildChannelsParams")
#	var data = yield(_send_patch_request(ENDPOINTS.GUILD_CHANNELS % p_guild_id, p_params.to_dict().modifications), "completed")
#	if data is HTTPResponse:
#		if data.is_error():
#			return data
#		return data.is_no_content()
#	return false
#
#
## Get a list of active threads in a guild, including private and public threads
##
## Threads are ordered by their `id` in descending order
## @returns [GetActiveGuildThreadsResponse] | [HTTPResponse] if error
#func get_active_guild_threads(p_guild_id: String) -> Array:
#	var data = yield(_send_request(ENDPOINTS.GUILD_THREADS_ACTIVE % p_guild_id), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	return GetActiveGuildThreadsResponse.new().from_dict(data)
#
#
## Get a list of members in a guild
##
## Needs the `GUILD_MEMBERS` privileged intent
## @returns [Array] of [GuildMember] | [HTTPResponse] if error
#func get_guild_members(p_guild_id: String, p_params = {}) -> Array:
#	if typeof(p_params) == TYPE_DICTIONARY:
#		p_params = GetGuildMembersParams.new().from_dict(p_params)
#	elif not p_params is GetGuildMembersParams:
#		DiscordUtils.perror("DiscordRESTClient:get_guild_members:params must be a Dictionary or GetGuildMembersParams")
#
#	var endpoint = ENDPOINTS.GUILD_MEMBERS % p_guild_id
#	var query_string = DiscordUtils.query_string_from_dict(p_params.to_dict())
#	if query_string: endpoint += "?" + query_string
#
#	var data = yield(_send_request(endpoint), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	var ret = []
#	for elm in data:
#		ret.append(GuildMember.new().from_dict(elm))
#	return ret
#
#
## Get a guild member for a specific user in a guild
##
## @returns [GuildMember] | [HTTPResponse] if error
#func get_guild_member(p_guild_id: String, p_user_id: String) -> GuildMember:
#	var data = yield(_send_request(ENDPOINTS.GUILD_MEMBER % [p_guild_id, p_user_id]), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	return GuildMember.new().from_dict(data)
#
#
## Get a list of guild members whose username or nickname starts with a provided string
##
## @returns [Array] of [GuildMember] | [HTTPResponse] if error
#func search_guild_members(p_guild_id: String, p_params = {}) -> Array:
#	if typeof(p_params) == TYPE_DICTIONARY:
#		p_params = SearchGuildMembersParams.new().from_dict(p_params)
#	elif not p_params is SearchGuildMembersParams:
#		DiscordUtils.perror("DiscordRESTClient:search_guild_members:params must be a Dictionary or SearchGuildMembersParams")
#
#	var endpoint = ENDPOINTS.GUILD_MEMBERS_SEARCH % p_guild_id
#	var query_string = DiscordUtils.query_string_from_dict(p_params.to_dict())
#	if query_string: endpoint += "?" + query_string
#
#	var data = yield(_send_request(endpoint), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#
#	var ret = []
#	for elm in data:
#		ret.append(GuildMember.new().from_dict(elm))
#	return ret
#
#
## Adds a user to a guild
##
## Needs a valid OAuth2 access token for the user with the `guilds.join` scope. The bot must belong to the same application user for authorization and the bot must be a member of the guild with `CREATE_INSTANT_INVITE` permission
##
## For guilds with Membership Screening enabled, this will default to adding new members as pending in the [GuildMember]. Members that are pending will have to complete membership screening before they become full members that can talk
## @returns [GuildMember] | [HTTPResponse] if error
#func add_guild_member(p_guild_id: String, p_user_id: String, p_params = {}) -> GuildMember:
#	if typeof(p_params) == TYPE_DICTIONARY:
#		p_params = AddGuildMemberParams.new().from_dict(p_params)
#	elif not p_params is AddGuildMemberParams:
#		DiscordUtils.perror("DiscordRESTClient:add_guild_member:params must be a Dictionary or AddGuildMemberParams")
#
#	var data = yield(_send_put_request(ENDPOINTS.GUILD_MEMBER % [p_guild_id, p_user_id], p_params.to_dict()), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	return GuildMember.new().from_dict(data)
#
#
## Modify attributes of a guild member
##
## If the `channel_id` is set to null, this will force the target user to be disconnected from voice
##
## When moving members to channels, the current user must have permissions to both connect to the channel and have the `MOVE_MEMBERS` permission
## @returns [GuildMember] | [HTTPResponse] if error
#func modify_guild_member(p_guild_id: String, p_user_id: String, p_params = {}) -> GuildMember:
#	if typeof(p_params) == TYPE_DICTIONARY:
#		p_params = ModifyGuildMemberParams.new().from_dict(p_params)
#	elif not p_params is ModifyGuildMemberParams:
#		DiscordUtils.perror("DiscordRESTClient:modify_guild_member:params must be a Dictionary or ModifyGuildMemberParams")
#
#	var data = yield(_send_patch_request(ENDPOINTS.GUILD_MEMBER % [p_guild_id, p_user_id], p_params.to_dict()), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	return GuildMember.new().from_dict(data)
#
#
## Modify the current member in a guild
##
## Needs `CHANGE_NICKNAME` permission
## @returns [GuildMember] | [HTTPResponse] if error
#func modify_current_member(p_guild_id: String, p_nick = null) -> GuildMember:
#	var data = yield(_send_patch_request(ENDPOINTS.GUILD_MEMBERS_ME % p_guild_id, {nick = p_nick}), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	return GuildMember.new().from_dict(data)
#
#
## Removes member from a guild
##
## Needs `KICK_MEMBERS` permission
## @returns [bool] | [HTTPResponse] if error
#func remove_guild_member(p_guild_id: String, p_user_id: String) -> bool:
#	var data = yield(_send_delete_request(ENDPOINTS.GUILD_MEMBER % [p_guild_id, p_user_id]), "completed")
#	if data is HTTPResponse:
#		if data.is_error():
#			return data
#		return data.is_no_content()
#	return false
#
#
## Adds a role to a guild member
##
## Needs `MANAGE_ROLES` permission
## @returns [bool] | [HTTPResponse] if error
#func add_guild_member_role(p_guild_id: String, p_user_id: String, p_role_id: String) -> bool:
#	var data = yield(_send_put_request(ENDPOINTS.GUILD_MEMBER_ROLE % [p_guild_id, p_user_id, p_role_id]), "completed")
#	if data is HTTPResponse:
#		if data.is_error():
#			return data
#		return data.is_no_content()
#	return false
#
#
## Removes a role to a guild member
##
## Needs `MANAGE_ROLES` permission
## @returns [bool] | [HTTPResponse] if error
#func remove_guild_member_role(p_guild_id: String, p_user_id: String, p_role_id: String) -> bool:
#	var data = yield(_send_delete_request(ENDPOINTS.GUILD_MEMBER_ROLE % [p_guild_id, p_user_id, p_role_id]), "completed")
#	if data is HTTPResponse:
#		if data.is_error():
#			return data
#		return data.is_no_content()
#	return false
#
#
## Get a list of bans in a guild
##
## Needs `BAN_MEMBERS` permission
## @returns [Array] of [GuildBan] | [HTTPResponse] if error
#func get_guild_bans(p_guild_id: String, p_params = {}) -> Array:
#	if typeof(p_params) == TYPE_DICTIONARY:
#		p_params = GetGuildBansParams.new().from_dict(p_params)
#	elif not p_params is GetGuildBansParams:
#		DiscordUtils.perror("DiscordRESTClient:get_guild_bans:params must be a Dictionary or GetGuildBansParams")
#
#	var endpoint = ENDPOINTS.GUILD_BANS % p_guild_id
#	var query_string = DiscordUtils.query_string_from_dict(p_params.to_dict())
#	if query_string: endpoint += "?" + query_string
#
#	var data = yield(_send_request(endpoint), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	var ret = []
#	for elm in data:
#		ret.append(GuildBan.new().from_dict(elm))
#	return ret
#
#
## Get a guild ban for the given user or a 404 [HTTPResponse] if the ban cannot be found.
##
## Needs `BAN_MEMBERS` permission
## @returns [GuildBan] | [HTTPResponse] if error
#func get_guild_ban(p_guild_id: String, p_user_id: String) -> GuildBan:
#	var data = yield(_send_request(ENDPOINTS.GUILD_BAN % [p_guild_id, p_user_id]), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	return GuildBan.new().from_dict(data)
#
#
## Create a guild ban, and optionally delete previous messages sent by the banned user
##
## Needs `BAN_MEMBERS` permission
## @returns [bool] | [HTTPResponse] if error
#func create_guild_ban(p_guild_id: String, p_user_id: String, p_params = {}) -> bool:
#	if typeof(p_params) == TYPE_DICTIONARY:
#		p_params = CreateGuildBanParams.new().from_dict(p_params)
#	elif not p_params is CreateGuildBanParams:
#		DiscordUtils.perror("DiscordRESTClient:create_guild_ban:params must be a Dictionary or CreateGuildBanParams")
#
#	var data = yield(_send_put_request(ENDPOINTS.GUILD_BAN % [p_guild_id, p_user_id], p_params.to_dict()), "completed")
#	if data is HTTPResponse:
#		if data.is_error():
#			return data
#		return data.is_no_content()
#	return false
#
#
## Remove the ban for a user
##
## Needs `BAN_MEMBERS` permission
## @returns [bool] | [HTTPResponse] if error
#func remove_guild_ban(p_guild_id: String, p_user_id: String) -> bool:
#	var data = yield(_send_delete_request(ENDPOINTS.GUILD_BAN % [p_guild_id, p_user_id]), "completed")
#	if data is HTTPResponse:
#		if data.is_error():
#			return data
#		return data.is_no_content()
#	return false
#
#
## Get a list of roles for a guild
##
## @returns [Array] of [Role] | [HTTPResponse] if error
#func get_guild_roles(p_guild_id: String) -> Array:
#	var data = yield(_send_request(ENDPOINTS.GUILD_ROLES % p_guild_id), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	var ret = []
#	for elm in data:
#		ret.append(Role.new().from_dict(elm))
#	return ret
#
#
## Create a new role for the guild
##
## Needs the `MANAGE_ROLES` permission
## @returns [Role] | [HTTPResponse] if error
#func create_guild_role(p_guild_id: String, p_params = {}) -> Role:
#	if typeof(p_params) == TYPE_DICTIONARY:
#		p_params = CreateGuildRoleParams.new().from_dict(p_params)
#	elif not p_params is CreateGuildRoleParams:
#		DiscordUtils.perror("DiscordRESTClient:create_guild_role:params must be a Dictionary or CreateGuildRoleParams")
#
#	var data = yield(_send_post_request(ENDPOINTS.GUILD_ROLES % p_guild_id, p_params.to_dict()), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	return Role.new().from_dict(data)
#
#
## Modify the settings for a set of roles in a guild
##
## Needs the `MANAGE_ROLES` permission
## @returns [Array] of [Role] | [HTTPResponse] if error
#func modify_guild_roles(p_guild_id: String, p_params = {}) -> Array:
#	if typeof(p_params) == TYPE_DICTIONARY:
#		p_params = ModifyGuildRolesParams.new().from_dict(p_params)
#	elif not p_params is ModifyGuildRolesParams:
#		DiscordUtils.perror("DiscordRESTClient:modify_guild_roles:params must be a Dictionary or ModifyGuildRolesParams")
#
#	var data = yield(_send_patch_request(ENDPOINTS.GUILD_ROLES % p_guild_id, p_params.to_dict().modifications), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	var ret = []
#	for elm in data:
#		ret.append(Role.new().from_dict(elm))
#	return ret
#
#
## Modify a guild role
##
## Needs the `MANAGE_ROLES` permission
## @returns [Role] | [HTTPResponse] if error
#func modify_guild_role(p_guild_id: String, p_role_id: String, p_params = {}) -> Role:
#	if typeof(p_params) == TYPE_DICTIONARY:
#		p_params = ModifyGuildRoleParams.new().from_dict(p_params)
#	elif not p_params is ModifyGuildRoleParams:
#		DiscordUtils.perror("DiscordRESTClient:modify_guild_role:params must be a Dictionary or ModifyGuildRoleParams")
#
#	var data = yield(_send_patch_request(ENDPOINTS.GUILD_ROLE % [p_guild_id, p_role_id], p_params.to_dict()), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	return Role.new().from_dict(data)
#
#
## Delete a guild role
##
## Needs the `MANAGE_ROLES` permission
## @returns [Role] | [HTTPResponse] if error
#func delete_guild_role(p_guild_id: String, p_role_id: String) -> bool:
#	var data = yield(_send_delete_request(ENDPOINTS.GUILD_ROLE % [p_guild_id, p_role_id]), "completed")
#	if data is HTTPResponse:
#		if data.is_error():
#			return data
#		return data.is_no_content()
#	return false
#
#
## Modify a guild's MFA level. Needs guild ownership
##
## @returns [MFALevel] | [HTTPResponse] if error
#func modify_guild_mfa_level(p_guild_id: String, p_level: int) -> int:
#	var data = yield(_send_post_request(ENDPOINTS.GUILD_MFA % p_guild_id, {level = p_level}), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	return data
#
#
## Get the number of members that would be removed in a prune operation
##
## Needs the `KICK_MEMBERS` permission
## @returns [int] | [HTTPResponse] if error
#func get_guild_prune_count(p_guild_id: String, p_params = {}) -> int:
#	if typeof(p_params) == TYPE_DICTIONARY:
#		p_params = GetGuildPruneCountParams.new().from_dict(p_params)
#	elif not p_params is GetGuildPruneCountParams:
#		DiscordUtils.perror("DiscordRESTClient:get_guild_prune_count:params must be a Dictionary or GetGuildPruneCountParams")
#
#	var endpoint = ENDPOINTS.GUILD_PRUNE % p_guild_id
#	var query_string = DiscordUtils.query_string_from_dict(p_params.to_dict())
#	if query_string: endpoint += "?" + query_string
#
#	var data = yield(_send_request(endpoint), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	return data.pruned
#
#
## Begin a prune operation on the guild
##
## Needs the `KICK_MEMBERS` permission
##
## For large guilds it's recommended to set the `compute_prune_count` option to false, thus returning null
## @returns [int] | [HTTPResponse] if error
#func begin_guild_prune(p_guild_id: String, p_params = {}) -> int:
#	if typeof(p_params) == TYPE_DICTIONARY:
#		p_params = BeginGuildPruneParams.new().from_dict(p_params)
#	elif not p_params is BeginGuildPruneParams:
#		DiscordUtils.perror("DiscordRESTClient:begin_guild_prune:params must be a Dictionary or BeginGuildPruneParams")
#
#	var data = yield(_send_post_request(ENDPOINTS.GUILD_PRUNE % p_guild_id, p_params.to_dict()), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	return data.pruned
#
#
## Get a list of voice regions for the guild
##
## @returns [Array] of [VoiceRegion] | [HTTPResponse] if error
#func get_guild_voice_regions(p_guild_id: String) -> Array:
#	var data = yield(_send_request(ENDPOINTS.GUILD_REGIONS % p_guild_id), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	var ret = []
#	for elm in data:
#		ret.append(VoiceRegion.new().from_dict(elm))
#	return ret
#
#
## Get a list of invites for the guild
##
## Needs the `MANAGE_GUILD` permission
## @returns [Array] of [Invite] | [HTTPResponse] if error
#func get_guild_invites(p_guild_id: String) -> Array:
#	var data = yield(_send_request(ENDPOINTS.GUILD_INVITES % p_guild_id), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	var ret = []
#	for elm in data:
#		ret.append(Invite.new().from_dict(elm))
#	return ret
#
#
## Get a list of integrations for the guild
##
## Needs the `MANAGE_GUILD` permission
## @returns [Array] of [Integration] | [HTTPResponse] if error
#func get_guild_integrations(p_guild_id: String) -> Array:
#	var data = yield(_send_request(ENDPOINTS.GUILD_INTEGRATIONS % p_guild_id), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	var ret = []
#	for elm in data:
#		ret.append(Integration.new().from_dict(elm))
#	return ret
#
#
## Delete an integration for the guild. Alse deletes any associated webhooks and kicks the associated bot if there is one.
##
## Needs the `MANAGE_GUILD` permission
## @returns [bol] | [HTTPResponse] if error
#func delete_guild_integration(p_guild_id: String, p_integration_id: String) -> bool:
#	var data = yield(_send_delete_request(ENDPOINTS.GUILD_INTEGRATION % [p_guild_id, p_integration_id]), "completed")
#	if data is HTTPResponse:
#		if data.is_error():
#			return data
#		return data.is_no_content()
#	return false
#
#
## Get the settings for the guild widget
##
## Needs the `MANAGE_GUILD` permission
## @returns [GuildWidgetSettings] | [HTTPResponse] if error
#func get_guild_widget_settings(p_guild_id: String) -> GuildWidgetSettings:
#	var data = yield(_send_request(ENDPOINTS.GUILD_WIDGET_SETTINGS % p_guild_id), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	return GuildWidgetSettings.new().from_dict(data)
#
#
## Get the widget for a guild
## @returns [GuildWidget] | [HTTPResponse] if error
#func get_guild_widget(p_guild_id: String) -> GuildWidget:
#	var data = yield(_send_request(ENDPOINTS.GUILD_WIDGET % p_guild_id), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	return GuildWidget.new().from_dict(data)
#
#
## Get the PNG image widget for a guild
## @param p_style - [GuildWidgetStyles]
## @returns [Image] | [HTTPResponse] if error
#func get_guild_widget_image(p_guild_id: String, p_style = "") -> Image:
#	var endpoint = ENDPOINTS.GUILD_WIDGET_IMAGE % p_guild_id
#	var query_string = DiscordUtils.query_string_from_dict({style = p_style})
#	if query_string: endpoint += "?" + query_string
#
#	var data = yield(_send_request(endpoint), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#
#	var image = Image.new()
#	image.load_png_from_buffer(data)
#	return image
#
#
## Modify the widget settings for a guild
##
## Needs the `MANAGE_GUILD` permission
## @returns [GuildWidgetSettings] | [HTTPResponse] if error
#func modify_guild_widget(p_guild_id: String, p_params = {}) -> GuildWidgetSettings:
#	if typeof(p_params) == TYPE_DICTIONARY:
#		p_params = GuildWidgetSettings.new().from_dict(p_params)
#	elif not p_params is GuildWidgetSettings:
#		DiscordUtils.perror("DiscordRESTClient:modify_guild_widget:params must be a Dictionary or GuildWidgetSettings")
#
#	var data = yield(_send_patch_request(ENDPOINTS.GUILD_WIDGET_SETTINGS % p_guild_id, p_params.to_dict()), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	return GuildWidgetSettings.new().from_dict(data)
#
#
## Get a partial invite for guilds with the `VANITY_URL` feature enable
##
## Needs the `MANAGE_GUILD`
##
## `code` will be null if a vanity url for the guild is not set.
## @returns [Invite] | [HTTPResponse] if error
#func get_guild_vanity_url(p_guild_id: String) -> Invite:
#	var data = yield(_send_request(ENDPOINTS.GUILD_VANITYURL % p_guild_id), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	return Invite.new().from_dict(data)
#
#
## Get the welcome screen of a guild
##
## If the welcome screen is not enabled, the `MANAGE_GUILD` permission is required
## @returns [WelcomeScreen] | [HTTPResponse] if error
#func get_guild_welcome_screen(p_guild_id: String) -> WelcomeScreen:
#	var data = yield(_send_request(ENDPOINTS.GUILD_WELCOMESCREEN % p_guild_id), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#
#	return WelcomeScreen.new().from_dict(data)
#
#
## Modify the welcome screen for a guild
##
## Needs the `MANAGE_GUILD` permission
## @returns [WelcomeScreen] | [HTTPResponse] if error
#func modify_guild_welcome_screen(p_guild_id: String, p_params = {}) -> WelcomeScreen:
#	if typeof(p_params) == TYPE_DICTIONARY:
#		p_params = ModifyGuildWelcomeScreenParams.new().from_dict(p_params)
#	elif not p_params is ModifyGuildWelcomeScreenParams:
#		DiscordUtils.perror("DiscordRESTClient:modify_guild_welcome_screen:params must be a Dictionary or ModifyGuildWelcomeScreenParams")
#
#	var data = yield(_send_patch_request(ENDPOINTS.GUILD_WELCOMESCREEN % p_guild_id, p_params.to_dict()), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	return WelcomeScreen.new().from_dict(data)
#
#
## Modify the current user's voice state
##
## There are currently several caveats for this method:
## - `channel_id` must currently point to a stage channel
## - current user must already have joined `channel_id`
## - You must have the `MUTE_MEMBERS` permission to unsuppress yourself. You can always suppress yourself
## - You must have the `REQUEST_TO_SPEAK` permission to request to speak. You can always clear your own request to speak
## - You are able to set `request_to_speak_timestamp` to any present or future time
## @returns [bool] | [HTTPResponse] if error
#func modify_current_user_voice_state(p_guild_id: String, p_params = {}) -> bool:
#	if typeof(p_params) == TYPE_DICTIONARY:
#		p_params = ModifyCurrentUserVoiceStateParams.new().from_dict(p_params)
#	elif not p_params is ModifyCurrentUserVoiceStateParams:
#		DiscordUtils.perror("DiscordRESTClient:modify_current_user_voice_state:params must be a Dictionary or ModifyCurrentUserVoiceStateParams")
#
#	var data = yield(_send_patch_request(ENDPOINTS.GUILD_VOICESTATES_ME % p_guild_id, p_params.to_dict()), "completed")
#	if data is HTTPResponse:
#		if data.is_error():
#			return data
#		return data.is_no_content()
#	return false
#
#
## Updates another user's voice state
##
## There are currently several caveats for this method:
## - `channel_id` must currently point to a stage channel
## - User must already have joined `channel_id`
## - You must have the `MUTE_MEMBERS` permission (Since suppression is the only thing that is available currently)
## - When unsuppressed, non-bot users will have their `request_to_speak_timestamp` set to the current time. Bot users will not
## - When suppressed, the user will have their `request_to_speak_timestamp` removed
## @returns [bool] | [HTTPResponse] if error
#func modify_user_voice_state(p_guild_id: String, p_user_id: String, p_params = {}) -> bool:
#	if typeof(p_params) == TYPE_DICTIONARY:
#		p_params = ModifyUserVoiceStateParams.new().from_dict(p_params)
#	elif not p_params is ModifyUserVoiceStateParams:
#		DiscordUtils.perror("DiscordRESTClient:modify_user_voice_state:params must be a Dictionary or ModifyUserVoiceStateParams")
#
#	var data = yield(_send_patch_request(ENDPOINTS.GUILD_VOICESTATES_USER % [p_guild_id, p_user_id], p_params.to_dict()), "completed")
#	if data is HTTPResponse:
#		if data.is_error():
#			return data
#		return data.is_no_content()
#	return false
#
#
##! ----------
##! GuildScheduledEvent
##! ----------
#
#
## Get a list of guild scheduled events for the given guild
##
## @returns [Array] of [GuildScheduledEvent] | [HTTPResponse] if error
#func get_guild_scheduled_events(p_guild_id: String, p_with_counts = null) -> Array:
#	var endpoint = ENDPOINTS.GUILD_SCHEDULED_EVENTS % p_guild_id
#	if typeof(p_with_counts) == TYPE_BOOL:
#		var query_string = DiscordUtils.query_string_from_dict({with_counts = p_with_counts})
#		if query_string: endpoint += "?" + query_string
#	var data = yield(_send_request(endpoint), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	var ret = []
#	for elm in data:
#		ret.append(GuildScheduledEvent.new().from_dict(elm))
#	return ret
#
#
## Create a guild scheduled event in the guild
##
## @returns [GuildScheduledEvent] | [HTTPResponse] if error
#func create_guild_scheduled_event(p_guild_id: String, p_params = {}) -> GuildScheduledEvent:
#	if typeof(p_params) == TYPE_DICTIONARY:
#		p_params = CreateGuildScheduledEventParams.new().from_dict(p_params)
#	elif not p_params is CreateGuildScheduledEventParams:
#		DiscordUtils.perror("DiscordRESTClient:create_guild_scheduled_event:params must be a Dictionary or CreateGuildScheduledEventParams")
#
#	var data = yield(_send_post_request(ENDPOINTS.GUILD_SCHEDULED_EVENTS % p_guild_id, p_params.to_dict()), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	return GuildScheduledEvent.new().from_dict(data)
#
#
## Modify an existing guild scheduled event
##
## To start or end an event, use this method to modify the event's `status` field
## @returns [GuildScheduledEvent] | [HTTPResponse] if error
#func modify_guild_scheduled_event(p_guild_id: String, p_event_id: String, p_params = {}) -> GuildScheduledEvent:
#	if typeof(p_params) == TYPE_DICTIONARY:
#		p_params = ModifyGuildScheduledEventParams.new().from_dict(p_params)
#	elif not p_params is ModifyGuildScheduledEventParams:
#		DiscordUtils.perror("DiscordRESTClient:modify_guild_scheduled_event:params must be a Dictionary or ModifyGuildScheduledEventParams")
#
#	var data = yield(_send_patch_request(ENDPOINTS.GUILD_SCHEDULED_EVENT % [p_guild_id, p_event_id], p_params.to_dict()), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	return GuildScheduledEvent.new().from_dict(data)
#
#
## Delete a guild scheduled event
## @returns [bool] | [HTTPResponse] if error
#func delete_guild_scheduled_event(p_guild_id: String, p_event_id: String) -> bool:
#	var data = yield(_send_delete_request(ENDPOINTS.GUILD_SCHEDULED_EVENT % [p_guild_id, p_event_id]), "completed")
#	if data is HTTPResponse:
#		if data.is_error():
#			return data
#		return data.is_no_content()
#	return false
#
#
## Get a list of guild scheduled events for the given guild
##
## @returns [Array] of [GuildScheduledEventUser] | [HTTPResponse] if error
#func get_guild_scheduled_event_users(p_guild_id: String, p_event_id: String, p_params = {}) -> Array:
#	if typeof(p_params) == TYPE_DICTIONARY:
#		p_params = GetGuildScheduledEventUsersParams.new().from_dict(p_params)
#	elif not p_params is GetGuildScheduledEventUsersParams:
#		DiscordUtils.perror("DiscordRESTClient:get_guild_scheduled_event_users:params must be a Dictionary or GetGuildScheduledEventUsersParams")
#
#	var endpoint = ENDPOINTS.GUILD_SCHEDULED_EVENT_USERS % [p_guild_id, p_event_id]
#	var query_string = DiscordUtils.query_string_from_dict(p_params.to_dict())
#	if query_string: endpoint += "?" + query_string
#
#	var data = yield(_send_request(endpoint), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	var ret = []
#	for elm in data:
#		ret.append(GuildScheduledEventUser.new().from_dict(elm))
#	return ret
#
#
##! ----------
##! GuildTemplate
##! ----------
#
#
## Get a list of guild scheduled events for the given guild
## @returns [GuildTemplate] | [HTTPResponse] if error
#func get_guild_template(p_template_code: String) -> GuildTemplate:
#	var data = yield(_send_request(ENDPOINTS.GUILD_TEMPLATES_CODE % p_template_code), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	return GuildTemplate.new().from_dict(data)
#
#
## Get a list of guild scheduled events for the given guild
## @returns [GuildTemplate] | [HTTPResponse] if error
#func create_guild_from_template(p_template_code: String, p_params = {}) -> Guild:
#	if typeof(p_params) == TYPE_DICTIONARY:
#		p_params = CreateGuildFromTemplateParams.new().from_dict(p_params)
#	elif not p_params is CreateGuildFromTemplateParams:
#		DiscordUtils.perror("DiscordRESTClient:create_guild_from_template:params must be a Dictionary or CreateGuildFromTemplateParams")
#
#	var data = yield(_send_post_request(ENDPOINTS.GUILD_TEMPLATES_CODE % p_template_code, p_params.to_dict()), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	return Guild.new().from_dict(data)
#
#
## Creates a template for the guild
##
## Needs the `MANAGE_GUILD` permission
## @returns [GuildTemplate] | [HTTPResponse] if error
#func create_template_from_guild(p_guild_id: String, p_params = {}) -> GuildTemplate:
#	if typeof(p_params) == TYPE_DICTIONARY:
#		p_params = CreateGuildFromTemplateParams.new().from_dict(p_params)
#	elif not p_params is CreateGuildFromTemplateParams:
#		DiscordUtils.perror("DiscordRESTClient:create_template_from_guild:params must be a Dictionary or CreateGuildFromTemplateParams")
#
#	var data = yield(_send_post_request(ENDPOINTS.GUILD_TEMPLATES % p_guild_id, p_params.to_dict()), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	return GuildTemplate.new().from_dict(data)
#
#
## Delete a guild template
## @returns [GuildTemplate] | [HTTPResponse] if error
#func delete_guild_template(p_guild_id: String, p_template_code: String) -> GuildTemplate:
#	var data = yield(_send_delete_request(ENDPOINTS.GUILD_TEMPLATE % [p_guild_id, p_template_code]), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	return GuildTemplate.new().from_dict(data)
#
#
## Syncs a guild template to the guild's current state
## @returns [GuildTemplate] | [HTTPResponse] if error
#func sync_guild_template(p_guild_id: String, p_template_code: String) -> GuildTemplate:
#	var data = yield(_send_put_request(ENDPOINTS.GUILD_TEMPLATE % [p_guild_id, p_template_code]), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	return GuildTemplate.new().from_dict(data)
#
#
## Modify a guild template's metadata
## @returns [GuildTemplate] | [HTTPResponse] if error
#func modify_guild_template(p_guild_id: String, p_template_code: String, p_params = {}) -> GuildTemplate:
#	if typeof(p_params) == TYPE_DICTIONARY:
#		p_params = ModifyGuildTemplateParams.new().from_dict(p_params)
#	elif not p_params is ModifyGuildTemplateParams:
#		DiscordUtils.perror("DiscordRESTClient:modify_guild_template:params must be a Dictionary or ModifyGuildTemplateParams")
#
#	var data = yield(_send_post_request(ENDPOINTS.GUILD_TEMPLATE % [p_guild_id, p_template_code], p_params.to_dict()), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	return GuildTemplate.new().from_dict(data)
#
#
##! ----------
##! Invite
##! ----------
#
#
## Get the invite with given code
## @returns [Invite] | [HTTPResponse] if error
#func get_invite(p_invite_code: String, p_params = {}) -> Invite:
#	if typeof(p_params) == TYPE_DICTIONARY:
#		p_params = GetInviteParams.new().from_dict(p_params)
#	elif not p_params is GetInviteParams:
#		DiscordUtils.perror("DiscordRESTClient:get_invite:params must be a Dictionary or GetInviteParams")
#
#	var endpoint = ENDPOINTS.INVITE % p_invite_code
#	var query_string = DiscordUtils.query_string_from_dict(p_params.to_dict())
#	if query_string: endpoint += "?" + query_string
#
#	var data = yield(_send_request(endpoint), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	return Invite.new().from_dict(data)
#
#
## Get the invite with given code
## @returns [Invite] | [HTTPResponse] if error
#func delete_invite(p_invite_code: String) -> Invite:
#	var data = yield(_send_delete_request(ENDPOINTS.INVITE % p_invite_code), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	return Invite.new().from_dict(data)
#
#
##! ----------
##! StageInstance
##! ----------
#
#
## Creates a new Stage instance associated to a Stage channel
##
## Needs the user to be a moderator of the Stage channel
## @returns [StageInstance] | [HTTPResponse] if error
#func create_stage_instance(p_params = {}) -> Invite:
#	if typeof(p_params) == TYPE_DICTIONARY:
#		p_params = CreateStageInstanceParams.new().from_dict(p_params)
#	elif not p_params is CreateStageInstanceParams:
#		DiscordUtils.perror("DiscordRESTClient:create_stage_instance:params must be a Dictionary or CreateStageInstanceParams")
#
#	var data = yield(_send_post_request(ENDPOINTS.STAGEINSTANCES, p_params.to_dict()), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	return StageInstance.new().from_dict(data)
#
#
## Get the stage instance associated with the Stage channel, if it exists
## @returns [Invite] | [HTTPResponse] if error
#func get_stage_instance(p_channel_id: String) -> StageInstance:
#	var data = yield(_send_request(ENDPOINTS.STAGEINSTANCE % p_channel_id), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	return StageInstance.new().from_dict(data)
#
#
## Updates fields of an existing Stage instance
##
## Needs the user to be a moderator of the Stage channel
## @returns [StageInstance] | [HTTPResponse] if error
#func modify_stage_instance(p_channel_id: String, p_params = {}) -> StageInstance:
#	if typeof(p_params) == TYPE_DICTIONARY:
#		p_params = ModifyStageInstanceParams.new().from_dict(p_params)
#	elif not p_params is ModifyStageInstanceParams:
#		DiscordUtils.perror("DiscordRESTClient:modify_stage_instance:params must be a Dictionary or ModifyStageInstanceParams")
#
#	var data = yield(_send_patch_request(ENDPOINTS.STAGEINSTANCE % p_channel_id, p_params.to_dict()), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	return StageInstance.new().from_dict(data)
#
#
## Deletes a stage instance
##
## Needs the user to be a moderator of the Stage channel
## @returns [bool] | [HTTPResponse] if error
#func delete_stage_instance(p_channel_id: String) -> bool:
#	var data = yield(_send_delete_request(ENDPOINTS.STAGEINSTANCE % p_channel_id), "completed")
#	if data is HTTPResponse:
#		if data.is_error():
#			return data
#		return data.is_no_content()
#	return false
#
#
##! ----------
##! Sticker
##! ----------
#
#
## Get a sticker with given id
## @returns [Invite] | [HTTPResponse] if error
#func get_sticker(p_sticker_id: String) -> Sticker:
#	var data = yield(_send_request(ENDPOINTS.STICKER % p_sticker_id), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	return Sticker.new().from_dict(data)
#
#
## Get a lsit of nitro sticker packs
## @returns [Array] of [StickerPack] | [HTTPResponse] if error
#func get_sticker_packs() -> Array:
#	var data = yield(_send_request(ENDPOINTS.STICKERPACKS), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	var ret = []
#	for elm in data.sticker_packs:
#		ret.append(StickerPack.new().from_dict(elm))
#	return ret
#
#
## Get a list of stickers for the given guild
## @returns [Array] of [Sticker] | [HTTPResponse] if error
#func get_guild_stickers(p_guild_id: String) -> Array:
#	var data = yield(_send_request(ENDPOINTS.GUILD_STICKERS % p_guild_id), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	var ret = []
#	for elm in data:
#		ret.append(Sticker.new().from_dict(elm))
#	return ret
#
#
## Get a sticker for a given sticker in a guild
## @returns [Sticker] | [HTTPResponse] if error
#func get_guild_sticker(p_guild_id: String, p_sticker_id: String) -> Sticker:
#	var data = yield(_send_request(ENDPOINTS.GUILD_STICKER % [p_guild_id, p_sticker_id]), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	return Sticker.new().from_dict(data)
#
#
## Modify the given sticker
##
## Needs the `MANAGE_EMOJIS_AND_STICKERS` permission
## @returns [Sticker] | [HTTPResponse] if error
#func modify_guild_sticker(p_guild_id: String, p_sticker_id: String, p_params = {}) -> Sticker:
#	if typeof(p_params) == TYPE_DICTIONARY:
#		p_params = ModifyGuildStickerParams.new().from_dict(p_params)
#	elif not p_params is ModifyGuildStickerParams:
#		DiscordUtils.perror("DiscordRESTClient:modify_guild_sticker:params must be a Dictionary or ModifyGuildStickerParams")
#	var data = yield(_send_patch_request(ENDPOINTS.GUILD_STICKER % [p_guild_id, p_sticker_id], p_params.to_dict()), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	return Sticker.new().from_dict(data)
#
#
## Delete the given sticker
##
## Needs the `MANAGE_EMOJIS_AND_STICKERS` permission
## @returns [bool] | [HTTPResponse] if error
#func delete_guild_sticker(p_guild_id: String, p_sticker_id: String) -> bool:
#	var data = yield(_send_delete_request(ENDPOINTS.GUILD_STICKER % [p_guild_id, p_sticker_id]), "completed")
#	if data is HTTPResponse:
#		if data.is_error():
#			return data
#		return data.is_no_content()
#	return false
#
#
##! ----------
##! User
##! ----------
#
#
## Get the user of the requester's account
##
## For OAuth2, this requires the `identify` scope, which will return the object without an email, and optionally the `email` scope, which returns the object with an email.
## @returns [User] | [HTTPResponse] if error
#func get_current_user() -> User:
#	var data = yield(_send_request(ENDPOINTS.USER_ME), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	return User.new().from_dict(data)
#
#
## Modify the requester's user account settings
## @returns [User] | [HTTPResponse] if error
#func modify_current_user(p_params = {}) -> User:
#	if typeof(p_params) == TYPE_DICTIONARY:
#		p_params = ModifyCurrentUserParams.new().from_dict(p_params)
#	elif not p_params is ModifyCurrentUserParams:
#		DiscordUtils.perror("DiscordRESTClient:modify_current_user:params must be a Dictionary or ModifyCurrentUserParams")
#
#	var data = yield(_send_patch_request(ENDPOINTS.USER_ME, p_params.to_dict()), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	return User.new().from_dict(data)
#
#
## Get a user by id
## @returns [User] | [HTTPResponse] if error
#func get_user(p_user_id: String) -> User:
#	var data = yield(_send_request(ENDPOINTS.USER % p_user_id), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	return User.new().from_dict(data)
#
#
## Get a list of partial [Guild] the current user is a member of
##
## Partial guild properties: `id`, `name`, `icon`, `owner`, `permissions`, `features`
##
## This methods returns 200 guilds by default, which is the maximum number of guilds a non-bot user can join
## @returns [Array] of [Guild] | [HTTPResponse] if error
#func get_current_user_guilds(p_params = {}) -> Array:
#	if typeof(p_params) == TYPE_DICTIONARY:
#		p_params = GetCurrentUserGuildsParams.new().from_dict(p_params)
#	elif not p_params is GetCurrentUserGuildsParams:
#		DiscordUtils.perror("DiscordRESTClient:get_current_user_guilds:params must be a Dictionary or GetCurrentUserGuildsParams")
#
#	var endpoint = ENDPOINTS.USER_ME_GUILDS
#	var query_string = DiscordUtils.query_string_from_dict(p_params.to_dict())
#	if query_string: endpoint += "?" + query_string
#
#	var data = yield(_send_request(endpoint), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	var ret = []
#	for elm in data:
#		ret.append(Guild.new().from_dict(elm))
#	return ret
#
#
## Get the guild member for the current user in a guild
##
## Needs the `guilds.members.read` OAuth2 scope
## @returns [User] | [HTTPResponse] if error
#func get_current_guild_member(p_guild_id: String) -> GuildMember:
#	var data = yield(_send_request(ENDPOINTS.USER_ME_GUILD_MEMBER % p_guild_id), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	return GuildMember.new().from_dict(data)
#
#
## Leave a guild.
## @returns [bool] | [HTTPResponse] if error
#func leave_guild(p_guild_id: String) -> bool:
#	var data = yield(_send_delete_request(ENDPOINTS.USER_ME_GUILD % p_guild_id), "completed")
#	if data is HTTPResponse:
#		if data.is_error():
#			return data
#		return data.is_no_content()
#	return false
#
#
## Create a new DM channel with a user
## @returns [Channel] | [HTTPResponse] if error
#func create_dm(p_user_id: String) -> Channel:
#	var data = yield(_send_post_request(ENDPOINTS.USER_ME_CHANNELS, {recipient_id = p_user_id}), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	return Channel.new().from_dict(data)
#
#
## Create a new group DM channel with multiple users
##
## This method is limited to 10 active group DMs. DMs created with this endpoint will not be shown in the Discord client
## @returns [Channel] | [HTTPResponse] if error
#func create_group_dm(p_params = {}) -> Channel:
#	if typeof(p_params) == TYPE_DICTIONARY:
#		p_params = CreateGroupDmParams.new().from_dict(p_params)
#	elif not p_params is CreateGroupDmParams:
#		DiscordUtils.perror("DiscordRESTClient:create_group_dm:params must be a Dictionary or CreateGroupDmParams")
#
#	var data = yield(_send_post_request(ENDPOINTS.USER_ME_CHANNELS, p_params.to_dict()), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	return Channel.new().from_dict(data)
#
#
## Get a list of the user's connection
##
## Needs the `connections` OAuth2 scope
## @returns [Array] of [UserConnection] | [HTTPResponse] if error
#func get_current_user_connections() -> Array:
#	var data = yield(_send_request(ENDPOINTS.USER_ME_CONNECTIONS), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	var ret = []
#	for elm in data:
#		ret.append(UserConnection.new().from_dict(elm))
#	return ret
#
#
##! ----------
##! Voice
##! ----------
#
#
## Get a list of of [VoiceRegion] that can be used when setting a voice or stage channel's `rtc_region`
## @returns [Array] of [VoiceRegion] | [HTTPResponse] if error
#func get_voice_regions() -> Array:
#	var data = yield(_send_request(ENDPOINTS.VOICE_REGIONS), "completed")
#	if data is HTTPResponse and data.is_error():
#		return data
#	var ret = []
#	for elm in data:
#		ret.append(VoiceRegion.new().from_dict(elm))
#	return ret


# @hidden
const ENDPOINTS: Dictionary = {
	# AuditLog
	GUILD_AUDIT_LOGS = "/guilds/%s/audit-logs",

	# AutoModeration
	GUILD_AUTO_MODERATION_RULES = "/guilds/%s/auto-moderation/rules",
	GUILD_AUTO_MODERATION_RULE = "/guilds/%s/auto-moderation/rules/%s",

	# Channel
	CHANNEL = "/channels/%s",
	CHANNEL_MESSAGES = "/channels/%s/messages",
	CHANNEL_MESSAGE = "/channels/%s/messages/%s",
	CHANNEL_MESSAGE_CROSSPOST = "/channels/%s/messages/%s/crosspost",
	CHANNEL_MESSAGES_BULKDELETE = "/channels/%s/messages/bulk-delete",

	REACTIONS = "/channels/%s/messages/%s/reactions",
	REACTIONS_EMOJI = "/channels/%s/messages/%s/reactions/%s",
	REACTIONS_EMOJI_USER = "/channels/%s/messages/%s/reactions/%s/%s",
	REACTIONS_EMOJI_ME = "/channels/%s/messages/%s/reactions/%s/@me",

	CHANNEL_PERMISSIONS = "/channels/%s/permissions/%s",

	CHANNEL_INVITES = "/channels/%s/invites",

	CHANNEL_FOLLOWERS = "/channels/%s/followers",

	CHANNEL_TYPING = "/channels/%s/typing",

	CHANNEL_PINS = "/channels/%s/pins",
	CHANNEL_PIN = "/channels/%s/pins/%s",

	CHANNEL_RECIPIENT = "/channels/%s/recipients/%s",

	CHANNEL_THREADS = "/channels/%s/threads",
	CHANNEL_MESSAGE_THREADS = "/channels/%s/messages/%s/threads",

	CHANNEL_THREADMEMBERS = "/channels/%s/thread-members",
	CHANNEL_THREADMEMBERS_USER = "/channels/%s/thread-members/%s",
	CHANNEL_THREADMEMBERS_ME = "/channels/%s/thread-members/@me",
	CHANNEL_THREADS_ARCHIVED_PUBLIC = "/channels/%s/threads/archived/public",
	CHANNEL_THREADS_ARCHIVED_PRIVATE = "/channels/%s/threads/archived/private",
	CHANNEL_USERS_ME_THREADS_ARCHIVED_PRIVATE = "/channels/%s/users/@me/threads/archived/private",

	# Emoji
	GUILD_EMOJIS = "/guilds/%s/emojis",
	GUILD_EMOJI = "/guilds/%s/emojis/%s",

	# Guild
	GUILDS = "/guilds",
	GUILD = "/guilds/%s",
	GUILD_PREVIEW = "/guilds/%s/preview",

	GUILD_CHANNELS = "/guilds/%s/channels",
	GUILD_THREADS_ACTIVE = "/guilds/%s/threads/active",

	GUILD_MEMBERS = "/guilds/%s/members",
	GUILD_MEMBER = "/guilds/%s/members/%s",
	GUILD_MEMBERS_SEARCH = "/guilds/%s/members/search",
	GUILD_MEMBERS_ME = "/guilds/%s/members/@me",

	GUILD_MEMBER_ROLE = "/guilds/%s/members/%s/roles/%s",

	GUILD_BANS = "/guilds/%s/bans",
	GUILD_BAN = "/guilds/%s/bans/%s",

	GUILD_ROLES = "/guilds/%s/roles",
	GUILD_ROLE = "/guilds/%s/roles/%s",

	GUILD_MFA = "/guilds/%s/mfa",

	GUILD_PRUNE = "/guilds/%s/prune",

	GUILD_REGIONS = "/guilds/%s/regions",

	GUILD_INVITES = "/guilds/%s/invites",

	GUILD_INTEGRATIONS = "/guilds/%s/integrations",
	GUILD_INTEGRATION = "/guilds/%s/integrations/%s",

	GUILD_WIDGET = "/guilds/%s/widget.json",
	GUILD_WIDGET_SETTINGS = "/guilds/%s/widget",
	GUILD_WIDGET_IMAGE = "/guilds/%s/widget.png",

	GUILD_VANITYURL = "/guilds/%s/vanity-url",

	GUILD_WELCOMESCREEN = "/guilds/%s/welcome-screen",

	GUILD_VOICESTATES_USER = "/guilds/%s/voice-states/%s",
	GUILD_VOICESTATES_ME = "/guilds/%s/voice-states/@me",

	# GuildScheduledEvent
	GUILD_SCHEDULED_EVENTS = "/guilds/%s/scheduled-events",
	GUILD_SCHEDULED_EVENT = "/guilds/%s/scheduled-events/%s",
	GUILD_SCHEDULED_EVENT_USERS = "/guilds/%s/scheduled-events/%s/users",

	# GuildTemplate
	GUILD_TEMPLATES_CODE = "/guilds/templates/%s",
	GUILD_TEMPLATES = "/guilds/%s/templates",
	GUILD_TEMPLATE = "/guilds/%s/templates/%s",

	# Invite
	INVITE = "/invites/%s",

	# StageInstance
	STAGEINSTANCES = "/stage-instances",
	STAGEINSTANCE = "/stage-instances/%s",

	# Sticker
	STICKER = "/stickers/%s",
	STICKERPACKS = "/sticker-packs",
	GUILD_STICKERS = "/guilds/%s/stickers",
	GUILD_STICKER = "/guilds/%s/stickers/%s",

	# User
	USERS = "/users/",
	USER = "/users/%s",
	USER_ME = "/users/@me",
	USER_ME_CHANNELS = "/users/@me/channels",
	USER_ME_CONNECTIONS = "/users/@me/connections",
	USER_ME_GUILDS = "/users/@me/guilds",
	USER_ME_GUILD = "/users/@me/guilds/%s",
	USER_ME_GUILD_MEMBER = "/users/@me/guilds/%s/member",

	# Voice
	VOICE_REGIONS = "/voice/regions"
}

var _base_url: String
var _auth_header = ""
var _headers = [
	"User-Agent: DiscordBot (%s %s, Godot:%s)" % [DiscordMetadata.LIBRARY, DiscordMetadata.LIBRARY_URL, Engine.get_version_info().string],
	"Accept: application/json"
]


# @hidden
func _init() -> void:
	pause_mode = PAUSE_MODE_PROCESS
	_base_url = DiscordMetadata.REST_URL % DiscordMetadata.REST_VERSION


# @hidden
func get_class():
	return "DiscordRESTClient"


func _to_string() -> String:
	return "[%s:%d]" % [get_class(), get_instance_id()]


# @hidden
func _send_post_request(slug: String, payload = {}):
	return _send_request(slug, payload, HTTPClient.METHOD_POST)


# @hidden
func _send_patch_request(slug: String, payload = {}):
	return _send_request(slug, payload, HTTPClient.METHOD_PATCH)


# @hidden
func _send_put_request(slug: String, payload = {}):
	return _send_request(slug, payload, HTTPClient.METHOD_PUT)


# @hidden
func _send_delete_request(slug: String, payload = null):
	return _send_request(slug, payload, HTTPClient.METHOD_DELETE)


# @hidden
func _send_request(slug: String, payload = null, method := HTTPClient.METHOD_GET) -> HTTPResponse:
	var headers = _headers.duplicate(true)

	if not _auth_header == "":
		headers.append(_auth_header)

	var http_request = HTTPRequest.new()
	add_child(http_request)

	var request_string = ""
	if payload != null:
		headers.append("Content-Type: application/json")
		request_string = JSON.print(payload)

	http_request.call_deferred("request", _base_url + slug, headers, true, method, request_string)

	var data = yield(http_request, "request_completed")
	http_request.queue_free()

	# Check for errors
	var res := HTTPResponse.new(data[0], data[1], data[2], data[3])

	if res.is_error() or res.is_no_content():
		# Got some error or 204
		return res

	var content_type = null
	for header in res.headers:
		header = header as String
		if header.begins_with("Content-Type: "):
			content_type = header.substr(14)
			break
	match content_type:
		"application/json":
			var json = res.get_json()
			return json
		"image/png", "image/jpg", "image/gif":
			return res.body
		_:
			return res


# @hidden
func _send_multipart_form_request(slug: String, form_dict = {}, method := HTTPClient.METHOD_POST) -> HTTPResponse:
	var headers = _headers.duplicate(true)

	if not _auth_header == "":
		headers.append(_auth_header)

	headers.append("Content-Type: multipart/form-data; boundary=\"xx__boundary__xx\"")

	var http_request = HTTPRequest.new()
	add_child(http_request)

	var body = PoolByteArray()

	var _file_count = 0
	if form_dict.has("files") and typeof(form_dict.files) == TYPE_ARRAY:
		for file in form_dict.files:
			if not file is DiscordFile:
				DiscordUtils.perror("DiscordRESTClient:_send_multipart_form_request:Invalid file in files. Expected DiscordFile but got: %s" % file)
			body.append_array("--xx__boundary__xx\r\n".to_utf8())
			body.append_array(
				("Content-Disposition: form-data; name=\"files[%s]\"; filename=\"%s\"\r\n" % [_file_count, file.filename]).to_utf8()
			)
			body.append_array(("Content-Type: %s\r\n\r\n" % file.content_type).to_utf8())
			body.append_array(file.contents)
			body.append_array("\r\n".to_utf8())
			_file_count += 1
		form_dict.erase("files")

	var form_field_names = form_dict.keys()
	for field_name in form_field_names:
		var field_value = form_dict[field_name]
		if typeof(field_value) == TYPE_DICTIONARY:
			body.append_array("--xx__boundary__xx\r\n".to_utf8())
			body.append_array(("Content-Disposition: form-data; name=\"%s\"\r\n" % field_name).to_utf8())
			body.append_array("Content-Type: application/json\r\n\r\n".to_utf8())

			body.append_array((JSON.print(field_value) + "\r\n").to_utf8())
		else:
			DiscordUtils.perror("DiscordRESTClient:_send_multipart_form_request:Invalid form field type: %s for field: %s" % [typeof(field_value), field_name])
	body.append_array("--xx__boundary__xx--\r\n".to_utf8())

	http_request.call_deferred("request_raw", _base_url + slug, headers, true, method, body)

	var data = yield(http_request, "request_completed")
	http_request.queue_free()

	# Check for errors
	var res := HTTPResponse.new(data[0], data[1], data[2], data[3])

	if res.is_error() or res.is_no_content():
		# Got some error or 204
		return res

	var content_type = null
	for header in res.headers:
		header = header as String
		if header.begins_with("Content-Type: "):
			content_type = header.substr(14)
			break
	match content_type:
		"application/json":
			var json = res.get_json()
			return json
		"image/png", "image/jpg", "image/gif":
			return res.body
		_:
			return res


# Extracts non [DiscordFile] data from a dictionary to `payload_json`.
func _parse_files_from_dict(p_dict: Dictionary) -> Dictionary:
	var form_dict = {}
	if p_dict.has("files") and typeof(p_dict.files) == TYPE_ARRAY:
		var files = p_dict.files
		p_dict.erase("files")
		form_dict.files = files
	form_dict.payload_json = p_dict
	return form_dict
