extends Control

# Testing new stuff (Nothing much here)
var rest: DiscordRESTClient

onready var logs = $VB/MC/Logs


func _ready() -> void:
	_on_rerun_btn_pressed()
	# warning-ignore:return_value_discarded
	$VB/RerunBtn.connect("pressed", self, "_on_rerun_btn_pressed")


func Print(var1, var2 = null, var3 = null):
	var s = str(var1)
	if var2 != null: s += str(var2)
	if var3 != null: s += str(var3)
	logs.text += s + "\n"
	print(s)


func _on_rerun_btn_pressed() -> void:
	Print("\n---------------\nRunning\n---------------\n")
#	rest = DiscordRESTClient.new()
#	add_child(rest)
#	rest.set_token(Env.get_var("TOKEN"))

#	var params_get_auditlog = GetGuildAuditLogParams.new()
#	params_get_auditlog.user_id = "321233875776962560"
#	params_get_auditlog.before = "993759739852886046"
#	params_get_auditlog.limit = 2
#	Print(yield(rest.get_guild_audit_log("369422519129604096", params_get_auditlog), "completed"))



#	Print(yield(rest.get_guild_auto_moderation_rules("330264450148073474"), "completed"))
#	Print(yield(rest.get_guild_auto_moderation_rule("330264450148073474", "987209742638268477"), "completed"))

#	# Missing Access
#	var params_create_automod = CreateGuildAutoModerationRuleParams.new()
#	params_create_automod.name = "Test Rule 01"
#	params_create_automod.trigger_type = AutoModerationTriggerTypes.SPAM
#	params_create_automod.actions = [AutoModerationAction.new().from_dict({type = AutoModerationActionTypes.BLOCK_MESSAGE})]
#	Print(params_create_automod)
#	Print(params_create_automod.to_dict())
#	Print(params_create_automod)
#	Print(yield(rest.create_guild_auto_moderation_rule("330264450148073474", params_create_automod), "completed"))

#	var params_modify_automod = ModifyGuildAutoModerationRuleParams.new()
#	params_modify_automod.name = "Custom Keyword Rule"
#	Print(yield(rest.modify_guild_auto_moderation_rule("330264450148073474", "993799349773541427", params_modify_automod), "completed"))

#	Print(yield(rest.delete_guild_auto_moderation_rule("330264450148073474", "993834186785968240"), "completed"))



#	Print(yield(rest.get_channel("330264450148073474"), "completed")) # GUILD_TEXT
#	Print(yield(rest.get_channel("787562894509211659"), "completed")) # GUILD_CATEGORY
#	Print(yield(rest.get_channel("330264450148073475"), "completed")) # GUILD_VOICE
#	Print(yield(rest.get_channel("870140096307933215"), "completed")) # GUILD_PUBLIC_THREAD
#	Print(yield(rest.get_channel("528466374104842270"), "completed")) # GUILD_NEWS
#	Print(yield(rest.get_channel("993847090595766292"), "completed")) # GUILD_STAGE_VOICE

#	var params_modify_channel = ModifyChannelParams.new()
#	params_modify_channel.position = 3
#	params_modify_channel.name = "edited channel name"
#	Print(yield(rest.modify_channel("993851377652609065", params_modify_channel), "completed"))

#	Print(yield(rest.delete_channel("993851377652609065"), "completed"))

#	Print(yield(rest.get_channel_messages("330264450148073474", {limit = 5}), "completed"))
#	Print(yield(rest.get_channel_message("373108000900251650", "994289865455829102"), "completed")) # With components
#	Print(yield(rest.get_channel_message("453816730284851201", "994295386657259621"), "completed")) # With stickers
#	var params_create_message = CreateMessageParams.new()
#	params_create_message.content = "hey @here"
#	var embed = Embed.new().from_dict({title = "Embed Title", description = "Embed Description"})
#	embed.fields = [EmbedField.new().from_dict({ name = "Field 1", value = "Value 1"}),
#					EmbedField.new().from_dict({ name = "Field 2", value = "Value 2", inline = true}),
#					EmbedField.new().from_dict({ name = "Field 3", value = "Value 3", inline = true})]
#	params_create_message.embeds = [embed]
#	Print(yield(rest.create_message("369423865618628608", params_create_message), "completed"))

#	var file1 = DiscordFile.new().load_file("res://icon.png")
#	Print(yield(rest.create_message("369423865618628608", {
#		embeds = [ {image = { url = "attachment://icon.png"}}],
#		files = [file1]
#	}), "completed"))

