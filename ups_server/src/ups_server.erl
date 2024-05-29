-module(ups_server).
-behaviour(gen_server).

%% API
-export([start/0,start/3,stop/0]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).


%%%===================================================================
%%% API
%%%===================================================================

%%--------------------------------------------------------------------
%% @doc
%% Starts the server assuming there is only one server started for 
%% this module. The server is registered locally with the registered
%% name being the name of the module.
%%
%% @end
%%--------------------------------------------------------------------
-spec start() -> {ok, pid()} | ignore | {error, term()}.
start() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).
%%--------------------------------------------------------------------
%% @doc
%% Starts a server using this module and registers the server using
%% the name given.
%% Registration_type can be local or global.
%%
%% Args is a list containing any data to be passed to the gen_server's
%% init function.
%%
%% @end
%%--------------------------------------------------------------------
-spec start(atom(),atom(),atom()) -> {ok, pid()} | ignore | {error, term()}.
start(Registration_type,Name,Args) ->
    gen_server:start_link({Registration_type, Name}, ?MODULE, Args, []).


%%--------------------------------------------------------------------
%% @doc
%% Stops the server gracefully
%%
%% @end
%%--------------------------------------------------------------------
-spec stop() -> {ok}|{error, term()}.
stop() -> gen_server:call(?MODULE, stop).

%% Any other API functions go here.

%-spec sum([Integer])->{Integer}|{error, term()}.
%sum(Numbers)->
%    gen_server:call(?MODULE,{sum,Numbers}).

%factorial(Number)->
%    gen_server:call(?MODULE,{fact,Number}).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Initializes the server
%%
%% @end
%%--------------------------------------------------------------------
-spec init(term()) -> {ok, term()}|{ok, term(), number()}|ignore |{stop, term()}.
init([]) ->
        {ok,replace_up}.
%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling call messages
%%
%% @end
%%--------------------------------------------------------------------
-spec handle_call(Request::term(), From::pid(), State::term()) ->
                                  {reply, term(), term()} |
                                  {reply, term(), term(), integer()} |
                                  {noreply, term()} |
                                  {noreply, term(), integer()} |
                                  {stop, term(), term(), integer()} | 
                                  {stop, term(), term()}.
handle_call({sum,Numbers}, From, State) ->
    Sum  = lists:foldl(fun(X,Accum)->X+Accum end, 0, Numbers),
        {reply,Sum,State};
handle_call({fact,Number}, From, State)->
    Result = factorial_helper(Number),
    {reply,Result, State};
handle_call(stop, _From, _State) ->
        {stop,normal,
                replace_stopped,
          down}. %% setting the server's internal state to down

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling cast messages
%%
%% @end
%%--------------------------------------------------------------------
-spec handle_cast(Msg::term(), State::term()) -> {noreply, term()} |
                                  {noreply, term(), integer()} |
                                  {stop, term(), term()}.
handle_cast(_Msg, State) ->
    {noreply, State}.
    
%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling all non call/cast messages
%%
%% @end
-spec handle_info(Info::term(), State::term()) -> {noreply, term()} |
                                   {noreply, term(), integer()} |
                                   {stop, term(), term()}.
