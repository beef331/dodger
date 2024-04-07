import pkg/[owlkettle, ponairi, sunny]
import dialogs/[login, errors, asyncrequests, chat]
import protocol/[syncs, rooms, infos, roomevents]
import database/datas
import std/[asyncdispatch, os, options, tables, strutils]

viewable App:
  timeout: EventDescriptor
  currentView: Widget
  exceptionDialog: Widget
  context: UserContext
  db: DbConn
  syncing: bool

let
  dataDir = getConfigDir() / "dodger"
  dbPath = dataDir / "data.sqlite"
  dataPath = dataDir / "data"


method view(app: AppState): Widget =
  proc asyncConsumer(): bool =
    try:
      if getGlobalDispatcher() != nil and hasPendingOperations():
        poll(0)
    except Exception as e:
      errorDialog(app):
        when not defined(release):
          e.msg & "\n" & e.getStackTrace()
        else:
          e.msg
    discard app.redraw()
    result = true

  if app.timeout.isNil:
    app.timeout = addGlobalTimeout(1, asyncConsumer)

  if app.context.token == "":
    app.currentView = gui:
      Login:
        proc onLogin(ctx: UserContext) =
          app.context = ctx
          writeFile dataPath, UserData(homeserver: ctx.homeserver, token: ctx.token).toJson()
  elif app.currentView.isNil:
    app.currentView = gui(ChatWindow(db = app.db, context = app.context))
  else:
    if not app.syncing:
      let fullSync = app.context.nextSync == ""
      proc syncCall(nextBatch: string, timeout: int) {.async.} =
        await sleepAsync(timeout)
        let sync = await handleRequest(app.context, syncRequest(SyncRequest(since: nextBatch, timeout: timeout, fullState: fullSync)))
        app.context.nextSync = sync.nextBatch
        app.syncing = false
        for roomId, room in sync.rooms.join:
          var data = RoomData(roomId: roomId)
          for evt in room.state.events:
            if evt.typ.startsWith"m.room":
              try:
                case parseEnum[RoomEventKind](evt.typ)
                of Name:
                  data.name = NameData.fromJson(evt.content.string).name
                of Avatar:
                  data.avatar = evt.content.string
                of Create:
                  let create = CreateEvent.fromJson(evt.content.string)
                  data.roomType = create.typ
                else:
                  discard
              except: discard
          app.db.upsert(data)
        app.context.onSync(sync)


        writeFile dataPath, UserData(homeserver: app.context.homeserver, token: app.context.token, lastSync: sync.nextBatch).toJson()

      asyncCheck syncCall(app.context.nextSync, 1000)
      app.syncing = true

  result = gui:
    Window:
      Box:
        insert(app.currentView)


discard existsOrCreateDir(dataDir)

let db = newConn(dbPath)
db.create RoomData

let data =
  try:
    UserData.fromJson(readFile(dataPath))
  except:
    UserData()
setControlCHook proc() {.noconv.} = discard

brew:
  gui:
    App:
      db = db
      context = UserContext(token: data.token, homeserver: data.homeserver, nextSync: data.lastSync)

db.close()
