import htmlgen
import jester
import jsony

type BattleSnake = object
  apiversion: string
  author: string
  color: string
  head: string
  tail: string
  version: string

proc snakeProperties(): BattleSnake =
  result.apiversion = "1"
  result.author = "sotolf"
  result.color = "#cccccc"
  result.head = "default"
  result.tail = "default"
  result.version = "0.0.1 beta"
  
routes:
  get "/":
    let snakeProperties = snakeProperties()
    resp(Http200, toJson(snakeProperties))