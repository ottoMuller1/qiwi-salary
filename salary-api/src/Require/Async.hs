module Require.Async ( async, await ) where

import Require.Deps

-- async await syntax implementation
newtype Async a = Async ( MVar a )

async :: IO a -> IO ( Async a )
async action =
    newEmptyMVar >>= \mvar ->
    forkIO ( action >>= putMVar mvar ) >>
    return ( Async mvar )

await :: Async a -> IO a
await ( Async mvar ) = readMVar mvar
