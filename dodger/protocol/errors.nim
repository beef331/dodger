type
  ErrorKind* = enum
    Nothing
    Forbidden = "M_FORBIDDEN"
    UnknownToken = "M_UNKNOWN_TOKEN"
    MissingToken = "M_MISSING_TOKEN"
    BadJson = "M_BAD_JSON"
    NotJson = "M_NOT_JSON"
    NotFound = "M_NOT_FOUND"
    LimitExceeded = "M_LIMIT_EXCEEDED"
    Unrecognized = "M_UNRECOGNIZED"
    Unknown = "M_UNKNOWN"
    Unauthorised = "M_UNAUTHORIZED"
    UserDeactivated = "M_USER_DEACTIVATED"
    InvalidUserName = "M_INVALID_USERNAME"
    RoomInUse = "M_ROOM_IN_USE"
    InvalidRoomState = "M_INVALID_ROOM_STATE"
    ThreePidNotFound = "M_THREEPID_NOT_FOUND"
    ThreePidAuthFailed = "M_THREEPID_AUTH_FAILED"
    ThreePidDenied = "M_THREEPID_DENIED"
    ServerNotTrusted = "M_SERVER_NOT_TRUSTED"
    UnsupportedRoomVersion = "M_UNSUPPORTED_ROOM_VERSION"
    IncompatibleRoomVersion = "M_INCOMPATIBLE_ROOM_VERSION"
    BadState = "M_BAD_STATE"
    GuestAccessForbidden = "M_GUESS_ACCESS_FORBIDDEN"
    CaptchaNeeded = "M_CAPTCHA_NEEDED"
    CaptchaInvalid = "M_CAPTCHA_INVALID"
    MissingParam = "M_MISSING_PARAM"
    InvalidParam = "M_INVALID_PARAM"
    TooLarge = "M_TOO_LARGE"
    Exclusive = "M_EXCLUSIVE"
    ResourceLimitExceeded = "M_RESOURCE_LIMIT_EXCEEDED"
    CannotLeaveServerNoticeRoom = "M_CANNOT_LEAVE_SERVER_NOTICE_ROOM"


  MatrixError* = object of CatchableError
    kind*: ErrorKind
