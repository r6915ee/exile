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

local function clearArchetypeEntity(archetype, index)
   for entityIndex = 1, #archetype do
      if archetype[entityIndex] == index then table.remove(archetype, entityIndex) end
   end
   if next(archetype) == nil then archetype = nil end
end

--- Creates an entity from a list of components.
--- @param ... number|table A list of components, either as their indexes or directly as mutations.
--- @return number # The index of the entity.
function exile:entity(...)
   local components = { ... }
   self._entities[#self._entities + 1] = {}
   for i = 1, #components do
      self:cleanAdd(#self._entities, components[i])
   end
   self:_attach(#self._entities)
   return #self._entities
end

--- Removes an entity from an archetype and then removes its data.
--- @param entity number The index of the entity.
function exile:removeEntity(entity)
   clearArchetypeEntity(self:parseQuery(self:getArchetype(entity)), entity)
   table.remove(self._entities, entity)
end

--- Checks if an entity has one or more specified components.
--- @param entity number The index of the entity.
--- @param ... number A list of components to check for.
--- @return boolean # Whether or not the entity possesses the component.
function exile:entityHas(entity, ...)
   local components = { ... }
   for i = 1, #components do
      if self._entities[entity][components[i]] == nil then return false end
   end
   return true
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

--- Adds one or more components to an entity and reassigns its archetype.
--- @param entity number The index of the entity.
--- @param ... number|table Either the index or a mutated version of a component, per argument.
function exile:push(entity, ...)
   local components = { ... }
   local archetype = self._archetypes[self:getArchetype(entity)]
   for i = 1, #components do
      exile:cleanAdd(entity, components[i])
   end
   self:_attach(entity)
   clearArchetypeEntity(archetype, entity)
end

--- Removes one or more components from an entity and reassigns its archetype.
--- @param entity number The index of the entity.
--- @param ... number The index of the component to remove, per argument.
function exile:pull(entity, ...)
   local components = { ... }
   local archetype = self._archetypes[self:getArchetype(entity)]
   for i = 1, #components do
      self._entities[entity][components[i]] = nil
   end
   self:_attach(entity)
   clearArchetypeEntity(archetype, entity)
end

--- Creates a schedule, with an optional set of pre-defined systems.
--- @param ... function A system to assign automatically, per argument.
--- @return number # The index of the schedule.
function exile:schedule(...)
   local systems = { ... }
   for i = 1, #systems do
      if type(systems[i]) ~= "function" then
         error("System " .. systems[i] .. " must be a function, not a " .. type(systems[i]))
      end
   end
   self._schedules[#self._schedules + 1] = { ... } or {}
   return #self._schedules
end

--- Invokes a schedule.
--- @param index number The index of the schedule.
--- @param ... any Arguments to pass to any systems associated with this schedule.
function exile:invoke(index, ...)
   local schedule = self._schedules[index]
   for i = 1, #schedule do
      if type(schedule[i]) ~= "function" then
         error("System " .. schedule[i] .. " must be a function, not a " .. type(schedule[i]))
      end
      schedule[i](...)
   end
end

--- Assigns one or more systems to a schedule.
--- @param index number The index of the schedule.
--- @param ... function A system to assign, per argument.
function exile:assign(index, ...)
   local systems = { ... }
   for i = 1, #systems do
      if type(systems[i]) ~= "function" then
         error("System being assigned cannot be " .. type(systems[i]) .. ", only function")
      end
      self._schedules[index][#self._schedules[index] + 1] = systems[i]
   end
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
--- @return string # The entity's archetype name.
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

function exile:_parseQueryData(queryData)
   local parsedQuery = self:parseQuery(queryData)
   local entities = {}
   for _, v in pairs(parsedQuery) do
      entities[v] = self._entities[v]
   end
   return entities
end

--- Queries an archetype through its string name.
--- @param archetype string The archetype to query.
--- @return table<number, table> # The results of the query.
function exile:queryString(archetype) return self:_parseQueryData(archetype) end

--- Queries an archetype.
--- @param ... number A list of components to query for.
--- @return table<number, table> # The results of the query.
function exile:query(...) return self:_parseQueryData({ ... }) end

--- Queries all entities available.
--- @return table<number, table> # All of the entities.
function exile:allEntities() return self._entities end

return exile
