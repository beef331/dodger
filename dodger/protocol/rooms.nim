import std/tables
import clientevents, accountdatas
import pkg/sunny

type
  Timeline* = object
    events*: seq[ClientEvent]
    prev_batch*: string
    limited: bool

  StrippedEventState* = object
    content*: RawJson
    sender*: string
    state_key*: string
    typ* {.json"type".}: string

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
    heroes* {.json"m.heroes".}: string
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
    events: seq[StrippedEventState]

  KnockedRoom* = object
    knockState* {.json"knock_state".}: KnockState

  LeftRoom* = object
    accountData {.json"account_data".}: AccountData
    state*: State
    timeline*: Timeline

  Rooms* = object
    invite*: Table[string, InvitedRoom]
    join*: Table[string, JoinedRoom]
    knock*: Table[string, KnockedRoom]
    leave*: Table[string, LeftRoom]
