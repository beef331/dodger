import pkg/sunny

type
  HomeServerInformation* = object
    url*: string

  IdentityServerInformation* = object
    baseUrl* {.json"base_url".}: string

  DiscoveryInformation* = object
    homeserver {.json"m.homeserver".}: HomeServerInformation
    identityServer {.json"identity_server".}: IdentityServerInformation
