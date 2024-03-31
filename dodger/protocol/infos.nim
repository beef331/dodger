import pkg/sunny

type
  BaseInfo* = object of RootObj
    mimetype*: string
    size*: int

  ThumbnailInfo = object of BaseInfo
    height* {.json"h".}: int
    width* {.json"w".}: int

  ImageInfo* = object of ThumbnailInfo
    thumbnailInfo* {.json"thumbnail_info".}:  ThumbnailInfo
    thumbnailUrl* {.json"thumbnail_url".}:  string

  FileInfo* = object of ImageInfo

  AudioInfo* = object of BaseInfo
    duration*: int

  LocationInfo* = object
    thumbnailInfo* {.json"thumbnail_info".}:  ThumbnailInfo
    thumbnailUrl* {.json"thumbnail_url".}:  string

  VideoInfo* = object of ImageInfo
    duration*: int
