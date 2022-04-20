import jester
import jsony
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

proc moveTowards(head: Coord, goal: Coord): string =
  if head.x < goal.x and Coord(x: head.x+1, y: head.y) notin game.you.body:
    return "right"
  if head.x > goal.x and Coord(x: head.x-1, y: head.y) notin game.you.body:
    return "left"
  if head.y < goal.y and Coord(x: head.x, y: head.y + 1) notin game.you.body:
    return "up"
  if head.y > goal.y and Coord(x: head.x, y: head.y - 1) notin game.you.body:
    return "down"

  else:
    return "up"
    

proc makeMove(): Move =
  let head = game.you.head
  let goal = findClosestFood()
  let direction = moveTowards(head, goal)
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