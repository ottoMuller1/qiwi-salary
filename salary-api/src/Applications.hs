{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE DataKinds #-}

module Applications where

import qualified Records as Rec
import Require.Deps
import Require.Logger
import Require.Async
import Database

-- extra
import qualified Data.Text as T
import qualified Data.Text.IO as TIO

-------------------------Api types--------------------------------------
type GeneralApi =
    -- user route
    "user" :> (
        -- get user
        Capture "userId" Int :>
        Header "Auth-token" Text :>
        Header "User-token" Text :>
        Post '[ JSON ] [ Rec.User ]
        :<|>

        -- creating new user
        "new" :> 
        Capture "second_name" Text :> 
        Capture "first_name" Text :> 
        Capture "father_name" Text :> 
        Header "Auth-token" Text :> 
        Post '[ PlainText ] Text
        :<|>

        -- deleting user
        "delete" :>
        Capture "user_id" Int :>
        Header "Auth-token" Text :>
        Header "User-hash" Text :>
        Post '[ PlainText ] Text
        :<|>

        -- getting all users
        "s" :>
        Header "Auth-token" Text :>
        Post '[ JSON ] [ Rec.User ]
        :<|>

        -- adding rate, currency, period and provider to user
        "desires" :>
        "of" :>
        Capture "user_id" Int :>
        "every" :>
        Capture "preiod" Double :>
        "for" :>
        Capture "rate" Double :>
        Capture "currency" Int :>
        "in" :>
        Capture "provider" Int :>
        Header "Auth-token" Text :>
        Header "User-hash" Text :>
        Post '[ PlainText ] Text
        :<|>

        -- adding card info
        "card" :> (
            "set" :>
            Capture "user_id" Int :>
            ReqBody '[ JSON ] Rec.Card :>
            Header "Auth-token" Text :>
            Header "User-hash" Text :>
            Post '[ PlainText ] Text
            :<|>

            "delete" :>
            Capture "user_id" Int :>
            Header "Auth-token" Text :>
            Header "User-hash" Text :>
            Post '[ PlainText ] Text
        )
    )
    :<|>

    -- payment route
    "pay" :>
    "to" :>
    Capture "user_id" Int :>
    Header "Auth-token" Text :>
    Header "User-token" Text :>
    Post '[ PlainText ] Text

----------------------------- Applications ---------------------------------
app1 :: Application
app1 = serve proxy server
    where 
        proxy :: Proxy GeneralApi
        proxy = Proxy

        server :: Server GeneralApi
        server = 
            (
                getUser :<|>
                newUser :<|>
                deleteUser :<|>
                allUsers :<|> 
                setDesires :<|> 
                ( setCard :<|> deleteCard ) 
            ) :<|>
            payTo 
            where
                getUser :: Int -> Maybe Text -> Maybe Text -> Handler [ Rec.User ]
                getUser userId token hash
                    | token == Nothing && hash == Nothing = liftIO (
                        writeLog WARNING ( "try to get user" ++ show userId ++ " -> no Auth-token or User-hash here" ) ) >>
                        throwError err404
                    | otherwise = do
                        verified <- liftIO $ do
                            ( token' : xs ) <- TIO.readFile "ADM" >>= return . T.lines
                            let Just token_ = token
                            return $ token_ == token'
                        if not verified 
                        then do 
                            liftIO $ writeLog WARNING $ "wrong token to get user " ++ show userId
                            throwError err404
                        else do
                            return []
                            -- db actions throw hash or error 500
    
                newUser :: Text -> Text -> Text -> Maybe Text -> Handler Text
                newUser sndName fstName fthName ( Just token ) = do
                    verified <- do
                        ( token' : xs ) <- liftIO $ TIO.readFile "ADM" >>= return . T.lines
                        return $ token == token'
                    if not verified 
                    then do 
                        liftIO $ writeLog WARNING "wrong token to add user" 
                        throwError err404
                    else do
                        liftIO $ writeLog SIMPLE $ "new user " ++ T.unpack sndName ++ " " ++ T.unpack fstName ++ " " ++ T.unpack fthName
                        return $ T.pack "well done!"
                        -- db actions or error 500
                newUser _ _ _ Nothing = liftIO (
                    writeLog WARNING "try to add user -> no Auth-token here" ) >>
                    throwError err404

                deleteUser :: Int -> Maybe Text -> Maybe Text -> Handler Text
                deleteUser userId token hash
                    | token == Nothing && hash == Nothing = liftIO (
                        writeLog WARNING ( "try to delete user " ++ show userId ++ " -> no Auth-token or User-hash here" ) ) >>
                        throwError err404
                    | otherwise = do
                        verified <- do
                            ( token' : xs ) <- liftIO $ TIO.readFile "ADM" >>= return . T.lines
                            let Just token_ = token
                            return $ token_ == token'
                        if not verified 
                        then do 
                            liftIO $ writeLog WARNING "wrong token to remove user" 
                            throwError err404
                        else do
                            liftIO $ writeLog IMPORTANT $ "user is well removed " ++ show userId
                            return $ T.pack "well done!"
                        -- db actions or error 500

                allUsers :: Maybe Text -> Handler [ Rec.User ]
                allUsers ( Just token ) = do
                    verified <- liftIO $ do
                        ( token' : xs ) <- TIO.readFile "ADM" >>= return . T.lines
                        return $ token == token'
                    if not verified 
                    then do 
                        liftIO $ writeLog WARNING "wrong token to get users "
                        throwError err404
                    else do
                        return []
                        -- db actions or error 500
                allUsers Nothing = liftIO (
                    writeLog WARNING "try to get users -> no Auth-token here" ) >>
                    throwError err404

                setDesires :: Int -> Double -> Double -> Int -> Int -> Maybe Text -> Maybe Text -> Handler Text
                setDesires userId period' rate' currency' provider' token hash
                    | token == Nothing && hash == Nothing = liftIO (
                        writeLog WARNING ( "try to set desires for " ++ show userId ++ " -> no Auth-token or User-hash here" ) ) >>
                        throwError err404
                    | otherwise = do
                        verified <- do
                            ( token' : xs ) <- liftIO $ TIO.readFile "ADM" >>= return . T.lines
                            let Just token_ = token
                            return $ token_ == token'
                        if not verified 
                        then do 
                            liftIO $ writeLog WARNING "wrong token to set desire" 
                            throwError err404
                        else do
                            liftIO $ writeLog IMPORTANT $ show userId ++ " has a desires now"
                            return $ T.pack "well done!"
                        -- db actions or error 500

                setCard :: Int -> Rec.Card -> Maybe Text -> Maybe Text -> Handler Text
                setCard userId ( Rec.Card nmb dt nmpTp bd ) token hash
                    | token == Nothing && hash == Nothing = liftIO (
                        writeLog WARNING ( "try to set card of " ++ show userId ++ " -> no Auth-token or User-hash here" ) ) >>
                        throwError err404
                    | otherwise = do
                        verified <- do
                            ( token' : xs ) <- liftIO $ TIO.readFile "ADM" >>= return . T.lines
                            let Just token_ = token
                            return $ token_ == token'
                        if not verified 
                        then do 
                            liftIO $ writeLog WARNING $ "wrong token to set card to " ++ show userId 
                            throwError err404
                        else do
                            liftIO $ writeLog IMPORTANT $ show userId ++ " has a card now"
                            return $ T.pack "well done!"
                        -- db actions or error 500

                deleteCard :: Int -> Maybe Text -> Maybe Text -> Handler Text
                deleteCard userId token hash
                    | token == Nothing && hash == Nothing = liftIO (
                        writeLog WARNING ( "try to delete card of " ++ show userId ++ " -> no Auth-token or User-hash here" ) ) >>
                        throwError err404
                    | otherwise = do
                        verified <- do
                            ( token' : xs ) <- liftIO $ TIO.readFile "ADM" >>= return . T.lines
                            let Just token_ = token
                            return $ token_ == token'
                        if not verified 
                        then do 
                            liftIO $ writeLog WARNING $ "wrong token to remove card of " ++ show userId
                            throwError err404
                        else do
                            liftIO $ writeLog IMPORTANT $ show userId ++ " card is removed"
                            return $ T.pack "well done!"
                        -- db actions or error 500

                payTo :: Int -> Maybe Text -> Maybe Text -> Handler Text
                payTo userId token hash 
                    | token == Nothing && hash == Nothing = liftIO (
                        writeLog WARNING ( "try to pay to " ++ show userId ++ " -> no Auth-token or User-hash here" ) ) >>
                        throwError err404
                    | otherwise = do
                        verified <- do
                            ( token' : xs ) <- liftIO $ TIO.readFile "ADM" >>= return . T.lines
                            let Just token_ = token
                            return $ token_ == token'
                        if not verified 
                        then do 
                            liftIO $ writeLog WARNING $ "wrong token to pay to user " ++ show userId
                            throwError err404
                        else do
                            liftIO $ writeLog IMPORTANT $ show userId ++ " has a card now"
                            return $ T.pack "well done!"
                        -- db actions or error 500
