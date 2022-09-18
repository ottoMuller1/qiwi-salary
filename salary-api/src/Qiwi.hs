module Qiwi where

-- extra
import Data.ByteString.Char8 as B8 ( pack )
import Data.Text as T ( pack, unpack )

import Require.Deps
import qualified Records as Rec
import Require.Async
import Require.Logger

---------------------Queries------------------------
-- payment here
paymentQiwi :: FromJSON a => Int -> Text -> Rec.Payment -> ExceptT JSONException IO ( Response a )
paymentQiwi prowId token payment = ExceptT $ do
    let queryString = "edge.qiwi.com/sinap/api/v2/terms/" ++ show prowId ++ "/payments"
    stringedRequest <- parseRequest queryString
    let request = 
            setRequestBodyJSON payment $
            addRequestHeader ( mk $ B8.pack "Authorization" ) ( B8.pack $ "Bearer " ++ T.unpack token ) $
            addRequestHeader ( mk $ B8.pack "Content-type" ) ( B8.pack "application/json" ) $
            addRequestHeader ( mk $ B8.pack "Accept" ) ( B8.pack "application/json" ) $
            setRequestMethod ( B8.pack "POST" ) stringedRequest
    try $ httpJSON request

-- handle calling of payment error
handleFailQiwi :: JSONException -> IO () -> IO ()
handleFailQiwi _ io = do
    writing <- async $ writeLog WARNING "JSON sending exception"
    putting <- async $ putStrLn "JSON sending exception"
    io' <- async io
    await writing
    await putting
    await io'
