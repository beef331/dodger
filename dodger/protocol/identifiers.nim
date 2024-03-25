import pkg/sunny

type
  Identifier* = object
    user*: string
  IdentityProvider* = object
    id*: string
    name*: string
    icon*: string
    brand*: string

const matrixType* = "m.id.user"

type Response = object
  typ {.json:"type".}: string
  user: string

proc toJson*(ident: Identifier; buffer: var string) =
  Response(user: ident.user, typ: matrixType).toJson(buffer)

proc fromJson*(ident: var Identifier; val: JsonValue, input: string) =
  var response: Response
  response.fromJson(val, input)
  assert response.typ == matrixType
  ident.user = response.user