handle_info(_Info, State) ->
    {noreply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% This function is called by a gen_server when it is about to
%% terminate. It should be the opposite of Module:init/1 and do any
%% necessary cleaning up. When it returns, the gen_server terminates
%% with Reason. The return value is ignored.
%%
%% @end
%%--------------------------------------------------------------------
-spec terminate(Reason::term(), term()) -> term().
terminate(_Reason, _State) ->
    ok.
    
%%--------------------------------------------------------------------
%% @private
%% @doc
%% Convert process state when code is changed
%%
%% @end
%%--------------------------------------------------------------------
-spec code_change(term(), term(), term()) -> {ok, term()}.
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
    
%%%===================================================================
%%% Internal functions
%%%===================================================================

factorial_helper(0)->1;
factorial_helper(N) when is_integer(N), N > 0 ->
    lists:foldl(fun(X,Accum)-> X*Accum end,1, lists:seq(1,N));
factorial_helper(_)->
    fail.


%% Only include the eunit testing library
%% in the compiled code if testing is 
%% being done.
-ifdef(TEST).
-include_lib("eunit/include/eunit.hrl").

%fact_test()->
%    [?_assertEqual(120,factorial_helper(5)),
%     ?_assertEqual(1,factorial_helper(0)),
%     ?_assertEqual(fail,factorial_helper(-3)),
%     ?_assertEqual(fail,factorial_helper(nil))
%    ].


%handle_call_test()->
%    ?assertEqual({reply,6,some_state},handle_call({sum,[1,2,3]},some_pid,some_state)).
% 
package_transfer_test()->
    {
        setup,
            fun() -> %this setup fun is run once befor the tests are run. If you want setup and teardown to run for each test, change {setup to {foreach
            meck:new(db_api),
            meck:expect(db_api, put_friends_for, fun(Key,Names,PID) -> worked end)
            
            end,
            fun(_) ->%This is the teardown fun. Notice it takes one, ignored in this example, parameter.
            meck:unload(db_api)
            end,
        [
            %Package Transfer Test
            ?_assertEqual({reply, worked, some_Db_PID}, silly_mock:handle_call({package_transfered, pack_id, loc_id}, some_from_pid, some_Db_PID)),
            ?_assertEqual({reply, fail, some_Db_PID}, silly_mock:handle_call({package_transfered, bad_id, loc_id}, some_from_pid, some_Db_PID)),
            ?_assertEqual({reply, fail, some_Db_PID}, silly_mock:handle_call({package_transfered, pack_id, bad_id}, some_from_pid, some_Db_PID)),
            ?_assertEqual({reply, fail, some_Db_PID}, silly_mock:handle_call({package_transfered, pack_id, undefined}, some_from_pid, some_Db_PID)),
            ?_assertEqual({reply, fail, some_Db_PID}, silly_mock:handle_call({package_transfered, bad_id, undefined}, some_from_pid, some_Db_PID)),
            ?_assertEqual({reply, fail, some_Db_PID}, silly_mock:handle_call({package_transfered, undefined, loc_id}, some_from_pid, some_Db_PID)),
            ?_assertEqual({reply, fail, some_Db_PID}, silly_mock:handle_call({package_transfered, undefined, bad_id}, some_from_pid, some_Db_PID)),
            ?_assertEqual({reply, fail, some_Db_PID}, silly_mock:handle_call({package_transfered, undefined, undefined}, some_from_pid, some_Db_PID))
        ]
    }.


package_delievered_test()->
    {
        setup,
            fun() -> %this setup fun is run once befor the tests are run. If you want setup and teardown to run for each test, change {setup to {foreach
            meck:new(db_api),
            meck:expect(db_api, put_friends_for, fun(Key,Names,PID) -> worked end)
            
            end,
            fun(_) ->%This is the teardown fun. Notice it takes one, ignored in this example, parameter.
            meck:unload(db_api)
            end,
        [
            %Delievered Test
            ?_assertEqual({reply, worked, some_Db_PID}, silly_mock:handle_call({delivered, pack_id}, some_from_pid, some_Db_PID)),
            ?_assertEqual({reply, fail, some_Db_PID}, silly_mock:handle_call({delivered, bad_id}, some_from_pid, some_Db_PID)),
            ?_assertEqual({reply, fail, some_Db_PID}, silly_mock:handle_call({delivered, undefined}, some_from_pid, some_Db_PID))
        ]
    }.

package_request_test()->
    {
        setup,
            fun() -> %this setup fun is run once befor the tests are run. If you want setup and teardown to run for each test, change {setup to {foreach
            meck:new(db_api),
            meck:expect(db_api, put_friends_for, fun(Key,Names,PID) -> worked end)
            
            end,
            fun(_) ->%This is the teardown fun. Notice it takes one, ignored in this example, parameter.
            meck:unload(db_api)
            end,
        [
            %Request Test
            ?_assertEqual({reply, {worked, 123.0, 456.0}, some_Db_PID}, package_server:handle_call({location_request, pack_id}, some_from_pid, some_Db_PID)),
            ?_assertEqual({reply, fail, some_Db_PID}, package_server:handle_call({location_request, bad_id}, some_from_pid, some_Db_PID)),
            ?_assertEqual({reply, fail, some_Db_PID}, package_server:handle_call({location_request, undefined}, some_from_pid, some_Db_PID))
        ]
    }.

package_update_test()->
    {
        setup,
            fun() -> %this setup fun is run once befor the tests are run. If you want setup and teardown to run for each test, change {setup to {foreach
            meck:new(db_api),
            meck:expect(db_api, put_friends_for, fun(Key,Names,PID) -> worked end)
            
            end,
            fun(_) ->%This is the teardown fun. Notice it takes one, ignored in this example, parameter.
            meck:unload(db_api)
            end,
        [
            %Update Test
            ?_assertEqual({reply, worked, some_Db_PID}, silly_mock:handle_call({location_update, loc_id, 123.0, 456.0}, some_from_pid, some_Db_PID)),
            ?_assertEqual({reply, fail, some_Db_PID}, silly_mock:handle_call({location_update, bad_id, 123.0, 456.0}, some_from_pid, some_Db_PID)),
            ?_assertEqual({reply, fail, some_Db_PID}, silly_mock:handle_call({location_update, loc_id, bad_id, 456.0},some_from_pid, some_Db_PID)),
            ?_assertEqual({reply, fail, some_Db_PID}, silly_mock:handle_call({location_update, loc_id, 123.0, bad_id}, some_from_pid, some_Db_PID)),
            ?_assertEqual({reply, fail, some_Db_PID}, silly_mock:handle_call({location_update, bad_id, bad_id, 456.0}, some_from_pid, some_Db_PID)),
            ?_assertEqual({reply, fail, some_Db_PID}, silly_mock:handle_call({location_update, bad_id, 123.0, bad_id}, some_from_pid, some_Db_PID)),
            ?_assertEqual({reply, fail, some_Db_PID}, silly_mock:handle_call({location_update, loc_id, bad_id, bad_id}, some_from_pid, some_Db_PID)),
            ?_assertEqual({reply, fail, some_Db_PID}, silly_mock:handle_call({location_update, bad_id, bad_id, bad_id}, some_from_pid, some_Db_PID)),
            ?_assertEqual({reply, fail, some_Db_PID}, silly_mock:handle_call({location_update, undefined, 123.0, 456.0}, some_from_pid, some_Db_PID)),
            ?_assertEqual({reply, fail, some_Db_PID}, silly_mock:handle_call({location_update, loc_id, undefined, 456.0}, some_from_pid, some_Db_PID)),
            ?_assertEqual({reply, fail, some_Db_PID}, silly_mock:handle_call({location_update, loc_id, 123.0, undefined}, some_from_pid, some_Db_PID)),
            ?_assertEqual({reply, fail, some_Db_PID}, silly_mock:handle_call({location_update, undefined, undefined, 456.0}, some_from_pid, some_Db_PID)),
            ?_assertEqual({reply, fail, some_Db_PID}, silly_mock:handle_call({location_update, undefined, 123.0, undefined}, some_from_pid, some_Db_PID)),
            ?_assertEqual({reply, fail, some_Db_PID}, silly_mock:handle_call({location_update, loc_id, undefined, undefined}, some_from_pid, some_Db_PID)),
            ?_assertEqual({reply, fail, some_Db_PID}, silly_mock:handle_call({location_update, undefined, undefined, undefined}, some_from_pid, some_Db_PID)),
            ?_assertEqual({reply, fail, some_Db_PID}, silly_mock:handle_call({location_update, bad_id, undefined, 456.0}, some_from_pid, some_Db_PID)),
            ?_assertEqual({reply, fail, some_Db_PID}, silly_mock:handle_call({location_update, bad_id, 123.0, undefined}, some_from_pid, some_Db_PID)),
            ?_assertEqual({reply, fail, some_Db_PID}, silly_mock:handle_call({location_update, undefined, bad_id, 456.0}, some_from_pid, some_Db_PID))
        ]
    }.
        


% server_test() ->
%     {setup,
%         fun() -> %this setup fun is run once befor the tests are run. If you want setup and teardown to run for each test, change {setup to {foreach
%         meck:new(db_api),
%         meck:expect(db_api, put_friends_for, fun(Key,Names,PID) -> worked end)
        
%         end,
%         fun(_) ->%This is the teardown fun. Notice it takes one, ignored in this example, parameter.
%         meck:unload(db_api)
%         end,
%     [
%         %Package Transfer Test
%         ?_assertEqual({reply, worked, some_Db_PID}, silly_mock:handle_call({package_transfered, pack_id, loc_id}, some_from_pid, some_Db_PID)),
%         ?_assertEqual({reply, fail, some_Db_PID}, silly_mock:handle_call({package_transfered, bad_id, loc_id}, some_from_pid, some_Db_PID)),
%         ?_assertEqual({reply, fail, some_Db_PID}, silly_mock:handle_call({package_transfered, pack_id, bad_id}, some_from_pid, some_Db_PID)),
%         ?_assertEqual({reply, fail, some_Db_PID}, silly_mock:handle_call({package_transfered, pack_id, undefined}, some_from_pid, some_Db_PID)),
%         ?_assertEqual({reply, fail, some_Db_PID}, silly_mock:handle_call({package_transfered, bad_id, undefined}, some_from_pid, some_Db_PID)),
%         ?_assertEqual({reply, fail, some_Db_PID}, silly_mock:handle_call({package_transfered, undefined, loc_id}, some_from_pid, some_Db_PID)),
%         ?_assertEqual({reply, fail, some_Db_PID}, silly_mock:handle_call({package_transfered, undefined, bad_id}, some_from_pid, some_Db_PID)),
%         ?_assertEqual({reply, fail, some_Db_PID}, silly_mock:handle_call({package_transfered, undefined, undefined}, some_from_pid, some_Db_PID)),
    
        
%         %Delievered Test
%         ?_assertEqual({reply, worked, some_Db_PID}, silly_mock:handle_call({delivered, pack_id}, some_from_pid, some_Db_PID)),
%         ?_assertEqual({reply, fail, some_Db_PID}, silly_mock:handle_call({delivered, bad_id}, some_from_pid, some_Db_PID)),
%         ?_assertEqual({reply, fail, some_Db_PID}, silly_mock:handle_call({delivered, undefined}, some_from_pid, some_Db_PID)),
    
    
%         %Request Test
%         ?_assertEqual({reply, {worked, 123.0, 456.0}, some_Db_PID}, package_server:handle_call({location_request, pack_id}, some_from_pid, some_Db_PID)),
%         ?_assertEqual({reply, fail, some_Db_PID}, package_server:handle_call({location_request, bad_id}, some_from_pid, some_Db_PID)),
%         ?_assertEqual({reply, fail, some_Db_PID}, package_server:handle_call({location_request, undefined}, some_from_pid, some_Db_PID)),
        

%         %Update Test
%         ?_assertEqual({reply, worked, some_Db_PID}, silly_mock:handle_call({location_update, loc_id, 123.0, 456.0}, some_from_pid, some_Db_PID)),
%         ?_assertEqual({reply, fail, some_Db_PID}, silly_mock:handle_call({location_update, bad_id, 123.0, 456.0}, some_from_pid, some_Db_PID)),
%         ?_assertEqual({reply, fail, some_Db_PID}, silly_mock:handle_call({location_update, loc_id, bad_id, 456.0},some_from_pid, some_Db_PID)),
%         ?_assertEqual({reply, fail, some_Db_PID}, silly_mock:handle_call({location_update, loc_id, 123.0, bad_id}, some_from_pid, some_Db_PID)),
%         ?_assertEqual({reply, fail, some_Db_PID}, silly_mock:handle_call({location_update, bad_id, bad_id, 456.0}, some_from_pid, some_Db_PID)),
%         ?_assertEqual({reply, fail, some_Db_PID}, silly_mock:handle_call({location_update, bad_id, 123.0, bad_id}, some_from_pid, some_Db_PID)),
%         ?_assertEqual({reply, fail, some_Db_PID}, silly_mock:handle_call({location_update, loc_id, bad_id, bad_id}, some_from_pid, some_Db_PID)),
%         ?_assertEqual({reply, fail, some_Db_PID}, silly_mock:handle_call({location_update, bad_id, bad_id, bad_id}, some_from_pid, some_Db_PID)),
%         ?_assertEqual({reply, fail, some_Db_PID}, silly_mock:handle_call({location_update, undefined, 123.0, 456.0}, some_from_pid, some_Db_PID)),
%         ?_assertEqual({reply, fail, some_Db_PID}, silly_mock:handle_call({location_update, loc_id, undefined, 456.0}, some_from_pid, some_Db_PID)),
%         ?_assertEqual({reply, fail, some_Db_PID}, silly_mock:handle_call({location_update, loc_id, 123.0, undefined}, some_from_pid, some_Db_PID)),
%         ?_assertEqual({reply, fail, some_Db_PID}, silly_mock:handle_call({location_update, undefined, undefined, 456.0}, some_from_pid, some_Db_PID)),
%         ?_assertEqual({reply, fail, some_Db_PID}, silly_mock:handle_call({location_update, undefined, 123.0, undefined}, some_from_pid, some_Db_PID)),
%         ?_assertEqual({reply, fail, some_Db_PID}, silly_mock:handle_call({location_update, loc_id, undefined, undefined}, some_from_pid, some_Db_PID)),
%         ?_assertEqual({reply, fail, some_Db_PID}, silly_mock:handle_call({location_update, undefined, undefined, undefined}, some_from_pid, some_Db_PID)),
%         ?_assertEqual({reply, fail, some_Db_PID}, silly_mock:handle_call({location_update, bad_id, undefined, 456.0}, some_from_pid, some_Db_PID)),
%         ?_assertEqual({reply, fail, some_Db_PID}, silly_mock:handle_call({location_update, bad_id, 123.0, undefined}, some_from_pid, some_Db_PID)),
%         ?_assertEqual({reply, fail, some_Db_PID}, silly_mock:handle_call({location_update, undefined, bad_id, 456.0}, some_from_pid, some_Db_PID))
%     ]
%     }.

-endif.