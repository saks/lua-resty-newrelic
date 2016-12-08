local newrelic = require 'resty.newrelic'
local newrelic_agent = require 'resty.newrelic_agent'
local nr_transaction_id = ngx.ctx.nr_transaction_id

local call_remote_host = function(uri)
  ngx.log(ngx.ERR, 'Calling ' .. uri .. ' host...')
  ngx.sleep(math.random())
end

local redis = require 'resty.redis'
local red = redis:new()
red:set_timeout(math.random(1000))

-- track database query
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
local uri = 'http://google.com'
local external_segment_id = newrelic.begin_external_segment(nr_transaction_id,
newrelic.NEWRELIC_ROOT_SEGMENT, uri, 'google home page')
call_remote_host(uri)
newrelic.end_segment(nr_transaction_id, external_segment_id)
