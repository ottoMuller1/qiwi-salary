{-# LANGUAGE DeriveGeneric #-}

module Records where

import Require.Deps

-- user special types
data User = User {
    uid :: Int,
    uhash :: Maybe Text,
    fio :: ( Text, Text, Text ),
    ureged :: UTCTime,
    rate :: Maybe Double,
    period :: Maybe Double,
    currencyQiwiCode :: Maybe Int,
    providerQiwiCode :: Maybe Int,
    card :: Maybe Card
} deriving Generic
instance ToJSON User
instance FromJSON User

data Card = Card {
    number :: Maybe Text,
    expDate :: Maybe Int,
    cardType :: Int,
    bid :: Int
} deriving Generic
instance ToJSON Card
instance FromJSON Card

-- payment special types for Qiwi
data Payment = Payment {
    _id :: Text,
    _sum :: Sum,
    paymentMethod :: Method,
    fields :: Fields
} deriving Generic
instance ToJSON Payment
instance FromJSON Payment

data Sum = Sum {
    amount :: Double,
    currency :: Text
} deriving Generic 
instance ToJSON Sum
instance FromJSON Sum

data Method = Method {
    _type :: Text,
    accountId :: Text
} deriving Generic
instance ToJSON Method
instance FromJSON Method

data Fields = Fields {
    _account :: Text,
    _exp_date :: Text,
    account_type :: Text,
    mfo :: Text,
    lname :: Text,
    fname :: Text,
    mname :: Text
} deriving Generic
instance ToJSON Fields
instance FromJSON Fields

data PaymentInfo = PaymentInfo {
    __id :: Int,
    terms :: Text,
    _fields :: Fields,
    __sum :: Sum,
    source :: Text,
    comment :: Maybe Text,
    transaction :: Transaction,
    code :: Text
} deriving Generic
instance ToJSON PaymentInfo
instance FromJSON PaymentInfo

data Transaction = Transaction {
    ___id :: Text,
    state :: Text
} deriving Generic
instance ToJSON Transaction
instance FromJSON Transaction
