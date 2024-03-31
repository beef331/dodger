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
    accessToken* {.json"access_token".}: string
    deviceId* {.json"device_id".}: string
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
    deviceName {.json"device_name".}: string
    password: string
    `type` = "m.login.password"

  LoginRequest(identifier: ident, deviceName: deviceName, password: password).toJson(buffer)

  Request[LoginResponse](url: loginEndpoint, data: buffer, reqMethod: HttpPost)


proc login*(): Request[LoginProviders] =
  ## Request for fetching the login support for a server
  Request[LoginProviders](url: loginEndpoint, data: "", reqMethod: HttpGet)


when isMainModule or defined(nimsuggest):
  import std/[httpclient, uri]

  proc handleRequest[T](client: HttpClient, request: Request[T]): T =
    when defined dodgerPrintRequests:
      echo request.reqMethod, ": ", request.url, ": "
      echo request.data

    let
      url = parseUri("https://www.matrix.org" & request.url)
      resp = client.request(url, request.reqMethod, request.data)

    when defined dodgerPrintResponses:
      echo resp.body
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

  proc sync(nextBatch: string): SyncResponse =
    let client = newHttpClient(headers = newHttpHeaders({"Authorization": "Bearer " & tok}))
    defer: client.close()
    result = client.handleRequest syncRequest(SyncRequest(timeout: 1000, since: nextBatch))

    for name, room in result.rooms.join:
      var roomInfo: array[RoomEventKind, string]
      for evt in room.state.events:
        if evt.typ.startsWith"m.room":
          try:
            case parseEnum[RoomEventKind](evt.typ)
            of Name:
              roomInfo[Name] = (tuple[name: string]).fromJson(evt.content.string).name
            of Avatar:
              roomInfo[Avatar] = evt.content.string
            else:
              discard
          except:
            discard

      for evt in room.timeline.events:
        if evt.typ.startsWith"m.room":
          try:
            case parseEnum[RoomEventKind](evt.typ)
            of Message:
              echo evt.sender, ": ", (tuple[body: string]).fromJson(evt.content.string).body
            else: discard
          except:
            discard

  var syncResp = sync("")
  while true:
    syncResp = sync(syncResp.nextBatch)
