import pkg/sunny

type
  IdentifierKind* = enum
    User = "m.id.user"
    ThirdParty = "m.id.thirdparty"
    Phone = "m.id.phone"

  Identifier* = object
    case kind* {.json"type".}: IdentifierKind
    of User:
      user*: string
    of ThirdParty:
      medium*: string
      address*:string
    of Phone:
      country*: string
      phone*: string

  IdentityProvider* = object
    id*: string
    name*: string
    icon*: string
    brand*: string
