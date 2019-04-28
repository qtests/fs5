{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE MultiParamTypeClasses      #-}

module Model where

import Data.ByteString (ByteString)
import Data.Text (Text)
import Database.Persist.Quasi
import Yesod
import Data.Typeable (Typeable)

import Data.Time
import Data.Pool (Pool(..))

import Control.Monad.Trans.Reader (ReaderT)
import Database.Persist.Sql (SqlBackend, ConnectionPool, runSqlPool)
import Control.Monad.Logger (LoggingT, runStderrLoggingT)
import Control.Monad.Trans.Resource (ResourceT, runResourceT)
import Data.Maybe (fromJust, isJust)

share [mkPersist sqlSettings, mkMigrate "migrateAll"]
    $(persistFileWith lowerCaseSettings "config/models")



dbFunction :: ReaderT SqlBackend (LoggingT (ResourceT IO)) a -> Pool SqlBackend  -> IO a
dbFunction query pool = runResourceT $ runStderrLoggingT $ runSqlPool query pool


getAllFilesNames :: ReaderT SqlBackend (LoggingT (ResourceT IO)) ( [Text] )
getAllFilesNames = do 
    tsRecords <- selectList [] []
    return $ fmap(\(Entity _ (StoredFile name _ _ _ _ _) ) ->  name ) tsRecords
 