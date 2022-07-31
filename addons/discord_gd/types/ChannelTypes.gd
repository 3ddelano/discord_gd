# Represents a list of Discord channel types
class_name ChannelTypes

const GUILD_TEXT = 0 # A text channel within a server
const DM = 1 # A direct message between users
const GUILD_VOICE = 2 # A voice channel within a server
const GROUP_DM = 3 # A direct message between multiple users
const GUILD_CATEGORY = 4 # An organizational category that contains up to 50 channels
const GUILD_NEWS = 5 # A channel that users can follow and crosspost into their own server
const GUILD_NEWS_THREAD = 10 # A temporary sub-channel within a GUILD_NEWS channel
const GUILD_PUBLIC_THREAD = 11 # A temporary sub-channel within a GUILD_TEXT channel
const GUILD_PRIVATE_THREAD = 12 # A temporary sub-channel within a GUILD_TEXT channel that is only viewable by those invited and those with the MANAGE_THREADS permission
const GUILD_STAGE_VOICE = 13 # A voice channel for hosting events with an audience
const GUILD_DIRECTORY = 14 # The channel in a hub containing the listed servers
const GUILD_FORUM = 15 # A channel that can only contain threads
