Name
====

lua-resty-newrelic - Lua newrelic SDK for the ngx_lua based on the C SDK.

Table of Contents
=================

* [Name](#name)
* [Status](#status)
* [Description](#description)
* [Synopsis](#synopsis)
* [Installation](#installation)
* [Bugs and Patches](#bugs-and-patches)
* [Author](#author)
* [Copyright and License](#copyright-and-license)

Status
======

This library is considered production ready.

Description
===========

This Lua library is a luajit ffi-based wrapper around [newrelic agent SDK](https://docs.newrelic.com/docs/agents/agent-sdk/installation-configuration/installing-agent-sdk) for the ngx_lua nginx module:

This library **can only** be used with luajit, **NOT** lua, because uses [luajit ffi](http://luajit.org/ext_ffi.html).

Synopsis
========

```lua
    http {
        # you do not need the following line if you are using
        # the OpenResty bundle:
        lua_package_path "/path/to/resty-newrelic/lib/?.lua;;";

        env NEWRELIC_APP_LICENSE_KEY=<your newrelic lincense key>;
        env NEWRELIC_APP_NAME=<your newrelic application name>;

        init_worker_by_lua_block {
            require('resty.newrelic_agent').enable()
        }

        server {
            location /test {
                rewrite_by_lua_block {
                    require('resty.newrelic_agent').start_web_transaction()
                }

                # here you can use any directive that generates response body like: try_files,
                # proxy_pass, content_by_lua_*, etc.
                content_by_lua_block {
                    local newrelic = require 'resty.newrelic'
                    local newrelic_agent = require 'resty.newrelic_agent'
                    local nr_transaction_id = ngx.ctx.nr_transaction_id

                    -- track database query
                    local redis = require 'resty.redis'
                    local red = redis:new()

                    local redis_connect_segment_id = newrelic.begin_datastore_segment(
                      nr_transaction_id, newrelic.NEWRELIC_ROOT_SEGMENT, 'redis', 'connect')
                    local connect_ok, connect_err = red:connect('127.0.0.1', 6379)

                    newrelic.end_segment(nr_transaction_id, redis_connect_segment_id)

                    -- increment custom metric
                    if connect_ok then
                      newrelic.record_metric('redis_client/new_connect', 1)
                    else
                      -- log error to newrelic
                      newrelic_agent.notice_error('Failed to connect to redis',
                        connect_err, debug.traceback(), '\n')

                    end

                    -- track remote call
                    local http = require 'resty.http'
                    local uri = 'http://google.com'
                    local httpc = http.new()
                    local external_segment_id = newrelic.begin_external_segment(nr_transaction_id,
                    newrelic.NEWRELIC_ROOT_SEGMENT, uri, 'google home page')

                    httpc:request_uri(uri, { foo = 'bar' })
                    newrelic.end_segment(nr_transaction_id, external_segment_id)
                }

                log_by_lua_block {
                    require('resty.newrelic_agent').finish_web_transaction()
                }
            }
        }
    }
```

[Back to TOC](#table-of-contents)

Installation
============

If you are using the OpenResty bundle (http://openresty.org ), then
just download lua file [newrelic.lua](https://github.com/saks/lua-resty-newrelic/blob/master/lib/resty/newrelic.lua)
and [newrelic_agent.lua](https://github.com/saks/lua-resty-newrelic/blob/master/lib/resty/newrelic_agent.lua)
files to the directiory where nginx will find it. Another way to install is to use
[luarocks](https://luarocks.org/modules/saksmlz/resty-newrelic) package.
And you can just use it in your Lua code,
as in

```lua
    local newrelic = require "resty.newrelic"
    ...
```

If you are using your own nginx + ngx_lua build, then you need to configure
the lua_package_path directive to add the path of your resty-newrelic source
tree to ngx_lua's LUA_PATH search path, as in

```nginx
    # nginx.conf
    http {
        lua_package_path "/path/to/resty-newrelic/lib/?.lua;;";
        ...
    }
```

Ensure that the system account running your Nginx ''worker'' proceses have
enough permission to read the `.lua` file.

[Back to TOC](#table-of-contents)


Bugs and Patches
================

Please report bugs or submit patches by

1. creating a ticket on the [GitHub Issue Tracker](http://github.com/saks/lua-resty-newrelic/issues),

[Back to TOC](#table-of-contents)

Author
======

Aliaksandr "saksmlz" Rahalevich <saksmlz__at__gmail.com>.

[Back to TOC](#table-of-contents)

Copyright and License
=====================

This module is licensed under the BSD license.

Copyright (C) 2016, by Aliaksandr Rahalevich (saksmlz) <saksmlz__at__gmail.com>.

All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

[Back to TOC](#table-of-contents)
