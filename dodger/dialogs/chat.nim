import pkg/[owlkettle, ponairi, sunny]
import std/[asyncdispatch, uri, os, strutils, sugar, tables]
import asyncrequests, messages
import ../protocol/[requestobjs, syncs, rooms, events]
import ../database/datas

viewable RoomSelection:
  roomId: string
  avatarUrl: string
  roomName: string
  pixbuf: PixBuf
  proc clicked(roomId: string)

method view(select: RoomSelectionState): Widget =
  if select.pixbuf != nil:
    gui:
      Box:
        Button {.expand: false.}:
          tooltip = select.roomName
          Picture:
            pixbuf = select.pixbuf
          proc clicked() =
            select.clicked.callback(select.roomId)
            discard select.app.redraw()

  else:
    gui:
      Box:
        Button {.expand: false.}:
          text = select.roomName
          tooltip = select.roomName
          proc clicked() =
            select.clicked.callback(select.roomId)
            discard select.app.redraw()

viewable ChatWindow:
  roomId: string
  db: DbConn
  context: UserContext
  roomSelect: seq[RoomSelection]
  inited: bool
  messages: Table[string, seq[Msg]]

proc getMessages*(context: UserContext, room: string): Future[seq[Msg]] {.async.} =
  let messages = await context.handleRequest(messageRequest(room, MessageQuery(dir: Reversed, limit: 10)))
  for evt in messages.chunk:
    try:
      if parseEnum[RoomEventKind](evt.typ) == Message:
        result.add:
          gui:
            Msg:
              message = MessageData.fromJson(evt.content.string).body
              sender = evt.sender
              eventId = evt.eventId
    except: discard


method view(chatWindow: ChatWindowState): Widget =
  if not chatWindow.inited:
    chatWindow.inited = true
    chatwindow.context.addSyncEvent proc(resp: SyncResponse) =
     for name, room in resp.rooms.join:
      if not chatWindow.messages.hasKeyOrPut(name, @[]):
        # Get the last few messages to make the client usable
        capture name:
          let fut = getMessages(chatWindow.context, name)
          fut.addCallback proc(msgs: Future[seq[Msg]]) =
            chatWindow.messages[name].add msgs.read
            discard chatWindow.app.redraw()

      for evt in room.timeline.events:
        try:
          case parseEnum[RoomEventKind](evt.typ)
          of Message:
            chatWindow.messages[name].add:
              gui:
                Msg:
                  message = MessageData.fromJson(evt.content.string).body
                  sender = evt.sender
                  eventId = evt.eventId
          else:
            discard
        except:
          discard

    for room in chatWindow.db.find(seq[RoomData], sql"SELECT * FROM ROOMDATA"):
      if room.name != "" or not room.isSpace:
        let name = room.roomId
        if not chatWindow.messages.hasKeyOrPut(name, @[]):
          # Get the last few messages to make the client usable
          capture name:
            let fut = getMessages(chatWindow.context, name)
            fut.addCallback proc(msgs: Future[seq[Msg]]) =
              chatWindow.messages[name].add msgs.read
              discard chatWindow.app.redraw()

        if room.avatar != "":
          let avatarData = AvatarData.fromJson(room.avatar)
          if avatarData.url != "":
            let
              ext =
                if '/' in avatarData.info.mimetype:
                  avatarData.info.mimetype.split"/"[1]
                else:
                  "jpeg"
            let
              downloadFut = downloadMxcToCache(chatWindow.context, avatarData.url, ext)
              name = room.name
              id = room.roomId
              url = avatarData.url
            capture name, id, url:
              downloadFut.addCallback(proc() =
                try:
                  let fut = try:
                    loadPixBufAsync(url.mxcToPath(ext))
                  except CatchableError as e:
                    return
                  fut.addCallback proc(myFut: Future[PixBuf]) =
                    chatWindow.roomSelect.add:
                      gui:
                        RoomSelection:
                          roomName = name
                          roomId = id
                          pixBuf = myFut.read()
                          proc clicked(roomId: string) =
                            chatWindow.roomId = roomId
                except:
                  discard
              )
        else:
          chatWindow.roomSelect.add:
            gui:
              RoomSelection:
                roomName = room.name
                roomId = room.roomId
                proc clicked(roomId: string) =
                  chatWindow.roomId = roomId


  result = gui:
    Box:
      orient = OrientX
      ScrolledWindow {.expand: false.}:
        Box:
          orient = OrientY
          for room in chatWindow.roomSelect:
            insert(room) {.expand: false, hAlign: AlignStart.}
      ScrolledWindow {.expand: true.}:
        Box:
          orient = OrientY
          if chatWindow.roomId in chatWindow.messages:
            for i in chatWindow.messages[chatWindow.roomId].high.countdown(0):
              insert(chatWindow.messages[chatWindow.roomId][i]) {.expand: false.}

export ChatWindow, ChatWindowState
