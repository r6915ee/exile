local handecs = require("handecs")

local position = handecs:component({
   x = 0,
   y = 0,
})

print(handecs.components[position].x .. " " .. handecs.components[position].y)
