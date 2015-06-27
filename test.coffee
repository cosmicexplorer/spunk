require("babel").transform "code", optional: ["runtime"]

parser =
  convertStrToFn: (strOrFn) ->
    if typeof strOrFn is 'string'
      statusIndex = Symbol()
      this[statusIndex] =
        string: strOrFn
        index: 0
      (str) =>
        strObj = this[statusIndex]
        for ch in str
          if ch is strObj.string[strObj.index]
            ++strObj.index
          else
            strObj.index = 0
            return no
        if strObj.index is strObj.string.length
          return yes
        else
          return no
    else
      return strOrFn

  plus: (strOrFn) ->
    strOrFn = @convertStrToFn strOrFn
    statusIndex = Symbol()
    this[statusIndex] =
      fn: strOrFn
      index: 0
    (str) =>
      fnObj = this[statusIndex]
      res = fnObj str
      if res
        ++fnObj.index
      else if fnObj.index > 0
        return yes


  "or": (strOrFnArr) ->
    (char) ->
      strArr.indexOf char isnt -1

  seq: (strOrFnArr) ->

  digits: @or [
    '0'
    '1'
    '2'
    '3'
    '4'
    '5'
    '6'
    '7'
    '8'
    '9'
    ]

# /[0-9]+|\.[0-9]+|[0-9+]\.[0-9]+/
doubleParser = ->
  @seq [
      @or [
        @plus @digits
        [
          "."
          @plus @digits
          ]
        [
          @plus @digits
          "."
          @plus @digits
          ]
        ]
    ]

console.log doubleParser.toString()
console.log Symbol('foo')
