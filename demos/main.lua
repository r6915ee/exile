local exile = require("exile")
local position = exile:component({ x = 0, y = 0 })
local display = exile:component()

local main = exile:schedule(function()
   for _, entity in pairs(exile:query(position, display)) do
      print(entity[position].x)
   end
end)

exile:entity(exile:mutate(position, { x = 10 }), display)
exile:entity(position, display)

exile:invoke(main)
