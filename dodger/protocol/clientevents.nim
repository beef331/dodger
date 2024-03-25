import pkg/sunny

type ClientEvent* = object
  content*: RawJson
  typ* {.json"type".}: string


