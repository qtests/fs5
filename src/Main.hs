{-# LANGUAGE OverloadedStrings #-}

-- | This module initializes the application's state and starts the warp server.
module Main where

import Control.Concurrent.STM
import Data.IntMap
import Yesod
import Database.Persist.Sql

import Control.Monad.Logger
import Control.Monad.Trans.Resource
import Dispatch ()
import Foundation
import Config
import Model (migrateAll)

main :: IO ()
main = do
    pool <- createPoolConfig persistConfig
    runResourceT $ runStderrLoggingT $ flip runSqlPool pool $ runMigration migrateAll
    -- Initialize the filestore to an empty map.
    tstore <- atomically $ newTVar empty
    -- The first uploaded file should have an ID of 0.
    tident <- atomically $ newTVar 0
    -- warpEnv starts the Warp server over a port defined by an environment
    -- variable. To launch the app on a specific port use 'warp'.
    -- warpEnv $ App tident tstore
    warpEnv $ App tident tstore pool
