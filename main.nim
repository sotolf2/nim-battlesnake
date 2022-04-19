import jester
import jsony

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

proc snakeProperties(): Customizations =
  result.apiversion = "1"
  result.author = "sotolf"
  result.color = "#A3BE8C"
  result.head = "caffeine"
  result.tail = "round-bum"
  result.version = "0.0.1 beta"

proc makeMove(): Move =
  result.move = "Up"
  result.shout = "Going Up"

var game: Game 

routes:
  get "/":
    let snakeProperties = snakeProperties()
    resp(Http200, toJson(snakeProperties))

  post "/start":
    game = request.body.fromJson(Game)
    resp(Http200, $request)

  post "/move":
    game = request.body.fromJson(Game)
    var move = makeMove()
    echo $game.you.head
    resp(Http200, toJson(move))

  post "/end":
    game = request.body.fromJson(Game)
    resp(Http200, "Ended")