--[[
  Author: r6915ee
  Repository: https://codeberg.org/r6915ee/handecs
  License: MIT (https://codeberg.org/r6915ee/handecs/src/branch/master/LICENSE)
]]

--- @class handecs
--- @field components table Defines all components.
--- @field entities table Defines all entities.
local handecs = {
   components = {},
   entities = {},
}

local function _shallowCopy(data)
   local copy = {}
   for k, v in pairs(data) do
      copy[k] = v
   end
   return copy
end

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

function handecs:_cleanCopy(index) return _shallowCopy(self:fetch(index)) end

function handecs:_copy(index)
   local copy = self:_cleanCopy(index)
   copy._index = index
   return copy
end

--- Creates a mutated, shallow copy of a component.
--- @param index number The index of the component.
--- @param extra table Set of key-value pairs that overwrite the pair with the same key.
--- @return table # The mutated copy of the component.
function handecs:mutate(index, extra)
   if extra == nil then
      error('"extra" parameter needs to be specified when mutating for performance reasons')
   end
   local data = self:_copy(index)
   for k, v in pairs(extra) do
      if data[k] == nil then error('No key "' .. k .. '" in component ' .. index) end
      if k == "_index" then error("Cannot modify component index when performing mutation") end
      data[k] = v
   end
   return data
end

--- Creates an entity from a list of components.
--- @param list table A list of components, either as their indexes or directly as valid component tables, to inject into the entity.
--- @return number # The index of the entity.
function handecs:entity(list)
   local entity = {}
   for _, component in ipairs(list) do
      if type(component) == "number" then
         entity[component] = handecs:_copy(component)
      elseif type(component) == "table" then
         local copy = _shallowCopy(component)
         copy._index = nil
         entity[component._index] = copy
      end
   end
   self.entities[#self.entities + 1] = entity
   return #self.entities
end

return handecs
