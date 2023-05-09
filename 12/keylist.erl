-module(keylist).
-author("ValeryDanilchenko").

-behaviour(gen_server).

%% @type describes state element thats include Key, Value, Comment
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
-export([add/4, is_member/2, take/2, find/2, delete/2, print_state/1]).

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

%% @doc sync API function for additing new state element into #state.list
-spec(add(Name :: atom(), Key :: atom() | string(), Value :: atom() | string(), Comment:: atom() | string()) ->
    {ok, state()}).
add(Name, Key, Value, Comment) ->
    gen_server:call(Name, {add, Key, Value, Comment}).


%% @doc sync API function for checking if the element is in State
-spec(is_member(Name :: atom(), Key ::atom() | string()) ->
    {boolean(), non_neg_integer()}).
is_member(Name, Key) ->
    gen_server:call(Name, {is_member, Key}).

%% @doc sync API function for returns state element by its key and deletes it from the State
-spec(take(Name :: atom(), Key ::atom() | string()) ->
    {state_element(), non_neg_integer()} | {false, badkey, non_neg_integer()}).
take(Name, Key) ->
    gen_server:call(Name, {take, Key}).

%% @doc sync API function for returns state element by its ke
-spec(find(Name :: atom(), Key ::atom() | string()) ->
    {false | state_element(), non_neg_integer()}).
find(Name, Key) ->
    gen_server:call(Name, {find, Key}).

%% @doc sync API function for deletes element from the State by its key and returns remaining State
-spec(delete(Name :: atom(), Key ::atom() | string()) ->
    {ok, state()}).
delete(Name, Key) ->
    gen_server:call(Name, {delete, Key}).


%% @doc sync API function for return list of State elements
-spec(print_state(Name :: atom()) ->
    list(state_element())).
print_state(Name) ->
    gen_server:call(Name, print_state).

%%%%%%%%%% CALLBACK %%%%%%%%%%

init(_Args) ->
    {ok, #state{}}.

handle_call({add, Key, Value, Comment}, _From, #state{list = List, counter = Counter} = State) ->
    NewState = State#state{list = [{Key, Value, Comment} | List], counter = Counter + 1},
    {reply, {ok, NewState}, NewState};

handle_call({is_member, Key}, _From, #state{list = List, counter = Counter} = State) ->
    Result = lists:keymember(Key, 1, List),
    NewState = State#state{counter = Counter + 1},
    {reply, {Result, NewState#state.counter}, NewState};

handle_call({take, Key}, _From, #state{list = List, counter = Counter} = State) ->
    Result = lists:keytake(Key, 1, List),
    case Result of
        false ->
            NewState = State#state{counter = Counter + 1},
            {reply, {false, badkey, NewState#state.counter}, NewState};
        _ ->
            NewState = State#state{list = element(3, Result), counter = Counter + 1},
            {reply, {ok, Result, NewState#state.counter}, NewState}
    end;

handle_call({find, Key}, _From, #state{list = List, counter = Counter} = State) ->
    Element = lists:keyfind(Key, 1, List),
    NewState = State#state{counter = Counter + 1},
    {reply, {Element, NewState#state.counter}, NewState};

handle_call({delete, Key}, _From, #state{list = List, counter = Counter} = State) ->
    NewState = State#state{list = lists:keydelete(Key, 1, List), counter = Counter + 1},
    {reply, {ok, NewState}, NewState};

handle_call(print_state, _From, #state{list = List} = State) ->
    {reply, List, State}.


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