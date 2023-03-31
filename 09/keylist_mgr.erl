-module(keylist_mgr).
-export([loop/1, start/0]).
-export([start_child/1, stop_child/1, stop/0, get_names/0]).

-record(state, {children = []}).

start_child(Name) ->
    keylist_mgr ! {self(), start_child, Name}.
    
stop_child(Name) ->
    keylist_mgr ! {self(), stop_child, Name}.

stop() ->
    keylist_mgr ! stop.

get_names() ->
    keylist_mgr ! {self(), get_names}.


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
                true ->
                    exit(whereis(Name), stop_child),
                    NewState = State#state{children = proplists:delete(Name, Children)},
                    From ! {ok, NewState},
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
            case lists:keyfind(Pid, 2, Children) of
                {Name, Pid} ->
                    io:format("Process ~p 'DOWN' with reason: ~p~n", [Pid, Reason]),
                    NewState = State#state{children = proplists:delete(Name, Children)},
                    loop(NewState);
                false ->
                    io:format("Process ~p undefined ~n",[Pid]),
                    loop(State)
            end
    end.

start() ->
    Pid = spawn(?MODULE, loop, [#state{}]),
    register(?MODULE, Pid),
    MonitorRef = erlang:monitor(process, Pid),
    {ok, Pid, MonitorRef}.
