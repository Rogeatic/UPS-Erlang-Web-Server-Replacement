%%%-------------------------------------------------------------------
%% @doc ups_server public API
%% @end
%%%-------------------------------------------------------------------

-module(ups_server_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    ups_server_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
