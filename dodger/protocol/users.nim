import pkg/sunny
import requestobjs
import std/strutils

type
  AvatarResponse* = object
    url* {.json"avatar_url".}: string

  DisplayNameResponse* = object
    name* {.json"displayname".}: string

proc avatarUrlRequest*(name: string): Request[AvatarResponse] =
  Request[AvatarResponse](
    url: "/_matrix/client/v3/profile/$#/avatar_url" % name,
    reqMethod: HttpGet
  )

proc displayNameRequest*(name: string): Request[DisplayNameResponse] =
  Request[DisplayNameResponse](
    url: "/_matrix/client/v3/profile/$#/displayname" % name,
    reqMethod: HttpGet
  )