#	Print(yield(rest.crosspost_message("994518610028548127", "994519585246162984"), "completed"))
#	Print(yield(rest.edit_message("369423865618628608", "995041106272194611", {
#		content = null, # Removes the message content
#		attachments = null,
#		embeds = [Embed.new().from_dict({title = "title", description = "he desc"}).to_dict()]
#	}), "completed"))
#	Print(yield(rest.delete_message("369423865618628608", "994552474205687858"), "completed"))
#	Print(yield(rest.delete_messages("369423865618628608", ["994556339059707945", "994556341026828338", "994556343023304704"]), "completed"))

#	Print(yield(rest.edit_channel_permissions("994558391118745681", "734040758373318708", {
#		type = 1,#OverwriteTypes.MEMBER,
#		allow = Permissions.new().add(Permissions.FLAGS.SEND_MESSAGES)
#	}), "completed"))

#	Print(yield(rest.get_channel_invites("994558391118745681"), "completed"))
#	Print(yield(rest.create_channel_invite("994558391118745681"), "completed"))
#	Print(yield(rest.create_channel_invite("994558391118745681", {max_age = 5}), "completed"))

#	Print(yield(rest.create_reaction("453816730284851201", "994521176061792306", "BrokeBack:514070728119681046"), "completed"))
#	Print(yield(rest.delete_own_reaction("453816730284851201", "994521176061792306", "BrokeBack:514070728119681046"), "completed"))
#	Print(yield(rest.delete_user_reaction("453816730284851201", "994521176061792306", "BrokeBack:514070728119681046", "321233875776962560"), "completed"))
#	Print(yield(rest.get_reactions("453816730284851201", "994521176061792306", "BrokeBack:514070728119681046"), "completed"))
#	Print(yield(rest.get_reactions("453816730284851201", "994521176061792306", "BrokeBack:514070728119681046", {limit = 1}), "completed"))
#	Print(yield(rest.delete_reactions("453816730284851201", "994295386657259621"), "completed"))
#	Print(yield(rest.delete_reactions("453816730284851201", "994521176061792306", "BrokeBack:514070728119681046"), "completed"))

#	Print(yield(rest.follow_news_channel("994518610028548127", "994558391118745681"), "completed"))

#	Print(yield(rest.trigger_typing("994558391118745681"), "completed"))

#	Print(yield(rest.get_pinned_messages("369423865618628608"), "completed"))
#	Print(yield(rest.pin_message("369423865618628608", "994547930046418954"), "completed"))
#	Print(yield(rest.unpin_message("369423865618628608", "994547930046418954"), "completed"))

	# TODO: test add/remove group dm recipient
#	Print(yield(rest.group_dm_add_recipient("", "", {}), "completed"))
#	Print(yield(rest.group_dm_remove_recipient("", ""), "completed"))

#	Print(yield(rest.start_thread_from_message("369423865618628608", "994612045121081414", {name = "Test Thread From Message"}), "completed"))
#	Print(yield(rest.start_thread("369423865618628608", {name = "Test Thread", auto_archive_duration = 1440, invitable = true, type = ChannelTypes.GUILD_PUBLIC_THREAD}), "completed"))
#	Print(yield(rest.start_thread_in_forum("369423865618628608", {name = "My thread", message = {content = "Message content"}}), "completed")) # TODO: test this when forums release to public

#	Print(yield(rest.get_thread_members("994824485058400259"), "completed"))
#	Print(yield(rest.get_thread_member("994824485058400259", "321233875776962560"), "completed"))
#	Print(yield(rest.add_thread_member("994824485058400259", "369422213394464770"), "completed"))
#	Print(yield(rest.remove_thread_member("994824485058400259", "369422213394464770"), "completed"))
#	Print(yield(rest.join_thread("994824485058400259"), "completed"))
#	Print(yield(rest.leave_thread("994824485058400259"), "completed"))
#	Print(yield(rest.get_public_archived_threads("369423865618628608", {limit = 2}), "completed"))
#	Print(yield(rest.get_private_archived_threads("369423865618628608", {limit = 2}), "completed"))
#	Print(yield(rest.get_joined_private_archived_threads("369423865618628608"), "completed"))



