import requestobjs, accountdatas, rooms, clientevents
import sunny

type
  Event* = object
    content*: RawJson # string?
    `type`*: string

  SyncResponse* = object
    nextBatch* {.json: "next_batch".}: string
    accountData* {.json: "account_data".}: AccountData
    rooms*: Rooms

  ChunkSyncResponse* = object
    start*: string
    stop* {.json"end".}: string
    chunk: seq[ClientEvent]

const syncEndPoint* = "/_matrix/client/v3/sync"

proc syncRequest*(timeout = 0): Request[SyncResponse] =
  type SyncRequest = object
    timeout: int

  Request[SyncResponse](
    url: syncEndPoint,
    reqMethod: HttpGet,
    data: $ SyncRequest(timeout: timeout).toJson()
  )


proc syncRequest*(frm: string, timeout = 0): Request[ChunkSyncResponse] =
  type SyncRequest = object
    timeout: int
    frm {.json"from".}: string

  Request[ChunkSyncResponse](
    url: syncEndPoint,
    reqMethod: HttpGet,
    data: $ SyncRequest(timeout: timeout, frm: frm).toJson()
  )
