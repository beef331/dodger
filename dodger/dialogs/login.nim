import pkg/owlkettle
import ../properties, ../protocol/[logins, identifiers]
import asyncrequests
import std/[asyncdispatch, strutils]
import errors


viewable Login:
  name: string
  pass: string
  device: string
  proc onLogin(ctx: UserContext)

method view*(login: LoginState): Widget =
  gui:
    Box:
      orient = OrientY
      spacing = 6
      margin = 12

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

      Property {.expand: false.}:
        name = "Device"
        Entry:
          text = login.device
          placeholder = "Optional name for this device"
          proc changed(device: string) =
            login.device = device

      Button {.expand: false.}:
        text = "Login"
        sensitive = login.name.len > 0 and login.pass.len > 0
        proc clicked() =
          proc loginRequest() {.async.} =
            let userInfo = login.name.split(':')
            if userInfo.len == 0:
              errorDialog(login):
                "No Homeserver provided."
              return

            let
              name = userInfo[0]
              homeserver = userInfo[1]
              val = await UserContext(homeserver: homeserver).handleRequest(login(Identifier(kind: User, user: name), login.device, login.pass))
            login.onLogin.callback(UserContext(homeserver: homeserver, token: val.accessToken))
          asyncCheck loginRequest()

export Login, LoginState
