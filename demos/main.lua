local handecs = require("handecs")
local position = handecs:component({ x = 0, y = 0 })
local display = handecs:component()

local main = handecs:schedule({
   function()
      for _, entity in pairs(handecs:query({ position, display })) do
         print(entity[position].x)
      end
   end,
})

handecs:entity({ handecs:mutate(position, { x = 10 }), 2 })
handecs:entity({ 1, 2 })

handecs:invoke(main)
