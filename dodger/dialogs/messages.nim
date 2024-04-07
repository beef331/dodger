import pkg/owlkettle

import ../protocol/rooms

viewable Message:
  eventId: string
  sender: string
  message: string
  buffer: TextBuffer


method view*(msg: MessageState): Widget =
  if msg.buffer.isNil:
    msg.buffer = newTextBuffer()
    msg.buffer.text = msg.sender & ": \n" & msg.message
  gui:
    TextView:
      buffer = msg.buffer
      editable = false
      wrapMode = WrapWord

type Msg* = Message

export MessageState
