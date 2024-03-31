import pkg/[ponairi]

type
  UserData* = object
    lastSync*: string
    token*: string
    homeserver*: string

  RoomData* = object
    roomId* {.primary.}: string
    avatar*: string
    name*: string