#	Print(yield(rest.get_guild_emojis("369422519129604096"), "completed"))
#	Print(yield(rest.get_guild_emoji("369422519129604096", "894447618049048646"), "completed"))
#	Print(yield(rest.create_guild_emoji("369422519129604096", {
#		name = "test_emoji",
#		image = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAIAAABMXPacAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAAEnQAABJ0Ad5mH3gAAAOuSURBVHhe7ZhhlqsgDEZnXS7I9XQ1bsbFzAMJKgFaatv3Tc+591fFJEquivbnF6QgQAwCxCBADALEIEAMAsQgQAwCxCBADALEIEAMAsQgQAwCxCBADALEIEAMAsQgQAwCxCBADALEIEAMAsQgQAwCxCBADALEIEAMAsQgQAwCxCBADALEIEAMAsQgQAwCxCBADALEIEAMAsQgQAwCxCBADALEIEAMAsQgQAwCxCBADALEIEAMAsQgQMyAgPU2/Ximab4t62oRBeu6dPb8RZY5TmdebPPtPKz/jIApkzYD07y4VlvwdPsSBV8koCyyLrc5iXDjW3AQY9t/na8VsJGqf/D0P893C8j1v+aBU/PtAioDneB1mY+lI63gtufESFARE4N8zD7j1Z6R56ujPMIc9gwKOJ64gfQCsk3UJV6o/6oAv7MVnE4iUCzh5W1jeXG8H7QXSkH5d+Ngx96jxHGIIj1yp0GBwcRr9V8V4BXXwdaR00i4TuJQfd9M52t+H3P9O1/zdaVdkr83muk21pvbxmDi1fofF9DOjrdqfH7krRhSXu2BlGrDnZjc8L1+J86HZdJ4NXzQm71LvFz/848gGwk96X2fpYi6t9s3nX3VpYk0Ynx2O7A+LeNRgwYTL9f/L2tAXJrioFEtr/3mHtyZSLmrXSydVuMQjxo0mHi5/ssC/Hz7weFFIrxJbHs3jlWh3bOS/kTcEdvFLjdoMPFy/VcFVNO9F5wJKragHNU9+xPtvkZcdjuwe1qPGjSYeLn+awJS9WKPD+4kl20qt3ZSrg13YqpzuFurnkQKr4YPBhMv178qYL+K/bgPtoGyI7Yo7FF7UP0Otyfadkg6xVj7T9U7AtrpNlbMIS38thEYTByu7xgXEGaVSZsB/7K9Bxczyvm5QN46N8kH5Q3nzYaLL53zJ0ZfwPkQRXrkqFAbHUwcDnM8I+BE79+EHOyOuH3JH1W2fxAaHSo+5Gu5kSKmFdQXEPD/KNR/FaTzL50GfOJi915rnltM4G1/RUCLh50dBAEDhEXBfu3cvdGeAQGPsIdS8X6Q2v+O/iNggONDvlhc39F+BAyy1i8I7+h+AAFiECAGAWIQIAYBYhAgBgFiECAGAWIQIAYBYhAgBgFiECAGAWIQIAYBYhAgBgFiECAGAWIQIAYBYhAgBgFiECAGAWIQIAYBYhAgBgFiECAGAWIQIAYBYhAgBgFiECAGAWIQIAYBYhAgBgFiECAGAWIQIAYBYhAgBgFiECDl9/cfVWryIAOkWS4AAAAASUVORK5CYII="
#	}), "completed"))
#	Print(yield(rest.modify_guild_emoji("369422519129604096", "994838400651755621", {
#		name = "edited_emoji2",
#	}), "completed"))
#	Print(yield(rest.delete_guild_emoji("369422519129604096", "994838400651755621"), "completed"))


#	Print(yield(rest.get_guild("994852345970163712", true), "completed"))
#	Print(yield(rest.get_guild_preview("994852345970163712"), "completed"))
#	Print(yield(rest.create_guild({
#		name = "TestGuild 001"
#	}), "completed"))
#	Print(yield(rest.modify_guild("994852345970163712", {
#		name = "Edited guild name",
#		description = "Edited guild desc"
#	}), "completed"))
#	Print(yield(rest.delete_guild("994852345970163712"), "completed"))

#	Print(yield(rest.get_guild_channels("369422519129604096"), "completed"))
#	Print(yield(rest.create_guild_channel("369422519129604096", {
#		name = "test name",
#		topic = "test topic",
#	}), "completed"))
#	Print(yield(rest.modify_guild_channels("369422519129604096", ModifyGuildChannelsParams.new().from_dict({
#		modifications = [
#			GuildChannelModification.new().from_dict({
#				id = "374137299811696640",
#				position = 3
#			}).to_dict()
#		]
#	})), "completed"))

#	Print(yield(rest.get_active_guild_threads("369422519129604096"), "completed"))

