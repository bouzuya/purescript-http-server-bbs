module Middleware.Logging
  ( middleware
  ) where

import Prelude

import Bouzuya.DateTime.Formatter.DateTime as DateTimeFormatter
import Data.String as String
import Effect.Class as Class
import Effect.Class.Console as Console
import Effect.Now as Now
import Type (Middleware)

middleware :: forall r. Middleware r r
middleware next context@{ request: { method, pathname } } = do
  dt <- Class.liftEffect (map DateTimeFormatter.toString Now.nowDateTime)
  Console.log (String.joinWith " " [dt, show method, pathname])
  response <- next context
  pure response
