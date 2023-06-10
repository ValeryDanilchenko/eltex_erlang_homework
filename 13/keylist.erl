-module(keylist).
-author("ValeryDanilchenko").

-behaviour(gen_server).

-include("keylist_element.hrl").

-type(keylist_element() :: #keylist_element{    
    key     :: atom(),
    value   :: atom() | string(),
    comment :: atom() | string()
}).


%% @type describes state keylist_element thats include Key, Value, Comment
%% it could be contained in #state.list or sent to add function
-type(state_element() :: {
    Key :: atom() | string(), 
    Value :: atom() | string(), 
    Comment:: atom() | string()
}).

-record(state, {
    list = []   :: list(state_element()),
    counter = 0 :: non_neg_integer()
}).

%% @type describes record 'state'
-type state() :: #state{
    list    :: list(state_element()),
    counter :: non_neg_integer() }.


%% API
-export([start/1, start_link/1, stop/1, stop_async/1]).
-export([add/4, is_member/2, take/2, find/2, delete/2]).

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
-spec(delete(Name :: atom(), Key ::atom() | string()) ->
    {ok, state()}).
delete(Name, Key) ->
    gen_server:call(Name, {delete, Key}).

%%%%%%%%%% CALLBACK %%%%%%%%%%

init(_Args) ->
    {ok, #state{}}.

handle_call({add, Key, Value, Comment}, _From, State) ->
    NewElement = #keylist_element{key = Key, value = Value, comment = Comment},
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
    {reply, ok, State}.


handle_cast(stop_async, State) ->
    {stop, normal, State}.

    
handle_info({added_new_child, NewPid, NewName}, State) ->
    io:format("Msg received by ~p: Aded new process ~p with pid ~p~n",[self(), NewName, NewPid]),
    {noreply, State};        
handle_info(Info, State) ->
    io:format("Received info message ~p ~n", [Info]),
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.