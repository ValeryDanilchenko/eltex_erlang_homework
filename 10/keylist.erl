-module(keylist).
-export([loop/1, init/1, terminate/0 ]).
-export([add/4, is_member/2, take/2, find/2, delete/2, start/1, start_link/1, stop/1]).

%% @type describes element
-type(state_element() :: {
    Key :: atom() | string(), 
    Value :: atom() | string(), 
    Comment:: atom() | string()
}).

-record(state, {
    list = []   :: list(state_element()),
    counter = 0 :: non_neg_integer()}).


%% @doc API function thats register new process and starts main loop
-spec(init(atom()) -> 
    no_return()).
init(Name) ->
    register(Name, self()),
    loop(#state{}).

%% @doc API function spawning new monitored process
-spec(start(Name :: atom()) -> 
    {Pid :: pid(), MonitorRef :: reference()}).
start(Name) ->
    {Pid, MonitorRef} = spawn_monitor(keylist, init, [Name]),
    {Pid, MonitorRef}.


%% @doc API function spawning new linked process
-spec(start_link(Name :: atom()) ->
    Pid :: pid()).
start_link(Name) ->
    Pid = spawn_link(keylist, init, [Name]),
    Pid.

%% @doc API function to exit process
-spec(terminate() -> 
    ok).
terminate() ->
    ok.

%% @doc API function thats add new element to the state
-spec(add(Name :: atom(), Key :: atom() | string(), Value :: atom() | string(), Comment :: atom() | string()) ->
    ok).
add(Name, Key, Value, Comment) -> 
    Name ! {self(), add, Key, Value, Comment},
    ok.

%% @doc API function thats checking if element is member of the state
-spec(is_member(Name :: atom(), Key :: atom()| string()) ->
    ok).
is_member(Name, Key)->
    Name ! {self(), is_member, Key},
    ok.

%% @doc API function that returns element`s data by is`s key and deletes it from state
-spec(take(Name :: atom(), Key :: atom()| string()) ->
    ok).
take(Name, Key)-> 
    Name ! {self(), take, Key},
    ok.

%% @doc API function that returns element`s data by is`s key
-spec(find(Name :: atom(), Key :: atom()| string()) ->
    ok).
find(Name, Key) -> 
    Name ! {self(), find, Key},
    ok.

%% @doc API function that deletes the element from state
-spec(delete(Name :: atom(), Key :: atom()| string()) ->
    ok).
delete(Name, Key)->
    Name ! {self(), delete, Key},
    ok.

%% @doc API function that stops main process
-spec(stop(Name :: atom()) ->
    ok).
stop(Name)->
    Name ! stop,
    ok.


%%%%%% PRIVATE FUNCTIONS %%%%%%

-spec(loop(#state{list :: list(), counter :: non_neg_integer()}) ->
    ok).
loop(#state{list = List, counter = Counter} = State) ->
    receive
        {From, add, Key, Value, Comment} ->
            NewState = State#state{list = [{Key, Value, Comment} | List], counter = Counter + 1},
            From ! {ok, NewState},
            loop(NewState);
        {From, is_member, Key} ->
            Result = lists:keymember(Key, 1, List),
            NewState = State#state{counter = Counter + 1},
            From ! {Result, NewState},
            loop(NewState);
        {From, take, Key} ->
            {_, Element, NewList} = lists:keytake(Key, 1, List),
            NewState = State#state{list = NewList, counter = Counter + 1},
            From ! {Element, NewState},
            loop(NewState);
        {From, find, Key} ->
            Element = lists:keyfind(Key, 1, List),
            NewState = State#state{counter = Counter + 1},
            From ! {Element, NewState},
            loop(NewState);
        {From, delete, Key} ->
            NewState = State#state{list = lists:keydelete(Key, 1, List), counter = Counter + 1},
            From ! {ok, NewState},
            loop(NewState); 
        stop ->
            keylist:terminate()
    end.
