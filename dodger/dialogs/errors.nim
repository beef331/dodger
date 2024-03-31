import pkg/owlkettle

viewable ErrorDialog:
  msg: string

method view*(err: ErrorDialogState): Widget =
  result = gui:
    Dialog:
      title = "Error"
      defaultSize = (320, 0)
      Box:
        Label:
          text = err.msg

template errorDialog*(app: auto, message: string) =
  discard app.open(gui(ErrorDialog(msg = message)))

export ErrorDialogState, ErrorDialog
