package = "resty-newrelic"
version = "0.01-1"
source = {
   url = "https://github.com/saks/lua-resty-newrelic/archive/master.zip",
   tag = "v0.01"
}
description = {
   summary = "Lua newrelic client library for OpenResty / ngx_lua.",
   detailed = [[
    Features an interface to reporting and monitoring with newrelic.
    Requires newrelic SDK shared libraries to be installed
    (https://docs.newrelic.com/docs/agents/agent-sdk/installation-configuration/installing-agent-sdk)
  ]],
   homepage = "https://github.com/saks/lua-resty-newrelic",
   license = "2-clause BSD",
   maintainer = "Alex R. <saksmlz@gmail.com>"
}
dependencies = {
   "lua >= 5.1"
}
build = {
   type = "builtin",
   modules = {
      ["resty.newrelic"] = "lib/resty/newrelic.lua",
      ["resty.newrelic_agent"] = "lib/resty/newrelic_agent.lua"
   }
}
