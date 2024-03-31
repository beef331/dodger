import std/macros
template queryName*(s: string) {.pragma.}

proc toQuery*(val: auto): string = $val

proc toQuery*(obj: object): string =
  for name, field in obj.fieldPairs:
    const theName =
      when field.hasCustomPragma(queryName):
        field.getCustomPragmaVal(queryName)
      else:
        name
    let query = field.toQuery()
    if query.len > 0:
      result.add name & "=" & query
      result.add "&"
  if result[^1] == '&':
    result.setLen(result.high)
