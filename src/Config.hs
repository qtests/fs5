
{-# LANGUAGE OverloadedStrings #-}

-- |This module defines how the 'persistent' library's back end is configured.
-- Other modules should not import anything Sqlite-specific
module Config where

-- import Database.Persist.Sqlite
import  Database.Persist.Postgresql


persistConfig :: PostgresConf
persistConfig = PostgresConf "host=localhost dbname=mydb user=mydbuser password=mydbpass port=5432" 100
-- persistConfig = PostgresConf "postgres://mydbuser:mydbpass@localhost:5432/mydb" 100




