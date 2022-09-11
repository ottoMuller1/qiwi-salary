module Require.Logger ( writeLog, LogType ( .. ) ) where

import Require.Deps

-- type of log
data LogType = WARNING | IMPORTANT | SIMPLE

-- log writing
writeLog :: LogType -> String -> IO ()
writeLog WARNING log =
    getCurrentTime >>= return . addSeconds 10800 >>= \timeLog ->
    appendFile "LOG" ( show timeLog ++ ": WARNING: " ++ log ++ "\n" )
writeLog SIMPLE log =
    getCurrentTime >>= return . addSeconds 10800 >>= \timeLog ->
    appendFile "LOG" ( show timeLog ++ ": SIMPLE: " ++ log ++ "\n" )
writeLog IMPORTANT log =
    getCurrentTime >>= return . addSeconds 10800 >>= \timeLog ->
    appendFile "LOG" ( show timeLog ++ ": IMPORTANT: " ++ log ++ "\n" )
