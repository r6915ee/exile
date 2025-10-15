--[[
  Author: r6915ee
  Repository: https://codeberg.org/r6915ee/handecs
  License: MIT (https://codeberg.org/r6915ee/handecs/src/branch/master/LICENSE)
]]

--- @class handecs
--- @field components table Defines all components.
--- @field entities table Defines all entities.
--- @field schedules table Defines all schedules.
local handecs = {
   components = {},
   entities = {},
   schedules = {},
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
   if extra == nil then
      error('"extra" parameter needs to be specified when mutating for performance reasons')
   end
   local data = self.components[index]
   for k, v in pairs(extra) do
      if data[k] == nil then error('No key "' .. k .. '" in component ' .. index) end
   end
   extra._index = index
   return setmetatable(extra, { __index = data })
end

--- Creates an entity from a list of components.
--- @param list table A list of components, either as their indexes or directly as valid component tables, to inject into the entity.
--- @return number # The index of the entity.
function handecs:entity(list)
   local entity = {}
   for _, component in ipairs(list) do
      if type(component) == "number" then
         entity[component] = setmetatable({}, { __index = self.components[component] })
      elseif type(component) == "table" then
         local index = component._index
         entity[index] = component
         entity[index]._index = nil
      else
         error("Cannot add type " .. type(component) .. " as a component when creating an entity")
      end
   end
   self.entities[#self.entities + 1] = entity
   return #self.entities
end

--- Creates a schedule, with an optional set of pre-defined systems.
--- @param systems? table A list of functions to run as systems.
--- @return number # The index of the schedule.
function handecs:schedule(systems)
   if systems ~= nil then
      for k, v in ipairs(systems) do
         if type(v) ~= "function" then
            error("System " .. k .. " must be a function, not a " .. type(v))
         end
      end
   end
   self.schedules[#self.schedules + 1] = systems or {}
   return #self.schedules
end

--- Invokes a schedule.
--- @param index number The index of the schedule.
--- @param ... any Arguments to pass to any systems associated with this schedule.
function handecs:invoke(index, ...)
   for k, v in ipairs(self.schedules[index]) do
      if type(v) ~= "function" then
         error("System " .. k .. " must be a function, not a " .. type(v))
      end
      v(...)
   end
end

--- Assigns a system to a schedule.
--- @param index number The index of the schedule.
--- @param system function The system to assign.
function handecs:assign(index, system)
   if type(system) ~= "function" then
      error("System being assigned cannot be " .. type(system) .. ", only function")
   end
   self.schedules[index][#self.schedules[index] + 1] = system
end

return handecs
