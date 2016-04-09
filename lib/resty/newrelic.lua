local ffi = require 'ffi'

ffi.cdef([[
	void *newrelic_message_handler(void *raw_message);
	void newrelic_register_status_callback(void(*callback)(int));
	int newrelic_init(const char *license, const char *app_name, const char *language, const char *language_version);
	int newrelic_request_shutdown(const char *reason);
	void newrelic_enable_instrumentation(int set_enabled);
	void newrelic_register_message_handler(void*(*handler)(void*));
  int newrelic_record_metric(const char *name, double value);
	long newrelic_transaction_begin();
	int newrelic_transaction_notice_error(long transaction_id, const char *exception_type,
    const char *error_message, const char *stack_trace, const char *stack_frame_delimiter);
	int newrelic_transaction_add_attribute(long transaction_id, const char *name, const char *value);
	int newrelic_transaction_set_name(long transaction_id, const char *name);
	int newrelic_transaction_set_request_url(long transaction_id, const char *request_url);
	int newrelic_transaction_set_max_trace_segments(long transaction_id, int max_trace_segments);
	int newrelic_transaction_end(int64_t transaction_id);
	long newrelic_segment_generic_begin(long transaction_id, long parent_segment_id, const char *name);
	long newrelic_segment_datastore_begin(long transaction_id, long parent_segment_id,
    const char *table, const char *operation);
	int newrelic_segment_end(long transaction_id, long segment_id);
]])

local nrt = ffi.load('newrelic-transaction', true)
local nrc = ffi.load('newrelic-collector-client', true)

local embed_collector = function()
	nrt.newrelic_register_message_handler(nrc.newrelic_message_handler)
end

local init = function(license, app_name, language, language_version)
	return nrc.newrelic_init(license, app_name, language, language_version)
end

local newrelic_record_metric = function(name, value)
  value = tonumber(value, 10)
  return nrt.newrelic_record_metric(name, value)
end

local request_shutdown = function(reason)
	return nrc.newrelic_request_shutdown(reason)
end

local enable_instrumentation = function(set_enabled)
	nrt.newrelic_enable_instrumentation(set_enabled)
end

local begin_transaction = function()
	return tonumber(nrt.newrelic_transaction_begin())
end

local notice_transaction_error = function(transaction_id, exception_type, error_message,
  stack_trace, stack_frame_delimiter)

  transaction_id = tonumber(transaction_id, 10)
	return nrt.newrelic_transaction_notice_error(transaction_id, exception_type, error_message,
    stack_trace, stack_frame_delimiter)
end

-- list of attrs:
-- https://docs.newrelic.com/docs/insights/new-relic-insights/decorating-events/apm-default-attributes-insights
local add_transaction_attribute = function(transaction_id, name, value)
  transaction_id = tonumber(transaction_id, 10)
  name           = tostring(name)
  value          = tostring(value)

	return nrt.newrelic_transaction_add_attribute(transaction_id, name, value)
end

local set_transaction_name = function(transaction_id, name)
  transaction_id = tonumber(transaction_id, 10)
	return nrt.newrelic_transaction_set_name(transaction_id, name)
end

local set_transaction_request_url = function(transaction_id, request_url)
  transaction_id = tonumber(transaction_id, 10)
	return nrt.newrelic_transaction_set_request_url(transaction_id, request_url)
end

local set_max_transaction_trace_segments = function(transaction_id, max_trace_segments)
  transaction_id = tonumber(transaction_id, 10)
	return nrt.newrelic_transaction_set_max_trace_segments(transaction_id, max_trace_segments)
end

local end_transaction = function(transaction_id)
  transaction_id = tonumber(transaction_id, 10)
	return nrt.newrelic_transaction_end(transaction_id)
end

local begin_generic_segment = function(transaction_id, parent_segment_id, name)
  transaction_id = tonumber(transaction_id, 10)
	return tonumber(nrt.newrelic_segment_generic_begin(transaction_id, parent_segment_id, name))
end

local begin_datastore_segment = function(transaction_id, parent_segment_id, table, operation)
  transaction_id = tonumber(transaction_id, 10)
	return tonumber(nrt.newrelic_segment_datastore_begin(transaction_id, parent_segment_id, table, operation))
end

local end_segment = function(transaction_id, parent_segment_id)
  transaction_id = tonumber(transaction_id, 10)
	return nrt.newrelic_segment_end(transaction_id, parent_segment_id)
end

local _M = {
	embed_collector                    = embed_collector,
	init                               = init,
	request_shutdown                   = request_shutdown,
	enable_instrumentation             = enable_instrumentation,
	begin_transaction                  = begin_transaction,
	notice_transaction_error           = notice_transaction_error,
	add_transaction_attribute          = add_transaction_attribute,
	set_transaction_name               = set_transaction_name,
	set_transaction_request_url        = set_transaction_request_url,
	set_max_transaction_trace_segments = set_max_transaction_trace_segments,
	end_transaction                    = end_transaction,
	begin_generic_segment              = begin_generic_segment,
	begin_datastore_segment            = begin_datastore_segment,
	end_segment                        = end_segment,
  record_metric                      = newrelic_record_metric,
  _VERSION                           = '0.0.1',
}

return _M
