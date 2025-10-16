package = "exile"
version = "master-1"
source = {
   url = "https://codeberg.org/r6915ee/exile/archive/master.tar.gz",
}
description = {
   summary = "Simple, Lua-adjacent Entity Component System framework",
   detailed = [[
      exile is an ECS framework for Lua and derivative programming languages.
      It provides a system as Lua-native as possible, by having a minimum
      supported Lua version at 5.1, possessing safe manipulation functions, and
      a Bevy-inspired custom schedule system.

      Several noteworthy features on the performance-side include explicit
      value management, most objects using numerical indexing instead of
      strings for naming, and the usage of archetypes for queries.
   ]],
   homepage = "https://codeberg.org/r6915ee/exile",
   license = "MIT"
}
dependencies = {
   "lua >= 5.1, <= 5.4",
}
build = {
   type = "builtin",
   modules = {
      exile = "src/exile.lua",
   },
}
rockspec_format = "3.1"
