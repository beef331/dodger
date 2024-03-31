import pkg/[owlkettle, ponairi]
import std/[asyncdispatch]
import asyncrequests
import ../protocol/[requestobjs, syncs]

viewable ChatWindow:
  val: int

method view(chatWindow: ChatWindowState): Widget =
  result = gui:
    Box:
      Label:
        text = "hellow world"

export ChatWindow, ChatWindowState
