{-
Welcome to a Spago project!
You can edit this file as you like.
-}
{ name =
    "my-project"
, dependencies =
    [ "arraybuffer"
    , "bouzuya-datetime-formatter"
    , "bouzuya-http-server"
    , "bouzuya-uuid-v4"
    , "node-process"
    , "now"
    , "psci-support"
    , "simple-json"
    , "test-unit"
    ]
, packages =
    ./packages.dhall
}
