{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE DataKinds #-}

module Applications where

import qualified Records as Rec
import Require.Deps as Req
import Require.Logger
import Require.Async

-------------------------Api types--------------------------------------
type GeneralApi =
    "users" :> "of" :> Capture "organisation" Int :> Post '[ JSON ] [ Rec.User ]
    :<|>
    "new" :> "user" 

----------------------------- Applications ---------------------------------
app1 :: Application
app1 = serve proxy server
    where 
        proxy :: Proxy GeneralApi
        proxy = Proxy

        server :: Server GeneralApi
        server = 
            usersOfOrg
            where
                usersOfOrg :: Int -> Handler [ Rec.User ]
                usersOfOrg index = liftIO $ do
                    Req.putStrLn $ Req.pack "getting list of users here"
                    return []