#	Print(yield(rest.get_guild_members("369422519129604096", {limit = 100}), "completed"))
#	Print(yield(rest.get_guild_member("369422519129604096", "172002275412279296"), "completed"))
#	Print(yield(rest.search_guild_members("369422519129604096", {
#		query = "discord",
#		limit = 10
#	}), "completed"))
#	Print(yield(rest.add_guild_member(), "completed")) # TODO: test this method
#	Print(yield(rest.modify_guild_member("369422519129604096", "369422213394464770", {
#		nick = null
#	}), "completed"))
#	Print(yield(rest.modify_current_member("369422519129604096", null), "completed"))

#	Print(yield(rest.add_guild_member_role("369422519129604096", "369422213394464770", "993759829850079253"), "completed"))
#	Print(yield(rest.remove_guild_member_role("369422519129604096", "369422213394464770", "993759829850079253"), "completed"))
#	Print(yield(rest.remove_guild_member("369422519129604096", "309562096486449153"), "completed"))

#	Print(yield(rest.get_guild_bans("330264450148073474", {limit = 5}), "completed"))
#	Print(yield(rest.get_guild_ban("330264450148073474", "775654177736097802"), "completed"))
#	Print(yield(rest.create_guild_ban("369422519129604096", "309562096486449153"), "completed"))
#	Print(yield(rest.remove_guild_ban("369422519129604096", "309562096486449153"), "completed"))

#	Print(yield(rest.get_guild_roles("369422519129604096"), "completed"))
#	Print(yield(rest.get_guild_role("369422519129604096", "369422519129604096"), "completed"))
#	var params_create_guild_role = CreateGuildRoleParams.new().from_dict({
#		name = "Created Role 001",
#		color = 1000,
#		hoist = true,
#		mentionable = true
#	})
#	params_create_guild_role.permissions = Permissions.new().add(Permissions.FLAGS.ADMINISTRATOR)
#	Print(yield(rest.create_guild_role("369422519129604096", params_create_guild_role), "completed"))
#	Print(yield(rest.modify_guild_roles("369422519129604096", {
#		modifications = [
#			{id = "994911039407784028", position = 1}
#		]
#	}), "completed"))
#	Print(yield(rest.modify_guild_role("369422519129604096", "994911039407784028", {
#		name = "edited role name",
#		permissions = 0
#	}), "completed"))
#	Print(yield(rest.delete_guild_role("369422519129604096", "994911039407784028"), "completed"))

#	Print(yield(rest.get_guild_prune_count("369422519129604096"), "completed"))
#	Print(yield(rest.begin_guild_prune("369422519129604096"), "completed")) # TODO: test this method

#	Print(yield(rest.get_guild_voice_regions("369422519129604096"), "completed"))

#	Print(yield(rest.get_guild_invites("369422519129604096"), "completed"))

#	Print(yield(rest.get_guild_integrations("369422519129604096"), "completed"))
#	Print(yield(rest.delete_guild_integration("369422519129604096", "841711554055372800"), "completed")) # TODO: test this method

#	Print(yield(rest.get_guild_widget_settings("369422519129604096"), "completed"))
#	Print(yield(rest.get_guild_widget("369422519129604096"), "completed"))
#	Print(yield(rest.get_guild_widget_image("369422519129604096"), "completed"))


#	Print(yield(rest.modify_guild_widget("369422519129604096", {enabled = true}), "completed"))

#	Print(yield(rest.get_guild_vanity_url("369422519129604096"), "completed"))

#	Print(yield(rest.get_guild_welcome_screen("369422519129604096"), "completed"))
#	Print(yield(rest.modify_guild_welcome_screen("369422519129604096", {
#		enabled = true,
#		description = "hey"
#	}), "completed")) # TODO: test this method

#	Print(yield(rest.modify_current_user_voice_state("330264450148073474", {
#		channel_id = "369422519129604100"
#	}), "completed")) # TODO: test this method
#	Print(yield(rest.modify_user_voice_state("330264450148073474", "321233875776962560", {
#		channel_id = null
#	}), "completed")) # TODO: test this method


#	Print(yield(rest.get_guild_scheduled_events("369422519129604096"), "completed"))
#	Print(yield(rest.create_guild_scheduled_event("369422519129604096", {
#		name = "Created event 001",
#		privacy_level = GuildScheduledEventPrivacyLevel.GUILD_ONLY,
#		entity_type = GuildScheduledEventEntityTypes.EXTERNAL,
#		scheduled_start_time = "2022-08-08T12:57:45+0000",
#		scheduled_end_time = "2023-07-08T12:57:45+0000",
#		entity_metadata = {
#			location = "India"
#		}
#	}), "completed"))
#	Print(yield(rest.modify_guild_scheduled_event("369422519129604096", "994950886365335582", {
#		description = "edited desc",
#		status = GuildScheduledEventStatus.COMPLETED
#	}), "completed"))
#	Print(yield(rest.delete_guild_scheduled_event("369422519129604096", "994950886365335582"), "completed"))
#	Print(yield(rest.get_guild_scheduled_event_users("369422519129604096", "994947386298347591", {with_member = true}), "completed"))



