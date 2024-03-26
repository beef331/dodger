import errors
import std/[strutils, httpcore]
import sunny

export HttpMethod

type Request*[T] = object
  url*: string
  data*: string
  reqMethod*: HttpMethod
  when T isnot void:
    _: array[0, T] #Ensure body is unique

type MatrixRequestError* = object
  errcode*, error*: string

proc extract*[T](val: var T, data: string) =
  var err = MatrixRequestError.fromJson(data)
  if err.errcode != "":
    raise (ref MatrixError)(kind: parseEnum[ErrorKind](err.errcode), msg: err.error)
  else:
    val = T.fromJson(data)
