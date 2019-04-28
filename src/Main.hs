{-# LANGUAGE OverloadedStrings #-}

-- | This module initializes the application's state and starts the warp server.
module Main where
-- import Control.Concurrent.STM
-- import Data.IntMap

import Servant

import Yesod
import Database.Persist.Sql
import Data.Text
import Data.Pool (Pool(..))


import Dispatch ()
import Foundation
import Config
import Model (migrateAll, getAllFilesNames, dbFunction)
import API

import System.ReadEnvVar (lookupEnvDef, readEnvDef)
import Control.Monad.Trans.Resource (ResourceT, runResourceT)
import Control.Monad.Logger (LoggingT, runStderrLoggingT)


appAPIServerMock :: [Text] -> Server AppAPI
appAPIServerMock servData  = return $ toJSON servData

main :: IO ()
main = do
   
    persistConfig <- perstConfig

    pool <- createPoolConfig persistConfig 
    runResourceT $ runStderrLoggingT $ flip runSqlPool pool $ runMigration migrateAll

    fileNames <- dbFunction getAllFilesNames pool
    let api = serve appAPIProxy (appAPIServerMock fileNames)

    -- Initialize the filestore to an empty map.
    --tstore <- atomically $ newTVar empty

    -- The first uploaded file should have an ID of 0.
    -- tident <- atomically $ newTVar 0

    -- warpEnv starts the Warp server over a port defined by an environment
    -- variable. To launch the app on a specific port use 'warp'.
    -- warpEnv $ App tident tstore

    port <- readEnvDef "PORT" 8080
    -- warp port $ App tident tstore pool persistConfig
    warp port $ App pool persistConfig (EmbeddedAPI api)
