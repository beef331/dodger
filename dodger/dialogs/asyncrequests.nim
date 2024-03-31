import std/[httpclient, asyncdispatch]
import ../protocol/[requestobjs]

type UserContext* = object # What to call this?
  homeserver*: string
  token*: string
  nextSync*: string


proc handleRequest*[T](context: UserContext, request: Request[T]): Future[T] {.async.} =
  when defined dodgerPrintRequests:
    echo request.reqMethod, ": ", request.url, " ", request.data

  let client = newAsyncHttpClient()
  defer: client.close()
  if context.token != "":
    client.headers = newHttpHeaders({"Authorization": "Bearer " & context.token})

  let
    url = "https://" & context.homeserver & request.url
    resp = await client.request(url, request.reqMethod, request.data)

  result.extract await resp.body
