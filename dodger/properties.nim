import owlkettle

viewable Property:
  name: string
  child: Widget

method view*(property: PropertyState): Widget =
  result = gui:
    Box:
      orient = OrientX
      spacing = 6

      Label:
        text = property.name
        xAlign = 0

      insert(property.child) {.expand: false.}

proc add*(property: Property, child: Widget) =
  property.hasChild = true
  property.valChild = child

export PropertyState, Property
