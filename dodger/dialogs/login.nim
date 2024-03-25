import pkg/[owlkettle, matrix]
import ../properties
import std/[asyncdispatch, uri]


viewable Login:
  homeserver: string = "https://matrix.org"
  name: string
  pass: string
  client: AsyncMatrixClient
  req: typeof(login(AsyncMatrixClient(), "", ""))
  timeout: EventDescriptor


method view*(login: LoginState): Widget =

  proc asyncHandler(): bool =
    if hasPendingOperations():
      try:
        poll(0)
      except CatchableError as e:
        echo e.msg
    discard login.redraw()
    result = true # Do not remove event

  gui:
    Box:
      orient = OrientY
      spacing = 6
      margin = 12

      Property {.expand: false.}:
        name = "homeserver"
        Entry:
          text = login.homeserver
          proc changed(server: string) =
            login.homeserver = server

      Property {.expand: false.}:
        name = "Name"
        Entry:
          text = login.name
          proc changed(name: string) =
            login.name = name

      Property {.expand: false.}:
        name = "Password"
        Entry:
          text = login.pass
          visibility = false
          proc changed(pass: string) =
            login.pass = pass
            for i in 0..<pass.len:
              pass[i].addr[] = '\0'

      Button {.expand: false.}:
        text = "Login"
        sensitive = login.name.len > 0 and login.pass.len > 0 and login.homeserver.len > 0
        proc clicked() =
          login.client = newAsyncMatrixClient(login.homeserver)
          login.req = login.client.login(login.name, login.pass)
          login.req.addCallback proc(fut: typeof(login.req)) =
            let val = fut.read
            echo val
          login.timeout = addGlobalIdleTask(asyncHandler)
          for i in 0..<login.pass.len:
              login.pass[i].addr[] = '\0'
          echo waitFor login.req


export Login, LoginState
