# `exile`

`exile` is an **Entity Component System** framework for the
[Lua](https://lua.org/) scripting language. It primarily focuses on using Lua
5.1 syntax, safe manipulation functions, and leveraging the use of more native
design concepts with managing objects.

## Glossary

> todo

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
data, or `nil` for an empty table.

Printing `position` will output `1`, and `shouldDisplay` will output `2`:

```lua
print(position .. " " .. shouldDisplay)
```

This is because all objects in `exile`, besides archetypes, are organized using
a typical table array internally. As such, components, entities, and systems
(which are grouped in schedules) are simply identifiers to tables that use
array indexing, starting from `1`.

It is possible to provide a mutation when referring to a component index in
some functions, particularly entity-related ones:

```lua
exile:mutate(position, { x = 10 })
```

This will attach a metatable to the mutation with the metamethod `__index`
pointing to the original component.

### Entities

> todo

### Systems

Systems are partially unconventional in `exile` for the preferred usage of
a schedules system, particularly inspired from [Bevy](https://bevy.org/).

> todo

### Queries

> todo

### Entity Mutations

> todo

## Demos

Demos are present in the [`demos`](./demos/) folder of this repository.

## License

`exile`, like Lua itself, is licensed under the [MIT license](./LICENSE).
