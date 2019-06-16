module Middleware.Routing
  ( middleware
  ) where

import Prelude

import Bouzuya.HTTP.Method as Method
import Bouzuya.HTTP.StatusCode as StatusCode
import Data.Maybe as Maybe
import Middleware.PathNormalize as MiddlewarePathNormalize
import NormalizedPath as NormalizedPath
import Record as Record
import ResponseHelper as ResponseHelper
import Simple.JSON as SimpleJSON
import Store (Store)
import Store as Store
import Type (AppData, MessageParams, Middleware, ThreadParams)

type R1 r = (store :: Store AppData | r)
type R2 r = MiddlewarePathNormalize.R r

middleware :: forall r r'. Middleware (R2 (R1 r)) r'
middleware
  _
  { normalizedPath
  , request: { method, body }
  , store
  } = do
  case NormalizedPath.toPieces normalizedPath of
    ["messages"] ->
      case method of
        Method.GET -> (Store.listMessage store) >>= ResponseHelper.fromJSON
        Method.POST -> do
          case (SimpleJSON.readJSON_ body :: _ MessageParams) of
            Maybe.Nothing ->
              -- TODO: error message
              ResponseHelper.fromStatus StatusCode.status400 []
            Maybe.Just params -> do
              (Store.createMessage params store) >>= ResponseHelper.fromJSON
        _ -> ResponseHelper.status405 [Method.GET, Method.POST]
    ["messages", messageId] ->
      case method of
        Method.GET -> do
          messageMaybe <- Store.getMessage messageId store
          case messageMaybe of
            Maybe.Nothing -> ResponseHelper.status404
            Maybe.Just message -> ResponseHelper.fromJSON message
        _ -> ResponseHelper.status405 [Method.GET]
    ["threads"] ->
      case method of
        Method.GET -> (Store.listThread store) >>= ResponseHelper.fromJSON
        Method.POST -> do
          case (SimpleJSON.readJSON_ body :: _ ThreadParams) of
            Maybe.Nothing ->
              -- TODO: error message
              ResponseHelper.fromStatus StatusCode.status400 []
            Maybe.Just params -> do
              (Store.createThread params store) >>= ResponseHelper.fromJSON
        _ -> ResponseHelper.status405 [Method.GET, Method.POST]
    ["threads", threadId] ->
      case method of
        Method.GET -> do
          threadMaybe <- Store.getThread threadId store
          case threadMaybe of
            Maybe.Nothing -> ResponseHelper.status404
            Maybe.Just thread -> ResponseHelper.fromJSON thread
        _ -> ResponseHelper.status405 [Method.GET]
    ["threads", threadId, "messages"] ->
      case method of
        Method.GET ->
          (Store.listMessageInThread threadId store) >>= ResponseHelper.fromJSON
        Method.POST -> do
          case (SimpleJSON.readJSON_ body :: _ { content :: String }) of
            Maybe.Nothing ->
              -- TODO: error message
              ResponseHelper.fromStatus StatusCode.status400 []
            Maybe.Just params -> do
              created <-
                Store.createMessage
                  (Record.merge params { thread_id: threadId })
                  store
              ResponseHelper.fromJSON created
        _ -> ResponseHelper.status405 [Method.GET, Method.POST]
    [] ->
      case method of
        Method.GET -> ResponseHelper.fromStatus StatusCode.status200 []
        _ -> ResponseHelper.status405 [Method.GET]
    _ -> ResponseHelper.status404
