-module(keylist).
-export([loop/1, start/1, start_link/1]).
-export([add/4, is_member/2, take/2, find/2, delete/2, stop/1]).

-record(state, {list = [], counter = 0}).

start(Name) ->
    Pid = spawn(keylist, loop, [#state{}]),
    register(Name, Pid),
    MonitorRef = erlang:monitor(process, Pid),
    {ok, Pid, MonitorRef}.

start_link(Name) ->
    Pid = spawn_link(keylist, loop, [#state{}]),
    register(Name, Pid),
    Pid.

add(Name, Key, Value, Comment) ->
    Name ! {self(), add, Key, Value, Comment}.

is_member(Name, Key) ->
    Name ! {self(), is_member, Key}.

take(Name, Key) ->
    Name ! {self(), take, Key}.

find(Name, Key) ->
    Name ! {self(), find, Key}.

delete(Name, Key) ->
    Name ! {self(), delete, Key}.
       
stop(Name)->
    Name ! stop.


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
                    {Key, Value, Comment} -> 
                        {ok, Value, Comment};
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
        stop ->
            ok
    end.
