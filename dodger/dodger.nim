import owlkettle
import dialogs/login
import std/[asyncdispatch]
import matrix

viewable App:
  currView: Widget

method view(app: AppState): Widget =
  if app.currView.isNil:
    app.currView = Login()
  result = gui:
    Window:
      title = "Users"
      Box:
        insert(app.currView)


brew(gui(App()))