#	Print(yield(rest.get_guild_template("Wne7zhb45uKQ"), "completed"))
#	Print(yield(rest.create_guild_from_template("Wne7zhb45uKQ", {
#		name = "My Guild From Template"
#	}), "completed"))
#	Print(yield(rest.create_template_from_guild("369422519129604096", {
#		name = "Test template 001"
#	}), "completed"))
#	Print(yield(rest.delete_guild_template("369422519129604096", "vjsvmNqw3aww"), "completed"))
#	Print(yield(rest.sync_guild_template("369422519129604096", "vjsvmNqw3aww"), "completed"))
#	Print(yield(rest.modify_guild_template("369422519129604096", "vjsvmNqw3aww", {name = "Edited template name"}), "completed"))



#	Print(yield(rest.get_invite("FZY9TqW"), "completed"))
#	Print(yield(rest.delete_invite("YKx5F8Fc"), "completed"))



#	Print(yield(rest.create_stage_instance({
#		channel_id = "993847090595766292",
#		send_start_notification = false,
#		topic = "Discord.gd test stage instance"
#	}), "completed"))
#	Print(yield(rest.get_stage_instance("993847090595766292"), "completed"))
#	Print(yield(rest.modify_stage_instance("993847090595766292", {
#		topic = "Discord.gd edited topic"
#	}), "completed"))
#	Print(yield(rest.delete_stage_instance("993847090595766292"), "completed"))



#	Print(yield(rest.get_sticker("860415820748292129"), "completed"))
#	Print(yield(rest.get_sticker_packs(), "completed"))
#	Print(yield(rest.get_guild_stickers("369422519129604096"), "completed"))
#	Print(yield(rest.get_guild_sticker("330264450148073474", "860415820748292129"), "completed"))
#	Print(yield(rest.modify_guild_sticker("369422519129604096", "995011624823955607", {
#		name = "edited-name",
#		description = "edited desc"
#	}), "completed"))
#	Print(yield(rest.delete_guild_sticker("330264450148073474", "860415820748292129"), "completed"))



#	Print(yield(rest.get_current_user(), "completed"))
#	Print(yield(rest.get_user("321233875776962560"), "completed"))
#	Print(yield(rest.modify_current_user({
#		avatar = DiscordFile.new().load_file("res://icon.png").to_data_uri()
#	}), "completed"))
#	Print(yield(rest.get_current_user_guilds({limit = 1}), "completed"))
#	Print(yield(rest.get_current_guild_member("330264450148073474"), "completed")) # TODO: test this method

#	Print(yield(rest.leave_guild("930050630368768010"), "completed"))

#	Print(yield(rest.create_dm("321233875776962560"), "completed"))
#	Print(yield(rest.create_group_dm({}), "completed")) # TODO: test this method

#	Print(yield(rest.get_current_user_connections(), "completed"))



#	Print(yield(rest.get_voice_regions(), "completed"))

#	Print(Snowflake.new().from_dict({increment = 1, timestamp_ms = 1501620762534, worker_id = 2}))

#	var intents = GatewayIntents.new(GatewayIntents.new().ALL)







#	print(DiscordBase.new().to_dict())
#	print(DiscordBase.new(930050630368768010).to_dict())
#	print(DiscordBase.new("930050630368768010").to_dict())

#	var cli = DiscordClient.new(Env.get_var("TOKEN"), {
#		get_all_users = true,
#		intents = DiscordConstants.IntentsAll
#	})
#	add_child(cli)
#	cli.login()

#	var ret = yield(cli, "client_ready")
#	print(ret, "ready")
#	print(cli.guilds)

#	var chan1 = Channel.new({
#		type = 2,
#		id = "930050630368768010"
#	}, cli)
#	var chan2 = Channel.new({
#		type = 1,
#		id = "830050630368768010"
#	}, cli)
#	print(JSON.print(chan1.to_dict()))
#	print(chan1)
#	print(JSON.print(chan1.to_dict()))

#	var coll1 = DiscordCollection.new(Channel, 0)
#	print(coll1.add(chan1))
#	print(coll1.add({
#		type = 2,
#		id = "930050630368768010"
#	}))

#	coll1.add(chan1)
#	coll1.add(chan2)
#	print(coll1)
