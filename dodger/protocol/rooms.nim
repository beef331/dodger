import std/[tables, strutils]
import events, accountdatas, requestobjs, queries, infos
import pkg/sunny

type
  UnsignedData* = object
    age*: int
    prevContent* {.json:"prev_content".}: RawJson
    redactedBecause* {.json: "redacted_because".}: ClientEventWithoutRoomID
    transactionId* {.json"transaction_id".}: string

  InvitedRoom* = object
    events*: seq[StrippedEventState]

  Ephemeral* = object
    events*: seq[ClientEvent]

  RoomSummary* = object
    heroes* {.json"m.heroes".}: seq[string]
    invitedMemberCount* {.json"m.invited_member_count".}: int
    joinedMemeberCount* {.json"m.joined_member_count".}: int

  State* = object
    events*: seq[ClientEventWithoutRoomID]

  UnreadNotifications* = object
    notificationCount* {.json"notification_count".}: int
    highlightCount* {.json"highlight_count".}: int

  JoinedRoom* = object
    accountData* {.json"account_data".}: AccountData
    ephemeral*: Ephemeral
    state*: State
    summary*: RoomSummary
    timeline*: Timeline
    unreadNotifications* {.json"unread_notifications".}: UnreadNotifications
    unreadThreadNotifications* {.json"unread_thread_notifications".}: UnreadNotifications

  KnockState* = object
    events*: seq[StrippedEventState]

  KnockedRoom* = object
    knockState* {.json"knock_state".}: KnockState

  LeftRoom* = object
    accountData* {.json"account_data".}: AccountData
    state*: State
    timeline*: Timeline

  Rooms* = object
    invite*: Table[string, InvitedRoom]
    join*: Table[string, JoinedRoom]
    knock*: Table[string, KnockedRoom]
    leave*: Table[string, LeftRoom]


const roomEventUrl* = " /_matrix/client/v3/rooms/$#/event/$#"

proc eventRequest*(roomId, eventId: string, lazyLoad = true): Request[ClientEvent] =
  Request[ClientEvent](
    url: roomEventUrl % [roomId, eventId],
    reqMethod: HttpGet
  )


type RoomAlias* = object
  aliases*: seq[string]

proc aliasRequest*(roomId: string): Request[RoomAlias] =
  Request[RoomAlias](
    url: "/_matrix/client/v3/rooms/$#/aliases" % roomId,
    reqMethod: HttpGet
  )


type
  Direction* = enum
    Chronological = "f"
    Reversed = "b"

  MessageQuery* = object
    dir*: Direction
    frm* {.queryName"from".}: string
    limit*: int = 10
    to*: string


  MessageResponse* = object
    chunk* {.json:",required".}: seq[ClientEvent]
    nd* {.json"end".}: string
    start* {.json:",required".}: string
    state*: seq[ClientEvent]

  RoomEventKind* = enum
    Create = "m.room.create"
    Name = "m.room.name"
    Avatar = "m.room.avatar"
    Topic = "m.room.topic"
    JoinRules = "m.room.join_rules"
    CanonicalAlias = "m.room.canonical_alias"
    Encrypted = "m.room.encrypted"
    Encryption = "m.room.encryption"
    Member = "m.room.member"
    Message = "m.room.message"
    PowerLevels = "m.room.power_levels"
    HistoryVisibility = "m.room.history_visibility"
    GuestAccess = "m.room.guest_access"
    RelatedGroups = "m.room.related_groups"

  NameData* = object
    name* {.json",required".}: string

  AvatarData* = object
    url*: string
    info*: ImageInfo

  TopicData* = object
    topic* {.json",required".}: string


  MessageType* = enum
    Text = "m.text"
    Emote = "m.emote"
    Notice = "m.notice"
    Image = "m.image"
    File = "m.file"
    Audio = "m.audio"
    Location = "m.location"
    Video = "m.video"

  MessageData* = object
    body* {.json",required".}: string
    format*: string
    formattedBody* {.json"formatted_body".}: string
    case kind* {.json"msgtype,required".}: MessageType
    of Text, Emote, Notice:
      discard

    of Image:
      imageFilename* {.json"filename".}: string
      imageInfo* {.json"info".}: ImageInfo
      imageurl* {.json"url".}: string
    of File:
      fileFilename* {.json"filename".}: string
      fileInfo* {.json"info".}: FileInfo
      fileurl* {.json"url".}: string
    of Audio:
      audioFilename* {.json"filename".}: string
      audioInfo* {.json"info".}: AudioInfo
      audioUrl* {.json"url".}: string
    of Location:
      geoUri* {.json"geo_uri,required".}: string
      locationInfo* {.json"info".}: LocationInfo
      locationUrl* {.json"url".}: string
    of Video:
      videoFilename* {.json"filename".}: string
      videoInfo* {.json"info".}: AudioInfo
      videoUrl* {.json"url".}: string

    else:
      discard


  PinnedEventData* = object
    pinned* {.json",required".}: seq[string]

proc messageRequest*(roomId: string, query: MessageQuery): Request[MessageResponse] =
  Request[MessageResponse](
    url: "/_matrix/client/v3/rooms/$#/messages?" % roomId & query.toQuery(),
    reqMethod: HttpGet
  )
