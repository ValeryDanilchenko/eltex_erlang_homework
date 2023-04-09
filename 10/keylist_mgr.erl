%%  @doc process menager
-module(keylist_mgr).


%% @type includes info about starting process: it`s name and is it permonentor not
%% if it is we will restrt it by the time it crash
-type(parameters() :: #{
    name => atom(),
    restart => permanent | temporary
    }).

%% Callback
-export([loop/1,  init/0, terminate/1]).
%% API funs
-export([ start/0, start_child/1, stop_child/1, stop/0, get_names/0]). 

-record(state, {
        children = []   :: list({atom(), pid()}),
        permanent = []  :: list(pid())
    }).


%% @doc API function thats register keylist_mgr process, set process_flag and start the main loop
-spec(init() -> 
    no_return()).
init() ->
    process_flag(trap_exit, true),
    register(?MODULE, self()),
    loop(#state{}).

%% @doc API function starting new monitor process
-spec(start() -> 
    {ok, Pid :: pid(), MonitorRef :: reference()}).
start() ->
    {Pid, MonitorRef} = spawn_monitor(?MODULE, init, []),
    {ok, Pid, MonitorRef}.



%% @doc API function for stop process manager and stop all child processes
-spec(terminate(#state{children :: list(), permanent :: list()}) -> ok).
terminate(#state{children = _Children} = State) ->
    lists:foreach(
                fun({Name, _Pid}) ->
                    keylist:stop(Name)
                end,
                State#state.children),
                ok.

%% @doc API function sending message to main process initialising starting the child process
-spec(start_child(parameters()) -> ok | badarg).
start_child(#{name := _Name , restart := _Restart} = Params) ->
    keylist_mgr ! {self(), start_child, Params},
    ok;
start_child(_Params) ->
    badarg.

    
 
%% @doc API function sending message to main process which stops this child process
-spec(stop_child(Name :: atom()) -> ok).    
stop_child(Name) ->
    keylist_mgr ! {self(), stop_child, Name},
    ok.



%% @doc API function sending message 'stop' to the main process which stops all the children and itself 
-spec(stop() -> ok).
stop() ->
    keylist_mgr ! stop,
    ok.


%% @doc API function sending message to the main process which sends info about child processes
-spec(get_names() -> ok).
get_names() ->
    keylist_mgr ! {self(), get_names},
    ok.


%%%%%% PRIVATE FUNCTIONS %%%%%%

-spec(loop(#state{children :: list({string(), pid()}), permanent :: list(pid())}) ->
    ok).
loop(#state{children = Children, permanent = Permanent} = State) ->
    receive
        {From, start_child, #{name := Name, restart := Restart}}  ->
            case proplists:is_defined(Name, Children) of
                {Name, _Pid} ->
                    io:format("Process ~p is alredy started  ~n",[Name]),
                    From ! {error, already_started},
                    loop(State);
                false ->
                    Pid = keylist:start_link(Name),
                    case Restart of
                        permanent -> 
                            NewState = State#state{children = [{Name, Pid} | Children], permanent = [Pid | Permanent]};
                        temporary ->
                            NewState = State#state{children = [{Name, Pid} | Children], permanent = Permanent}
                    end,
                    From ! {ok, Pid},
                    loop(NewState)
            end;
        {From, stop_child, Name} ->
            case proplists:is_defined(Name, Children) of
                true ->
                    keylist:stop(Name),
                    NewState = State#state{children = proplists:delete(Name, Children),
                            permanent = lists:delete(whereis(Name), Permanent)},
                    From ! {ok, NewState},
                    loop(NewState);
                false ->
                    From ! {error, undefined},
                    loop(State)
            end;
         stop ->
            keylist_mgr:terminate(State);
        {From, get_names} ->
            Names = [Name || {Name, _Pid} <- Children],
            From ! {ok, lists:reverse(Names)},
            loop(State);
        {'EXIT', Pid, Reason} ->
            case lists:keyfind(Pid, 2, Children) of
                {Name, Pid} ->
                    case lists:member(Pid, Permanent) of
                        true -> 
                            NewPid = keylist:start_link(Name),
                            NewState = State#state{children = [{Name, NewPid} | proplists:delete(Name, Children)], 
                                    permanent = [NewPid | lists:delete(Pid, Permanent)]},
                            io:format("Process ~p 'DOWN' with reason: ~p. Restared with PID ~p~n", [Pid, Reason, NewPid]);
                        false ->
                            NewState = State#state{children = proplists:delete(Name, Children), permanent = Permanent},
                            io:format("Process ~p 'DOWN' with reason: ~p~n",[Pid, Reason])
                    end,
                    loop(NewState);
                false ->
                    loop(State)
            end
    end.

