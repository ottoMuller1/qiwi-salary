# salary-api
## Intro
This is a part of salary control system, using qiwi api. Qiwi Salary api is used to add and control payment processes.
Not finished logic.
## Routes
- /user/{ user id }:Int -> POST { users }:[ Json ] Headers { Auth-token, User-hash } -> Getting user
- /user/new/{ second name }:String/{ first name }:String/{ father name }:String -> POST { some string }:String Headers { Auth-token } -> Adding user
- /user/delete/{ user id }:Int -> POST { some string }:String Headers { Auth-token, User-hash } -> Deleting user
- /user/s -> POST { users }:[ Json ] Headers { Auth-token } -> Getting all users
- /user/desires/of/{ user id }:Int/every/{ period }:Double/for/{ rate }:Double/{ currency }:Int/in/{ provider }:Int -> POST { some text }:String Headers { Auth-token, User-hash } -> Adding user desires
- /user/card/set/{ user id }:Int -> POST { some text }:String Headers { Auth-token, User-hash } Body { number:Null String, expDate:Null Int, cardType:Int, bid:Int }:Json -> Adding user card info
- /user/card/delete/{ user id }:Int -> POST { some text }:String Headers { Auth-token, User-hash } -> Deleting user card info
- /pay/to/{ user id }:Int -> POST { some text }:String Headers { Auth-token, User-hash } -> Starting payment process, used by scheduler
