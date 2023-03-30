-module(keylist_mgr).
-export([loop/1, start/0]).

-record(state, {children = []}).

loop(#state{children = Children} = State) ->
    process_flag(trap_exit, true),
    receive
        {From, start_child, Name} ->
            case proplists:is_defined(Name, Children) of
                {Name, _Pid} ->
                    From ! {error, already_started},
                    loop(State);
                false ->
                    Pid = keylist:start_link(Name),
                    NewState = State#state{children = [{Name, Pid} | Children]},
                    From ! {ok, Pid},
                    loop(NewState)
            end;
        {From, stop_child, Name} ->
            case proplists:is_defined(Name, Children) of
                {Name, Pid} ->
                    keylist:stop(Pid),
                    NewState = State#state{children = proplists:delete(Name, Children)},
                    From ! ok,
                    loop(NewState);
                false ->
                    From ! {error, not_found},
                    loop(State)
            end;
        stop ->
            exit(kill);
        {From, get_names} ->
            Names = [Name || {Name, _Pid} <- Children],
            From ! {ok, Names},
            loop(State);
        {'EXIT', Pid, Reason} ->
            io:format("Process ~p exited with reason: ~p~n", [Pid, Reason]),
            NewState = State#state{children = proplists:delete(Pid, Children)},
            loop(NewState)
    end.

start() ->
    Pid = spawn(?MODULE, loop, [#state{}]),
    register(?MODULE, Pid),
    MonitorRef = erlang:monitor(process, Pid),
    {ok, Pid, MonitorRef}.
