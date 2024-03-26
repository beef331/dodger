import identifiers, information, requestobjs, syncs, rooms
import std/[options, strutils, os, tables]
import pkg/sunny

type
  LoginKind = enum
    Sso = "m.login.sso"
    Token = "m.login.token"
    Password = "m.login.password"
    ApplicationService = "m.login.application_service"

  LoginType = object
    case kind {.json:"type".}: LoginKind
    of Sso:
      providers: seq[IdentityProvider]
    else:
      discard

  LoginProviders = object
    flows: seq[LoginType]

  LoginResponse* = object
    access_token*: string
    device_id*: string
    #expires_in_ms*: Option[int]
    #refresh_token*: Option[string]
    home_server: string
    user_id*: string
    well_known*: DiscoveryInformation

const loginEndpoint* = "/_matrix/client/v3/login"

proc login*(ident: Identifier, deviceName, password: sink string): Request[LoginResponse] =
  ## Login using a device identifier, device name, and a password
  var buffer = ""
  type LoginRequest = object
    identifier: Identifier
    deviceName: string
    password: string
    `type` = "m.login.password"

  LoginRequest(identifier: ident, deviceName: deviceName, password: password).toJson(buffer)

  Request[LoginResponse](url: loginEndpoint, data: buffer, reqMethod: HttpPost)


proc login*(): Request[LoginProviders] =
  ## Request for fetching the login support for a server
  Request[LoginProviders](url: loginEndpoint, data: "", reqMethod: HttpGet)


when isMainModule:
  import std/[httpclient, uri]

  proc handleRequest[T](client: HttpClient, request: Request[T]): T =
    let
      url = parseUri("https://www.matrix.org" & request.url)
      resp = client.request(url, request.reqMethod, request.data)
    result.extract resp.body

  var tok: string
  try:
    tok = readFile(getConfigDir() / "matewrecks" / "token")

  except CatchableError:
    let client = newHttpClient()
    defer: close client
    echo client.handleRequest(login())
    var pw = readFile("/tmp/pw")
    pw.setLen(pw.high)
    let resp = client.handleRequest(login(Identifier(kind: User, user: "Elegantbeef"), "Matewrecks", pw))


    discard existsOrCreateDir(getConfigDir() / "matewrecks")
    writeFile(getConfigDir() / "matewrecks" / "token", resp.access_token)

    tok = resp.access_token

  let client = newHttpClient(headers = newHttpHeaders({"Authorization": "Bearer " & tok}))
  echo client.handleRequest login()
  var sync = client.handleRequest(syncRequest(timeout = 1000))

  for room in sync.rooms.join.keys:
    let messages = client.handleRequest messageRequest(room, MessageQuery(frm: sync.next_batch))
    for message in messages.chunk:
      if message.typ == "m.room.name":
        echo room, ": ", (tuple[name: string]).fromJson(message.content.string)
