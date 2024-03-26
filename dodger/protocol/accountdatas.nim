import events

type AccountData* = object
  events*: seq[ClientEvent]
