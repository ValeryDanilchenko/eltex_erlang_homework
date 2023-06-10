-module(keylist).
-author("ValeryDanilchenko").

-behaviour(gen_server).


-define(LOCALNAME, element(2, process_info(self(), registered_name))).

-record(keylist_element,{
    key     :: atom(),
    value   :: atom() | string(),
    comment :: atom() | string(), 
    owner   :: atom() | pid()
}).

-type(keylist_element() :: #keylist_element{    
    key     :: atom(),
    value   :: atom() | string(),
    comment :: atom() | string(),
    owner   :: atom() | pid()
}).


%% @type describes state keylist_element thats include Key, Value, Comment
%% it could be contained in #state.list or sent to add function
-type(state_element() :: {
    Key :: atom() | string(), 
    Value :: atom() | string(), 
    Comment:: atom() | string()
}).


%% API
-export([start/1, start_link/1, stop/1, stop_async/1]).
-export([add/4, is_member/2, take/2, find/2, delete/2]).
-export([match/2, match_object/2, select/2, print_state/1]).

%% Callback
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2]).


%%%%%%%%%% API %%%%%%%%%%

%% @doc API function for spawn, register and monitor generic server process
-spec(start(Name :: atom()) -> {ok, pid()}).
start(Name) ->
    gen_server:start_monitor({local, Name}, ?MODULE, [], []).
    
%% @doc API function for spawn, register and link generic server process
-spec(start_link(Name :: atom()) -> 
    {ok, {pid(), reference()}}).
start_link(Name) ->
    gen_server:start_link({local, Name}, ?MODULE, [], []).

%% @doc API function for generic server stop_async process to exit with 'normal' reason
-spec(stop(Name :: atom()) -> ok).
stop(Name)->
    gen_server:stop(Name).

%% @doc async API function for generic server stop_async process to exit with 'normal' reason
-spec(stop_async(Name :: atom()) -> ok).
stop_async(Name) ->
    gen_server:cast(Name, stop_async).

%% @doc sync API function for additing new keylist_element into ETS
-spec(add(Name :: atom(), Key :: atom() | string(), Value :: atom() | string(), Comment:: atom() | string()) ->
    {ok, keylist_element()}).
add(Name, Key, Value, Comment) ->
    gen_server:call(Name, {add, Key, Value, Comment}).


%% @doc sync API function for checking if the keylist_element is in ETS
-spec(is_member(Name :: atom(), Key ::atom() | string()) -> boolean()).
is_member(Name, Key) ->
    gen_server:call(Name, {is_member, Key}).

%% @doc sync API function for returns state keylist_element by its key and deletes it from ETS
-spec(take(Name :: atom(), Key ::atom() | string()) ->
    {ok, keylist_element()} | {false, badkey}).
take(Name, Key) ->
    gen_server:call(Name, {take, Key}).

%% @doc sync API function returns keylist_element by its key from ETS
-spec(find(Name :: atom(), Key ::atom() | string()) ->
    {ok, keylist_element()} | {false, badkey}).
find(Name, Key) ->
    gen_server:call(Name, {find, Key}).

%% @doc sync API function deletes keylist_element from ETS by its key
-spec(delete(Name :: atom(), Key ::atom() | string()) -> ok).
delete(Name, Key) ->
    gen_server:call(Name, {delete, Key}).

%% @doc sync API function for return list of State elements
-spec(print_state(Name :: atom()) ->
    list(state_element())).
print_state(Name) ->
    gen_server:call(Name, print_state).

%% @doc sync API function matches the objects in table keylist_ets against pattern Pattern
-spec match(Name :: atom(), Pattern :: ets:match_pattern()) -> {ok, list()}.
match(Name, Pattern) ->
    gen_server:call(Name, {match, Pattern}).

%% @doc sync API function matches the objects in table Table against pattern Pattern. 
%% For a description of patterns, see match/2. 
%% The function returns a list of all objects that match the pattern.
-spec match_object(Name :: atom(), Pattern :: ets:match_pattern()) -> {ok, list()}.
match_object(Name, Pattern) ->
    gen_server:call(Name, {match_object, Pattern}).

%% @doc sync API function Matches the objects in table Table using a match specification
-spec select(Name :: atom(), Filter :: fun()) -> {ok, list()}.
select(Name, Filter) ->
    gen_server:call(Name, {select, Filter}).

%%%%%%%%%% CALLBACK %%%%%%%%%%

init(_Args = State) ->
    io:format("~p: Init callback was called~n", [?LOCALNAME]),
    {ok, State}.


handle_call({add, Key, Value, Comment}, _From, State) ->
    NewElement = #keylist_element{key = Key, value = Value, comment = Comment, owner = ?LOCALNAME},
    ets:insert(keylist_ets, NewElement),
    {reply, {ok, NewElement}, State};
handle_call({is_member, Key}, _From, State) ->
    {reply, ets:member(keylist_ets, Key), State};
handle_call({take, Key}, _From, State) ->
    case ets:take(keylist_ets, Key) of
        [Element] ->
            {reply, {ok, Element}, State};
        [] ->
            {reply, {false, badkey}, State}
    end;
handle_call({find, Key}, _From, State) ->
    case ets:lookup(keylist_ets, Key) of   
    [Element] ->
        {reply, {ok, Element}, State};
    [] ->
        {reply, {false, badkey}, State}
    end;
handle_call({delete, Key}, _From, State) ->
    ets:delete(keylist_ets, Key),
    {reply, ok, State};
handle_call(print_state, _From, State) ->
    Objects = ets:match_object(keylist_ets, #keylist_element{owner = ?LOCALNAME, _ = '_'}), 
    {reply, Objects, State};
handle_call({match, Pattern}, _From, State) ->
    Result = ets:match(keylist_ets, Pattern),
    {reply, {ok, Result}, State};
handle_call({match_object, Pattern}, _From, State) ->
    Result = ets:match_object(keylist_ets, Pattern),
    {reply, {ok, Result}, State};
handle_call({select, Filter}, _From, State) ->
    Result = ets:select(keylist_ets, ets:fun2ms(Filter)),
    {reply, {ok, Result}, State}.


handle_cast(stop_async, State) ->
    {stop, normal, State}.
    
handle_info({added_new_child, NewPid, NewName}, State) ->
    io:format("~p: Added new process ~p with pid ~p~n",[?LOCALNAME, NewName, NewPid]),
    {noreply, State};        
handle_info(Info, State) ->
    io:format("~p: Received message ~p ~n", [?LOCALNAME, Info]),
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.