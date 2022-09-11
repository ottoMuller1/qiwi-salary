module Main where

import Routes
import Require.Async
import Applications

main :: IO ()
main = do
    running <- async $ runApp 8080 app1
    await running
