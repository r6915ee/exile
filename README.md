# `exile`

`exile` is an **Entity Component System** framework for the
[Lua](https://lua.org/) scripting language. It primarily focuses on using Lua
5.1 syntax, safe manipulation functions, and leveraging the use of more native
design concepts with managing objects.

## Glossary

* **Entities**: Entities, at their core, are simply integer keys that point
  torwards a set of information describing a set of components. In the case of
  `exile`, entities are used as keys to a set of tables describing associated
  components for that entity.
* **Components**: Components are simply sets of data that can be used and
  manipulated by systems. An entity may refer to multiple different components
  at once.
* **Systems**: Systems are simply functions that operate on entities with
  certain components, typically through archetypes. They are invoked by
  schedules.
* **Schedules**: A concept unique to only some ECS frameworks, including
  `exile`, schedules categorize various systems together to be run at certain
  intervals specified by the base program.
* **Archetypes**: Archetypes, a feature popularized by
  [Unity](https://unity.com/), categorize entities based on their associated
  components. They are used for querying operations.

## Installation

For installing the `master` branch, it is safe to use
[LuaRocks](https://luarocks.org/) for installing like so:

```sh
luarocks install exile-master-1.rockspec
```

This will install the rock to your configured rocks directory.

Additionally, the library itself only consists of a module file, and it
contains some information of the project itself as well. It is safe to place
this file directly in a repository, or use a Git submodule.

```sh
cp ./exile/src/exile.lua ./project/src/exile.lua
```

## Usage

Require `exile` as you would with any other third-party Lua module, assuming
you either have the LuaRocks rocks directory in the Lua search path or in the
working directory of the Lua executor:

```lua
exile = require("exile")
```

### Components

Components can be constructed using the `component` method.

```lua
local position = exile:component({ x = 0, y = 0 })
local shouldDisplay = exile:component()
```

The `component` method can either accept a table with a certain set of default
data, or `nil` for an empty table, which can act as a simple flag.

Printing `position` will output `1`, and `shouldDisplay` will output `2`:

```lua
print(position .. " " .. shouldDisplay)
```

This is because all objects in `exile`, besides archetypes, are organized using
a typical table array internally. As such, components, entities, and systems
(which are grouped in schedules) are simply integer keys to tables that use
array indexing, starting from `1`. For this reason, creating a component,
entity, or schedule will return its associated index, which is useful for many
functions in `exile`.

It is possible to provide a mutation when referring to a component index in
some functions, particularly entity-related ones:

```lua
exile:mutate(position, { x = 10 })
```

This will attach a metatable to the mutation with the metamethod `__index`
pointing to the original component and allow the mutation's index to be known,
and then return the modified mutation.

### Entities

Entities are constructed using the `entity` method. Just like the `component`
method above, they can have no argument passed at all, although the arguments
passed are instead variadic arguments that are either a component index or
mutation each:

```lua
local displayObject = exile:entity(exile:mutate(1, { x = 10 }), 2)
```

Entities can have one or more components added or removed using the `push` and
`pull` methods, respectively:

```lua
local velocity = exile:component({ x = 0, y = 0 })
exile:push(displayObject, velocity)
exile:pull(displayObject, shouldDisplay)
```

An entity's archetype name may be found using the `getArchetype` method that
only accepts the entity index, which is useful for certain queries:

```lua
print(exile:getArchetype(displayObject)) -- 1,3
```

A simple way to verify whether or not one or more components are used by an
entity is to use the `entityHas` method:

```lua
print(exile:entityHas(displayObject, 1)) -- true
print(exile:entityHas(displayObject, 2)) -- false, since we pulled it earlier!
```

### Systems

Systems are partially unconventional in `exile` for the preferred usage of
a schedules system, particularly inspired from [Bevy](https://bevy.org/).

A schedule may be initiated with an initial set of systems using the following
`schedule` method, which accepts a set of variadic arguments consisting *only*
of functions, which are systems themselves:

```lua
local hello = exile:schedule(function(name)
   print("Hello, " .. tostring(name) .. "!")
end)
```

This schedule may then be invoked by using the respective `invoke` method,
where each variadic argument will be passed to the systems in the associated
schedule:

```lua
exile:invoke(hello, "exile") -- Hello, exile!
```

A schedule may have one or more systems assigned at runtime using the `assign`
method:

```lua
exile:assign(hello, function(name)
   print("And goodbye, " .. tostring(name) .. "!")
end)
```

### Queries

Queries are used to find entities associated with a certain archetype. To
perform a query, there are several methods available. All of them return a
table, where each key is the entity's index, and each value is that entity's
component data that can be mutated for further use. It is also possible to
fetch and mutate the component data of an entity.

Searching through an archetype by its associated components in a variadic
fashion can be performed using the `query` method:

```lua
for k, v in pairs(exile:query(position, velocity)) do
   print(k .. ": " .. tostring(v))
end
```

`queryString` is a slightly faster alternative to this method that operates
directly using the archetype name provided, instead of converting the variadic
arguments to a valid archetype name. However, it requires knowing the archetype
name beforehand, which includes component indexes separated by single commas:

```lua
for k, v in pairs(exile:queryString("1,3")) do
   print(k .. ": " .. tostring(v))
end
```

`allEntities` is a simpler query method that queries *all* entities:

```lua
local extraEntity = exile:entity()
for k, v in pairs(exile:allEntities()) do
   print(k .. ": " .. tostring(v))
end
```

The `entityHas` method mentioned [above](#entities) can be used in conjunction
with `allEntities` for basic filtering if so desired.

## Demos

Demos are present in the [`demos`](./demos/) folder of this repository.

## License

`exile`, like Lua itself, is licensed under the [MIT license](./LICENSE).
