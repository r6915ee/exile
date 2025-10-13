--- @class handecs
--- @field components table Defines all components.
local handecs = {
   components = {},
}

--- Creates a component from the specified table.
--- @param data table A table containing the keys and default values of the component.
--- @return number # The index of the component, or `0` if the data is not a table.
function handecs:component(data)
   if type(data) == "table" then
      local index = #self.components + 1
      self.components[index] = data
      return index
   end
   return 0
end

--- Creates a mutated, shallow copy of a component.
--- @param index number The index of the component.
--- @param extra table Set of key-value pairs that overwrite the pair with the same key.
function handecs:mutate(index, extra)
   if type(self.components[index]) == "table" then
      local copy = {}
      for k, v in pairs(self.components[index]) do
         copy[k] = v
      end
      for k, v in pairs(extra) do
         if self.components[index][k] == nil then
            error('No key "' .. k .. '" in component ' .. index)
         end
         copy[k] = v
      end
      return copy
   end
   error("Component " .. index .. " is not a table")
end

return handecs
