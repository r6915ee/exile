--[[
  Author: r6915ee
  Repository: https://codeberg.org/r6915ee/exile
  License: MIT (https://codeberg.org/r6915ee/exile/src/branch/master/LICENSE)
]]

--- @class exile
local exile = {
   _components = {},
   _entities = {},
   _archetypes = {},
   _schedules = {},
}

--- Creates a component from the specified table.
--- @param data? table A table containing the keys and default values of the component. This may be `nil` to provide no properties.
--- @return number # The index of the component.
function exile:component(data)
   if type(data) == "table" or type(data) == "nil" then
      local index = #self._components + 1
      self._components[index] = data or {}
      return index
   end
   error(
      "Unable to create component "
         .. #self._components + 1
         .. " because data is invalid (provided data must be table or nil, not "
         .. type(data)
         .. ")"
   )
end

--- Creates a mutated, shallow copy of a component.
--- @param index number The index of the component.
--- @param extra table Set of key-value pairs that overwrite the pair with the same key.
--- @return table # The mutated copy of the component.
function exile:mutate(index, extra)
   if extra == nil then
      error('"extra" parameter needs to be specified when mutating for performance reasons')
   end
   local data = self._components[index]
   for k, v in pairs(extra) do
      if data[k] == nil then error('No key "' .. k .. '" in component ' .. index) end
   end
   extra._index = index
   return setmetatable(extra, { __index = data })
end

--- Creates an entity from a list of components.
--- @param list table A list of components, either as their indexes or directly as valid component tables, to inject into the entity.
--- @return number # The index of the entity.
function exile:entity(list)
   local entity = {}
   self._entities[#self._entities + 1] = entity
   for _, component in ipairs(list) do
      self:cleanAdd(#self._entities, component)
   end
   self:_attach(#self._entities)
   return #self._entities
end

--- Adds a component to an entity without reassigning an archetype.
--- @param entity number The index of the entity.
--- @param component number|table Either the index or a mutated version of a component.
--- @return table # The entity's assigned component data.
function exile:cleanAdd(entity, component)
   if type(component) == "number" then
      if self._components[component] == nil then
         error("Component " .. component .. " doesn't exist")
      end
      self._entities[entity][component] = setmetatable(
         {},
         { __index = self._components[component] }
      )
   elseif type(component) == "table" then
      local index = component._index
      self._entities[entity][index] = component
      self._entities[entity][index]._index = nil
   else
      error("Cannot add type " .. type(component) .. " as a component when creating an entity")
   end
   return self._entities[entity]
end

local function clearArchetypeEntity(archetype, index)
   for entityIndex = 1, #archetype do
      if archetype[entityIndex] == index then table.remove(archetype, entityIndex) end
   end
   if next(archetype) == nil then archetype = nil end
end

--- Adds a component to an entity and reassigns its archetype.
--- @param entity number The index of the entity.
--- @param component number|table Either the index or a mutated version of a component.
function exile:add(entity, component)
   local archetype = self._archetypes[self:getArchetype(entity)]
   exile:cleanAdd(entity, component)
   self:_attach(entity)
   clearArchetypeEntity(archetype, entity)
end

--- Removes a component from an entity and reassigns its archetype.
--- @param entity number The index of the entity.
--- @param component number The index of the component to remove.
function exile:remove(entity, component)
   local archetype = self._archetypes[self:getArchetype(entity)]
   self._entities[entity][component] = nil
   self:_attach(entity)
   clearArchetypeEntity(archetype, entity)
end

--- Creates a schedule, with an optional set of pre-defined systems.
--- @param systems? table A list of functions to run as systems.
--- @return number # The index of the schedule.
function exile:schedule(systems)
   if systems ~= nil then
      for k, v in ipairs(systems) do
         if type(v) ~= "function" then
            error("System " .. k .. " must be a function, not a " .. type(v))
         end
      end
   end
   self._schedules[#self._schedules + 1] = systems or {}
   return #self._schedules
end

--- Invokes a schedule.
--- @param index number The index of the schedule.
--- @param ... any Arguments to pass to any systems associated with this schedule.
function exile:invoke(index, ...)
   for k, v in ipairs(self._schedules[index]) do
      if type(v) ~= "function" then
         error("System " .. k .. " must be a function, not a " .. type(v))
      end
      v(...)
   end
end

--- Assigns a system to a schedule.
--- @param index number The index of the schedule.
--- @param system function The system to assign.
function exile:assign(index, system)
   if type(system) ~= "function" then
      error("System being assigned cannot be " .. type(system) .. ", only function")
   end
   self._schedules[index][#self._schedules[index] + 1] = system
end

local function _parseArchetype(data)
   local components = {}
   for compIndex, _ in pairs(data) do
      components[#components + 1] = compIndex
   end
   table.sort(components)
   return table.concat(components, ",")
end

--- Helper function for getting the proper archetype of an entity.
--- @param index number The index of the entity.
function exile:getArchetype(index)
   if type(self._entities[index]) ~= "table" then
      error("Entity " .. index .. " must be table, not " .. type(self._entities[index]))
   end
   return _parseArchetype(self._entities[index])
end

function exile:_attach(index)
   local archetype = self:getArchetype(index)
   self._archetypes[archetype] = self._archetypes[archetype] or {}
   self._archetypes[archetype][#self._archetypes[archetype] + 1] = index
   return 0
end

--- Parses a set of query data.
--- @param archetype string|table The archetype to parse.
function exile:parseQuery(archetype)
   local archetypeStr
   if type(archetype) == "table" then
      archetypeStr = _parseArchetype(archetype)
   elseif type(archetype) == "string" then
      archetypeStr = archetype
   elseif type(archetype) == "nil" then
      error("Archetype name cannot be nil")
   else
      error(
         "Archetype name "
            .. archetype
            .. " must be either a table or string, not "
            .. type(archetype)
      )
   end
   if
      type(self._archetypes[archetypeStr]) ~= "table"
      and type(self._archetypes[archetypeStr]) ~= "nil"
   then
      error(
         "Archetype "
            .. archetypeStr
            .. " contents must be table, not "
            .. type(self._archetypes[archetypeStr])
      )
   end
   return self._archetypes[archetypeStr] or {}
end

--- Queries an archetype.
--- @param archetype string|table The archetype to query.
function exile:query(archetype)
   local parsedQuery = self:parseQuery(archetype)
   local entities = {}
   for k, v in pairs(parsedQuery) do
      entities[#entities + 1] = self._entities[v]
   end
   return entities
end

return exile
