-module(door).
-author("ValeryDanilchenko").

-behaviour(gen_statem).

%% API %%
-export([start/1, stop/0, enter/1, print_entered/0]).

%% Callbacks %%
-export([init/1, terminate/3, callback_mode/0, locked/3, open/3, suspended/3]).


-define(ATTEMPTS_LIMIT, 3).

% %% @type describes code for door thats includes list with 4 single digits
% -type( code() :: list([non_neg_integer(), non_neg_integer(), non_neg_integer(), non_neg_integer()])).


-record(data, {
    code         :: list(non_neg_integer()),
    attempt = 1  :: non_neg_integer(), 
    entered = [] :: list(non_neg_integer())
}).


% %% @type describes record 'data'
% -type data() :: #data{
%     code        :: code(),
%     attempt     :: non_neg_integer(), 
%     entered     :: list(non_neg_integer())
% }.


%%%%%%%%%%%% API %%%%%%%%%%%%

%% @doc This function starts the door state management process, initializing the code . 
-spec( start(InitCode :: list(non_neg_integer())) -> {ok, pid()} | {error, term()}).
start(InitCode) ->
    gen_statem:start({local, ?MODULE}, ?MODULE, InitCode, []).


%% @doc This function stops the door state management process. Returns an error code or the atom 'ok'.
-spec( stop() -> ok | {error, term()}).
stop() ->
    gen_statem:stop(?MODULE).


%% @doc This function is used to enter digits on the door code lock. Takes a digit Num as input. 
%% Returns an error code or the atom 'ok' depending on whether the correct code was entered to open the door.
-spec( enter(Num :: non_neg_integer()) -> 
    {ok, next | opened} | {error, wrong_code | attempt_limit_reached | already_opened | suspended}).
enter(Num) ->
    gen_statem:call(?MODULE, {enter, Num}).


%% @doc This function is used for debugging. 
%% Prints to the screen a list of digits that were entered on the door lock.
-spec( print_entered() -> ok).
print_entered() ->
    gen_statem:cast(?MODULE, print_entered).


%%%%%%%%%%%% Callbacks %%%%%%%%%%%%

init(InitCode) ->
    io:format("Initializing locked door.~n", []),
    {ok, locked, #data{code = InitCode}}.

callback_mode() ->
    state_functions.


locked({call, From}, {enter, Num} = Msg, #data{code = Code, attempt = Attempt, entered = Entered} = Data) ->
    NewEntered = [Num | Entered], 
    io:format("Received Msg ~p LoopData ~p~n Entered len: ~p~n Code len: ~p~n", [Msg, Data, length(NewEntered), length(Code)]), 

    case length(NewEntered) == length(Code) of 
        false ->
            NewData = Data#data{entered = NewEntered},
            {keep_state, NewData, [{reply, From, {ok, next}}]};
        
        true ->
            case Code == lists:reverse(NewEntered) of
                false ->
                    case Attempt == ?ATTEMPTS_LIMIT of 
                        false ->
                            NewData = Data#data{attempt = Attempt + 1, entered = []},
                            {keep_state, NewData, [{reply, From, {error, wrong_code}}]};
                        true ->
                            NewData = Data#data{attempt = 1, entered = []},
                            {next_state, suspended, NewData, [{reply, From, {error, attempt_limit_reached}}, {state_timeout, 10000, suspended_timeout}]}
                    end;
                true ->
                    NewData = Data#data{attempt = 1, entered = []},
                    {next_state, open, NewData, [{reply, From, {ok, opened}}, {state_timeout, 5000, open_timeout}]}
            end
    end;

locked(cast, print_entered, #data{entered = Entered}) ->
    io:format("Entered, ~p~n", [Entered]),
    keep_state_and_data;
locked(info, Msg, _Data) ->
    io:format("Received ~p~n", [Msg]),
    keep_state_and_data.


open({call, From}, {enter, Num}, _Data) ->
    io:format("Ignored ~p. Door already opened ~n", [Num]), 
    {keep_state_and_data, [{reply, From, {error, already_opened}}]};
open(state_timeout, open_timeout, Data) ->
    io:format("Timeout, the door will be locked~n"),
    {next_state, locked, Data}.


suspended({call, From}, {enter, Num}, _Data) ->
    io:format("Ignored ~p. Door suspended ~n", [Num]), 
    {keep_state_and_data, [{reply, From, {error, suspended}}]};
suspended(state_timeout, suspended_timeout, Data) ->
    io:format("Door enabled to enter code~n"),
    {next_state, locked, Data}.


terminate(Reason, State, Data ) ->
    io:format("Terminated with reason: ~p~n state: ~p~n data: ~p~n", [Reason, State, Data]),
    ok.