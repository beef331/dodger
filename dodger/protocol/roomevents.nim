import pkg/sunny

type CreateEvent* = object
  creator*: string
  federate* {.json"m.federate".}: bool
  predecessor*: RawJson
  roomVersion* {.json:"room_version".}: string
  typ* {.json: "type".}: string
