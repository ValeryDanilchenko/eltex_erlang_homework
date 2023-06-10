-module(keylist_mgr).
-export([loop/1, start/0]).
-export([start_child/1, stop_child/1, stop/0, get_names/0]).

-record(state, {children = [], permanent = []}).

start() ->
    {Pid, MonitorRef} = spawn_monitor(?MODULE, loop, [#state{}]),
    register(?MODULE, Pid),
    {ok, Pid, MonitorRef}.

start_child(Params) ->
    case Params of
        #{name := _Name , restart := _Restart} ->
            keylist_mgr ! {self(), start_child, Params};
        _ ->
            badarg
    end.
    
stop_child(Name) ->
    keylist_mgr ! {self(), stop_child, Name}.

stop() ->
    keylist_mgr ! stop.

get_names() ->
    keylist_mgr ! {self(), get_names}.


loop(#state{children = Children, permanent = Permanent} = State) ->
    process_flag(trap_exit, true),
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
                    exit(whereis(Name), stop_child),
                    NewState = State#state{children = proplists:delete(Name, Children), permanent = lists:delete(whereis(Name), Permanent)},
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
            From ! {ok, lists:reverse(Names)},
            loop(State);
        {'EXIT', Pid, Reason} ->
            case lists:keyfind(Pid, 2, Children) of
                {Name, Pid} ->
                    case lists:member(Pid, Permanent) of
                        true -> 
                            NewPid = keylist:start_link(Name),
                            NewState = State#state{children = [{Name, NewPid} | proplists:delete(Name, Children)], permanent = [NewPid | lists:delete(Pid, Permanent)]},
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


