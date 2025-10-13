--- @class handecs
--- @field components table Defines all components.
--- @field entities table
local handecs = {
   components = {},
}

--- Creates a component from the specified table.
--- @param data? table A table containing the keys and default values of the component. This may be `nil` to provide no properties.
--- @return number # The index of the component.
function handecs:component(data)
   if type(data) == "table" or type(data) == "nil" then
      local index = #self.components + 1
      self.components[index] = data or {}
      return index
   end
   error(
      "Unable to create component "
         .. #self.components + 1
         .. " because data is invalid (provided data must be table or nil, not "
         .. type(data)
         .. ")"
   )
end

--- Fetches a component.
--- @param index number The index of the component.
function handecs:fetch(index)
   if type(index) == "number" then
      if type(self.components[index]) ~= "table" then
         error("Component " .. index .. " must be a table, not a " .. type(self.components[index]))
      end
      return self.components[index]
   end
   error(
      "Unable to fetch component "
         .. index
         .. " because index can only be a number, not a "
         .. type(index)
   )
end

--- Creates a mutated, shallow copy of a component.
--- @param index number The index of the component.
--- @param extra table Set of key-value pairs that overwrite the pair with the same key.
--- @return table # The mutated copy of the component.
function handecs:mutate(index, extra)
   local origin = self:fetch(index)
   local copy = {}
   for k, v in pairs(origin) do
      copy[k] = v
   end
   for k, v in pairs(extra) do
      if origin[k] == nil then error('No key "' .. k .. '" in component ' .. index) end
      copy[k] = v
   end
   return copy
end

return handecs
