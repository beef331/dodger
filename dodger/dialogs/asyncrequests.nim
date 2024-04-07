import std/[httpclient, asyncdispatch, os, uri, strutils]
import ../protocol/[requestobjs, syncs]

let cacheDir* = getCacheDir() / "dodger"

type UserContext* = ref object # What to call this?
  homeserver*: string
  token*: string
  nextSync*: string
  onSync: seq[proc(_: SyncResponse)]


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


proc mxcToPath*(fileUrl, ext: string): string =
  let theUri = parseUri(fileUrl)
  {.cast(gcSafe).}:
    cacheDir / theUri.hostname / theUri.path &
      (if ext.len > 0:
        "." & ext
      else:
        "")

proc downloadMxcToCache*(context: UserContext, fileUrl, ext: string) {.async.} =
  let
    theUri = parseUri(fileUrl)
    dest = fileUrl.mxcToPath(ext)

  discard existsOrCreateDir cacheDir
  if not fileExists(dest):
    let client = newAsyncHttpClient()
    defer: client.close()
    if context.token != "":
      client.headers = newHttpHeaders({"Authorization": "Bearer " & context.token})
    discard existsOrCreateDir cacheDir / theUri.hostname
    echo "https://$#/_matrix/media/v3/download/$#$#" % [context.homeserver, theUri.hostname, theUri.path], " to: ", dest
    await downloadFile(client, "https://$#/_matrix/media/v3/download/$#$#" % [context.homeserver, theUri.hostname, theUri.path], dest)
  else:
    await sleepAsync(0)


proc onSync*(ctx: UserContext, resp: SyncResponse) =
  for evt in ctx.onSync:
    evt(resp)

proc addSyncEvent*(ctx: UserContext, evt: proc(_: SyncResponse)) =
  ctx.onSync.add evt
