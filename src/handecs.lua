--- @class handecs
--- @field components table Defines all components.
local handecs = {
   components = {},
}

--- Creates a component from the specified table.
--- @param data table A table containing the keys and default values of the component.
--- @return number # The index of the component.
function handecs:component(data)
   local index = #self.components + 1
   self.components[index] = data
   return index
end

return handecs
