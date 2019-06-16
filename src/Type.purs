module Type
  ( AppData
  , Message
  , MessageParams
  , Middleware
  , NewHandler
  , Thread
  , ThreadParams
  ) where

import Bouzuya.HTTP.Request (Request)
import Bouzuya.HTTP.Response (Response)
import Effect.Aff (Aff)

type Middleware a b = NewHandler b -> NewHandler a
type NewHandler r = Record (request :: Request | r) -> Aff Response

type AppData =
  { messages :: Array Message
  , threads :: Array Thread
  }

type Message =
  { content :: String
  , created_at :: String
  , id :: String
  , thread_id :: String
  }

type MessageParams =
  { content :: String
  , thread_id :: String
  }

type Thread =
  { content :: String
  , created_at :: String
  , id :: String
  , title :: String
  }

type ThreadParams =
  { content :: String
  , title :: String
  }
