{-# LANGUAGE DeriveGeneric #-}

module Records where

import Require.Deps

----------------------Types here----------------------
data User = User {
    uid :: Int,
    uhash :: Maybe Text,
    fio :: Maybe ( Text, Text, Text ),
    ureged :: UTCTime,
    rate :: Double,
    period :: Double,
    currencyQiwiCode :: Maybe Int,
    providerQiwiCode :: Maybe Int
} deriving Generic
instance ToJSON User
instance FromJSON User
