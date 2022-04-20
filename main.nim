import jester
import jsony
import std/sets
#import std/math
  
type Customizations = object
  apiversion: string
  author: string
  color: string
  head: string
  tail: string
  version: string

type RoyaleSettings = object
  shrinkEveryNTurns: int

type SquadSettings = object
  allowBodyCollisions: bool
  sharedElimination: bool
  sharedHealth: bool
  sharedLength: bool
  
type RulesetSettings = object
  foodSpawnChance: int
  minimumFood: int
  hazardDamagePerTurn: int
  hazardMap: string
  hazardMapAuthor: string
  royale: RoyaleSettings
  squad: SquadSettings
  
type Ruleset = object
  name: string
  version: string
  settings: RulesetSettings
  
type GameObject = object
  id: string
  ruleset: Ruleset
  timeout: int
  source: string

type Coord = object
  x: int
  y: int

type BattleSnake = object
  id: string
  name: string
  health: int
  body: seq[Coord]
  latency: string
  head: Coord
  length: int
  shout: string
  squad: string
  customizations: Customizations
  
type Board = object
  height: int
  width: int
  food: seq[Coord]
  hazards: seq[Coord]
  snakes: seq[BattleSnake]
  
type Game = object
  game: GameObject
  turn: int
  board: Board
  you: BattleSnake

type Move = object
  move: string
  shout: string

var game: Game 
  
proc snakeProperties(): Customizations =
  result.apiversion = "1"
  result.author = "sotolf"
  result.color = "#A3BE8C"
  result.head = "caffeine"
  result.tail = "round-bum"
  result.version = "0.0.1 beta"

proc `+`(this: Coord, other: Coord): Coord =
  return Coord(x: this.x + other.x, y: this.y + other.y)

proc manhattan(this: Coord, other: Coord): int =
  abs(this.x - other.x) + abs(this.y - other.y)

proc findClosestFood(): Coord =
  let head = game.you.head
  var foods = game.board.food
  var shortestDistance = game.board.height + game.board.width

  for food in foods:
    let distance = manhattan(head, food)
    if distance < shortestDistance:
      result = food

const 
  left  = Coord(x: -1, y: 0)
  right = Coord(x: 1, y: 0)
  up    = Coord(x: 0, y: 1)
  down  = Coord(x: 0, y: -1)

proc toDirection(co: Coord): string =
  if co == up:
    return "up"
  if co == down:
    return "down"
  if co == right:
    return "right"
  if co == left:
    return "left"
  else:
    doAssert(true, "unreachable")

proc isOkay(coord: Coord): bool =
  # is not on a snake
  let board = game.board
  for snake in board.snakes:
    if coord in snake.body:
      return false
    if coord == snake.head:
      return false

  # is not a hazard
  if coord in board.hazards:
    return false

  # is not outside the board
  if coord.x < 0 or coord.y < 0:
    return false
  if coord.x >= board.width:
    return false
  if coord.y >= board.height:
    return false

  # if everything is okay the cell is okay
  return true
  

proc moveTowards(head: Coord, goal: Coord): string =
  var poss: Coord
  # lower than goal
  if head.y < goal.y:
    poss = head + up
    if poss.isOkay():
      return "up"

  # higher than goal
  if head.y > goal.y:
    poss = head + down
    if poss.isOkay():
      return "down"

  # more right than goal
  if head.x > goal.x:
    poss = head + left
    if poss.isOkay():
      return "left"

  # more left than goal
  if head.x < goal.x:
    poss = head + right
    if poss.isOkay():
      return "right"

  # if none found go in first okay direction
  for direction in [up, down, left, right]:
    poss = head + direction
    if poss.isOkay():
      return direction.toDirection()
  
    

proc makeMove(): Move =
  let head = game.you.head
  let goal = findClosestFood()
  let direction = head.moveTowards(goal)
  result.move = direction
  result.shout = $goal



routes:
  get "/":
    let snakeProperties = snakeProperties()
    resp(Http200, toJson(snakeProperties))

  post "/start":
    game = request.body.fromJson(Game)
    resp(Http200, $request)

  post "/move":
    game = request.body.fromJson(Game)
    echo "Turn: " & $game.turn
    var move = makeMove()
    echo $toJson(move)
    resp(Http200, toJson(move), contentType="application/json")
    

  post "/end":
    game = request.body.fromJson(Game)
    resp(Http200, "Ended")