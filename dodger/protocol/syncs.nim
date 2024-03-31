import requestobjs, accountdatas, rooms, events, queries
import sunny

type
  Event* = object
    content*: RawJson # string?
    `type`*: string

  SyncResponse* = object
    nextBatch* {.json: "next_batch".}: string
    accountData* {.json: "account_data".}: AccountData
    rooms*: Rooms

  Filter* = object ## TODO: Move this to it's own module with an API for it
    lazyLoad* {.json"lazy_load_members".}: bool

  SyncRequest* = object
    since*: string
    timeout*: int
    fullState* {.queryName"full_state".}: bool

const syncEndPoint* = "/_matrix/client/v3/sync"

proc syncRequest*(req: SyncRequest): Request[SyncResponse] =
  Request[SyncResponse](
    url: syncEndPoint & "?" & req.toQuery(),
    reqMethod: HttpGet,
  )
