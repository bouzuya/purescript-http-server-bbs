module Main (main) where

import Prelude

import Action as Action
import Bouzuya.HTTP.Server as Server
import Control.Bind (bindFlipped)
import Data.Int as Int
import Data.Maybe as Maybe
import Effect (Effect)
import Effect.Aff as Aff
import Effect.Class as Class
import Effect.Console as Console
import Node.Process as Process
import Store as Store

readPort :: Int -> Effect Int
readPort defaultPort =
  map
    (Maybe.fromMaybe defaultPort)
    (map (bindFlipped Int.fromString) (Process.lookupEnv "PORT"))

main :: Effect Unit
main = Aff.launchAff_ do
  store <- Store.newStore { messages: [], threads: [] }
  port <- Class.liftEffect (readPort 8080)
  let config = { hostname: "0.0.0.0", port }
  Class.liftEffect
    (Server.run
      config
      (Console.log "listen")
      (\request -> Action.execute { request, store }))
