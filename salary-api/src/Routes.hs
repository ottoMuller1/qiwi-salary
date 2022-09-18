{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}

module Routes where

import qualified Require.Deps as Req
import Require.Async
import Require.Logger
import Applications

---------------------------- Features ----------------------------------
runApp :: Int -> Req.Application -> IO ()
runApp port app = do
    adm <- Req.doesFileExist "ADM"
    if adm then do
        logAttempt <- async $ writeLog IMPORTANT $ "attemption to start server at " ++ show port
        runing <- async $ Req.run port app
        printing <- async $ putStrLn $ "attemption at " ++ show port
        await runing
        await printing
        await logAttempt
    else do
        writeLog WARNING "could not find ADM file"
