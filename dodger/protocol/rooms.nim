import std/[tables, strutils]
import events, accountdatas, requestobjs
import pkg/sunny

type



  UnsignedData* = object
    age*: int
    prevContent* {.json:"prev_content".}: RawJson
    redactedBecause* {.json: "redacted_because".}: ClientEventWithoutRoomID
    transactionId* {.json"transaction_id".}: string

  ClientEventWithoutRoomID* = object
    content*: RawJson
    eventId* {.json:"event_id".}: string
    originServerTs* {.json:"origin_server_ts".}: int
    sender*: string
    stateKey* {.json"state_key".}: string
    typ* {.json:"type".}: string
    unsigned*: RawJson

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
  MessageQuery* = object
    dir*: string
    filter*: string
    frm* {.json"from".}: string
    limit*: int = 10
    to*: string

  MessageResponse* = object
    chunk*: seq[ClientEvent]
    nd* {.json"end".}: string
    start*: string
    state*: seq[ClientEvent]



proc messageRequest*(roomId: string, query: MessageQuery): Request[MessageResponse] =
  Request[MessageResponse](
    url: "/_matrix/client/v3/rooms/$#/messages" % roomId,
    data: query.toJson(),
    reqMethod: HttpGet
  )
