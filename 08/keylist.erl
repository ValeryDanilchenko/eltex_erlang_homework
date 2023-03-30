-module(keylist).
-export([loop/1, start/1, start_link/1]).

-record(state, {list = [], counter = 0}).

loop(#state{list = List, counter = Counter} = State) ->
    receive
        {From, add, Key, Value, Comment} ->
            NewState = State#state{list = [{Key, Value, Comment} | List], counter = Counter + 1},
            From ! {ok, NewState#state.counter},
            loop(NewState);

        {From, is_member, Key} ->
            Result = lists:keymember(Key, 1, List),
            NewState = State#state{counter = Counter + 1},
            From ! {Result, NewState#state.counter},
            loop(NewState);

        {From, take, Key} ->
            {Result, NewList} = 
                case lists:keytake(Key, 1, List) of
                    {value, {_, Value, Comment}, Rest} -> 
                            {{ok, Value, Comment}, Rest};
                    false -> {not_found, List}
                end,
            NewState = State#state{list = NewList, counter = Counter + 1},
            From ! {Result, NewState#state.counter},
            loop(NewState);

        {From, find, Key} ->
            Result = 
                case lists:keyfind(Key, 1, List) of
                    {Key, Value, Comment} -> {ok, Value, Comment};
                    false -> not_found
                end,
            NewState = State#state{counter = Counter + 1},
            From ! {Result, NewState#state.counter},
            loop(NewState);

        {From, delete, Key} ->
            NewList = lists:keydelete(Key, 1, List),
            NewState = State#state{list = NewList, counter = Counter + 1},
            From ! {ok, NewState#state.counter},
            loop(NewState)
    end.



start(Name) ->
    Pid = spawn(keylist, loop, [#state{}]),
    register(Name, Pid),
    MonitorRef = erlang:monitor(process, Pid),
    {ok, Pid, MonitorRef}.

start_link(Name) ->
    Pid = spawn_link(keylist, loop, [#state{}]),
    register(Name, Pid),
    Pid.