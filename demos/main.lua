local exile = require("exile")
local position = exile:component({ x = 0, y = 0 })
local display = exile:component()

local main = exile:schedule(function()
   exile:operate(function(_, entity) print(entity[position].x) end, 1, 2)
end)

exile:entity(exile:mutate(position, { x = 10 }), display)
exile:entity(position, display)

exile:invoke(main)
