###
interface:

in can be whatever lol
  check: (in) ->
    # do stuff
    return result

result is any of four forms:
yes -> parsed fully including char, move onto next in sequence or collect
'' -> parsed fully NOT including char, move onto next in sequence or
  collect, and retry current char
no -> parse failed
this -> intermediate stage of parsing

when finished parsing, return something
  collect: (obj) ->
    # accept object, return some result, idgaf what
    return parseResult

if there's no more input, check if parsing can be terminated successfully
  finishable: ->
    # for example, if we're trying to parse a double, we can't allow it to end
    # on a period ("234." doesn't make sense as a number), so this tells us
    # whether the parse completed successfully; we call collect if so. returns
    # yes or no.
    return canBeCompleted
###

# parse single numbers (primitive?)
class NumParser
  check: (ch) ->
    if ch.match /[0-9]/
      @collect = -> ch
      yes
    else
      @err = -> ch
      no

  finishable: -> yes

class LetterParser
  check: (ch) ->
    if ch.match /[a-zA-Z]/
      @collect = -> ch
      yes
    else
      @err = -> ch
      no

  finishable: -> yes

class MetaParserBase
  # @p is inner parser
  constructor: (collect, err) ->
    @inputs = []
    @collectFun = collect?.bind(@)
    @errFun = err?.bind(@)

  collect: ->
    @cleanup?()
    if @collectFun
      @collectFun()
    else
      @inputs.join ''

  err: ->
    if @errFun
      @errFun()
    else
      @inputs.join ''

# make lowEnd 0 and highEnd null for *
# make lowEnd 0 and highEnd 1 for ?
# make lowEnd 1 and highEnd null for +
# make lowEnd 3 and highEnd 5 for {3,5}
class MakeRange extends MetaParserBase
  constructor: (@p, @lowEnd, @highEnd, collect, err) ->
    if (@lowEnd and @highEnd and (@lowEnd > @highEnd)) or
       (@highEnd and @highEnd < 1)
      throw new Error "you can't do that"
    super collect, err

  check: (ch) ->
    res = @p.check ch
    if res is yes
      @inputs.push @p.collect()
      if @highEnd and @inputs.length is @highEnd
        yes
      else @
    else if res is no
      if @lowEnd and @inputs.length < @lowEnd
        no
      else ''
    else @

  finishable: ->
    @inputs.length >= @lowEnd and @p.finishable()

# this emulates the + operator
p = new MakeRange new NumParser, 1, null, -> JSON.parse @inputs.join('')

res = no
for ch in '1234'
  res = p.check ch
  if res is no
    console.error p.err()
    process.exit 1
  else if res is yes
    console.log p.collect()
    process.exit 0

if p.finishable()
  console.log p.collect()
else
  console.error p.err()

lp = new MakeRange new LetterParser, 1, null, -> @inputs.join '-'

lRes = no
for ch in 'abcd'
  lRes = lp.check ch
  if lRes is no
    console.error lp.err()
    process.exit 1
  else if lRes is yes
    console.log lp.collect()
    process.exit 0

if lp.finishable()
  console.log lp.collect()
else
  console.error lp.err()

# next let's do functions to transform string literals, then seq, then or, then
# (from that) regex transformation

class MakeSeq extends MetaParserBase
  constructor: (@pArr, collect, err) ->
    super collect, err
    @curParserIndex = 0

  check: (ch) ->
    curParser = @pArr[@curParserIndex]
    res = curParser.check ch
    if res is yes
      if @cleanup() then @ else yes
    else if res is no
      @cleanup()
      no
    else if res is ''
      if @cleanup() then @check ch else ''
    else @

  cleanup: ->
    if @curParserIndex < @pArr.length
      curParser = @pArr[@curParserIndex]
      @inputs.push curParser.collect()
      ++@curParserIndex
      return @curParserIndex < @pArr.length
    else no

  finishable: ->
    @curParserIndex is @pArr.length - 1 and @pArr[@curParserIndex].finishable()

intThenWordParser =
  new MakeSeq([
    new MakeRange new NumParser, 1, null
    new MakeRange new LetterParser, 1, null
    ],
    # @inputs is an array of two arrays
    -> @inputs.join '-')

newRes = no
for ch in '1234abc'
  newRes = intThenWordParser.check ch
  if newRes is no
    console.error intThenWordParser.err()
    process.exit 1
  else if newRes is yes
    console.log intThenWordParser.collect()
    process.exit 0

if intThenWordParser.finishable()
  console.log intThenWordParser.collect()
else
  console.error intThenWordParser.err()
