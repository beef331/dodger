import clientevents

type AccountData* = object
  events*: seq[ClientEvent]
