# vim:set ft= ts=4 sw=4 et:

use Test::Nginx::Socket;
use Cwd qw(cwd);

plan tests => repeat_each() * (blocks() * 3);

my $pwd = cwd();

our $MainConfigWithoutNrConfig = qq{
    env NEWRELIC_APP_LICENSE_KEY;
    env NEWRELIC_APP_NAME;
};

our $MainConfig = qq{
    env NEWRELIC_APP_LICENSE_KEY=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
    env NEWRELIC_APP_NAME=test-app;
};


our $HttpConfig = qq{
    lua_package_path "$pwd/lib/?.lua;;";
    init_worker_by_lua 'require("resty.newrelic_agent").enable()';
    error_log logs/error.log debug;
};

$ENV{TEST_NGINX_RESOLVER} = '8.8.8.8';

no_long_string();
#no_diff();

run_tests();

__DATA__
=== TEST 1: Not configured agent.
--- main_config eval: $::MainConfigWithoutNrConfig
--- http_config eval: $::HttpConfig
--- config
    location = /a {
        access_by_lua 'require("resty.newrelic_agent").start_web_transaction()';
        echo "OK";
        log_by_lua 'require("resty.newrelic_agent").finish_web_transaction()';
    }
--- request
GET /a
--- response_body
OK
--- error_log
Newrelic agent is not configured

=== TEST 2: Configured agent.
--- main_config eval: $::MainConfig
--- http_config eval: $::HttpConfig
--- config
    location = /a {
        access_by_lua 'require("resty.newrelic_agent").start_web_transaction()';
        echo "OK";
        log_by_lua 'require("resty.newrelic_agent").finish_web_transaction()';
    }
--- request
GET /a
--- response_body
OK
--- error_log
Starting newrelic agent.
