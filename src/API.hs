{-# LANGUAGE TypeFamilies #-}

-- API
{-# LANGUAGE DataKinds             #-}
{-# LANGUAGE FlexibleInstances     #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings     #-}
{-# LANGUAGE TypeOperators         #-}
{-# LANGUAGE RecordWildCards       #-}

module API where

import Yesod

-- API
import Data.Text (Text)
import Network.Wai
import Servant
import Yesod.Core.Types



data EmbeddedAPI = EmbeddedAPI { eapiApplication :: Application
                               }
             
instance RenderRoute EmbeddedAPI where
  data Route EmbeddedAPI = EmbeddedAPIR ([Text], [(Text, Text)])
    deriving(Eq, Show, Read)
  renderRoute (EmbeddedAPIR t) = t

instance ParseRoute EmbeddedAPI where
  parseRoute t = Just (EmbeddedAPIR t)

  
instance Yesod master => YesodSubDispatch EmbeddedAPI master where
  yesodSubDispatch YesodSubRunnerEnv{..} req = resp
    where
      master = yreSite ysreParentEnv
      site = ysreGetSub master
      resp = eapiApplication site req
      


type AppAPI = "items" :> Get '[JSON] Value

                          
appAPIProxy :: Proxy AppAPI
appAPIProxy = Proxy