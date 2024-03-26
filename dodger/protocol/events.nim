import pkg/sunny

type
  Event* = object of RootObj
    content*: RawJson
    typ* {.json"type".}: string

  ClientEventWithoutRoomID* = object of Event
    eventId* {.json:"event_id".}: string
    originServerTs* {.json:"origin_server_ts".}: int
    sender*: string
    stateKey* {.json"state_key".}: string
    unsigned*: RawJson

  ClientEvent* = object of ClientEventWithoutRoomID
    roomId* {.json"room_id".}: string

  StrippedEventState* = object of Event
    sender*: string
    state_key*: string

  Timeline* = object
    events*: seq[ClientEvent]
    prev_batch*: string
    limited: bool

