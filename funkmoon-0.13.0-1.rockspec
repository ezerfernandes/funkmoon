rockspec_format = "3.0"
package = "funkmoon"
version = "0.13.0-1"

source = {
   url = "git+https://github.com/ezerfernandes/funkmoon.git",
   tag = "v0.13.0",
}

description = {
   summary = "Typed functional tools for Lua",
   detailed = "Functional table and iterator utilities for Lua 5.2 through 5.5, with LuaLS type annotations.",
   homepage = "https://github.com/ezerfernandes/funkmoon",
   license = "MIT",
}

dependencies = {
   "lua >= 5.2, < 5.6",
}

build = {
   type = "builtin",
   modules = {
      funkmoon = "funkmoon.lua",
   },
}
