import requestobjs, accountdatas, rooms, events
import sunny

type
  Event* = object
    content*: RawJson # string?
    `type`*: string

  SyncResponse* = object
    nextBatch* {.json: "next_batch".}: string
    accountData* {.json: "account_data".}: AccountData
    rooms*: Rooms

const syncEndPoint* = "/_matrix/client/v3/sync"

proc syncRequest*(since: string = "", timeout = 1000): Request[SyncResponse] =
  type Filter = object ## TODO: Move this to it's own module with an API for it
    lazyLoad {.json"lazy_load_members".}: bool

  type SyncRequest = object
    since: string
    timeout: int
    filter: Filter
    fullState {.json"full_state".}: bool


  Request[SyncResponse](
    url: syncEndPoint,
    reqMethod: HttpGet,
    data: SyncRequest(
      since: since,
      timeout: timeout,
      filter: Filter(lazyLoad: true),
      fullState: true
    ).toJson()
  )
