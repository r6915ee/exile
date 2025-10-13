package = "handecs"
version = "master-1"
source = {
   url = "https://codeberg.org/r6915ee/handecs/archive/master.tar.gz",
}
description = {
   summary = "Simple, Lua-adjacent ECS framework",
   detailed = [[
      handecs is an ECS framework for Lua and derivative programming languages.
      It provides a system as Lua-native as possible, by having a minimum
      supported Lua version at 5.1, possessing both functions and data methods,
      and a focus on the archetype design to leverage faster queries.
   ]],
   homepage = "https://codeberg.org/r6915ee/handecs",
   license = "MIT"
}
dependencies = {
   "lua >= 5.1, <= 5.4",
}
build = {
   type = "builtin",
   modules = {
      handecs = "src/handecs.lua",
   },
}
rockspec_format = "3.1"
