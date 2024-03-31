import requestobjs
import pkg/sunny


const wellKnownUrl* = "https://$#/.well-known/matrix/client"


type
  Server* = object
    baseUrl* {.json:"base_url,required".}: string
  DiscoveryResponse* = object
    homeserver* {.json:"m.homeserver, required".}: string
    identityServer* {.json:"m.identity_server, required".}: string


proc discoverRequest*(name: string): Request[DiscoveryResponse] =
  let
    ind = name.find(':')
    domain = name[ind..^1]
  Request[DiscoveryResponse](
    url: wellKnownUrl % domain,
    reqMethod: HttpGet
  )
