module Store
  ( Store
  , createMessage
  , createThread
  , getMessage
  , getThread
  , listMessage
  , listMessageInThread
  , listThread
  , newStore
  ) where

import Prelude

import Bouzuya.DateTime.Formatter.DateTime as DateTimeFormatter
import Bouzuya.UUID.V4 as UUIDv4
import Data.Array as Array
import Data.Maybe (Maybe)
import Effect.Aff (Aff)
import Effect.Class as Class
import Effect.Now as Now
import Effect.Ref (Ref)
import Effect.Ref as Ref
import Record as Record
import Type (AppData, Message, MessageParams, ThreadParams, Thread)

newtype Store a = Store (Ref a)

createMessage :: MessageParams -> Store AppData -> Aff Message
createMessage params (Store ref) = Class.liftEffect do
  id <- map UUIDv4.toString UUIDv4.generate
  created_at <- map DateTimeFormatter.toString Now.nowDateTime
  let message' = Record.merge params { created_at, id }
  _ <- Ref.modify (\d -> d { messages = d.messages <> [message'] }) ref
  pure message'

createThread :: ThreadParams -> Store AppData -> Aff Thread
createThread params (Store ref) = Class.liftEffect do
  id <- map UUIDv4.toString UUIDv4.generate
  created_at <- map DateTimeFormatter.toString Now.nowDateTime
  let thread' = Record.merge params { created_at, id }
  _ <- Ref.modify (\d -> d { threads = d.threads <> [thread'] }) ref
  pure thread'

getMessage :: String -> Store AppData -> Aff (Maybe Message)
getMessage id (Store ref) = Class.liftEffect do
  map ((Array.find ((eq id) <<< _.id)) <<< _.messages) (Ref.read ref)

getThread :: String -> Store AppData -> Aff (Maybe Thread)
getThread id (Store ref) = Class.liftEffect do
  map ((Array.find ((eq id) <<< _.id)) <<< _.threads) (Ref.read ref)

listMessage :: Store AppData -> Aff (Array Message)
listMessage (Store ref) = Class.liftEffect (map _.messages (Ref.read ref))

listMessageInThread :: String -> Store AppData -> Aff (Array Message)
listMessageInThread threadId (Store ref) =
  Class.liftEffect
    (map
      ((Array.filter ((eq threadId) <<< _.thread_id)) <<< _.messages)
      (Ref.read ref))

listThread :: Store AppData -> Aff (Array Thread)
listThread (Store ref) = Class.liftEffect (map _.threads (Ref.read ref))

newStore :: AppData -> Aff (Store AppData)
newStore x = Class.liftEffect (map Store (Ref.new x))
