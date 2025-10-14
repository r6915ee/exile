local handecs = require("handecs")
local hello = handecs:schedule({ function() print("Hello, handecs!") end })
handecs:invoke(hello)
