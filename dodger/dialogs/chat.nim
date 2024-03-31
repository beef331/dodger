import pkg/[owlkettle, ponairi, sunny]
import std/[asyncdispatch, uri, os, strutils]
import asyncrequests
import ../protocol/[requestobjs, syncs, rooms]
import ../database/datas

viewable RoomSelection:
  roomId: string
  avatarUrl: string
  roomName: string
  pixbuf: PixBuf

method view(select: RoomSelectionState): Widget =
  if select.pixbuf != nil:
    gui(Picture(pixbuf = select.pixbuf))
  else:
    gui(Label(text = select.roomName))


viewable ChatWindow:
  roomId: string
  roomName: string
  db: DbConn
  context: UserContext
  roomSelect: seq[RoomSelection]
  inited: bool

method view(chatWindow: ChatWindowState): Widget =
  if not chatWindow.inited:
    chatWindow.inited = true
    for room in chatWindow.db.find(seq[RoomData], sql"SELECT * FROM ROOMDATA"):
      if room.avatar != "":
        let avatarData = AvatarData.fromJson(room.avatar)
        if avatarData.url != "":
          let
            ext =
              if '/' in avatarData.info.mimetype:
                avatarData.info.mimetype.split"/"[1]
              else:
                "jpeg"
          let downloadFut = downloadMxcToCache(chatWindow.context, avatarData.url, ext)
          downloadFut.addCallback(proc() =
            try:
              let fut = try:
                loadPixBufAsync(avatarData.url.mxcToPath(ext))
              except CatchableError as e:
                return
              fut.addCallback proc(myFut: Future[PixBuf]) =
                chatWindow.roomSelect.add gui(RoomSelection(roomId = room.roomId, pixBuf = myFut.read()))
            except:
              discard
          )
      else:
        ##chatWindow.roomSelect.add gui(RoomSelection(roomId = room.roomId, roomName = room.name))



  result = gui:
    ScrolledWindow:
      Box:
        orient = OrientY
        for room in chatWindow.roomSelect:
          insert(room) {.expand: false.}

export ChatWindow, ChatWindowState
