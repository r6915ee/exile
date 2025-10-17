local exile = require("exile")
local hello = exile:schedule(function() print("Hello, exile!") end)
exile:invoke(hello)
