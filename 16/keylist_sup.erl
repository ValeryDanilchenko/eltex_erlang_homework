-module(keylist_sup).
-author("ValeryDanilchenko").

-behaviour(supervisor).

%% API
-export([start_link/0, start_child/1, stop_child/1]).

%% Callback
-export([init/1]).


%%%%%%%%%% API %%%%%%%%%%

%% @doc API function starting supervisor process
-spec(start_link() -> {ok, pid()}).
start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%% @doc API function dynamically starts the child process with received params for ChildSpec
-spec(start_child(#{name => atom(), restart => permanent | temporary}) -> 
    {ok, pid()}).
start_child(#{name := Name, restart := Restart}) ->
    ChildSpec =       
        #{
            id => Name,
            start => {keylist, start_link, [Name]},
            restart => Restart,
            shutdown => 2000
        },
    supervisor:start_child(?MODULE, ChildSpec).

%% @doc API function for stop and delete the child process with reason normal
-spec(stop_child(Name :: atom()) -> ok).   
stop_child(Name) ->
    supervisor:terminate_child(?MODULE, Name),
    supervisor:delete_child(?MODULE, Name).

%%%%%%%%%% Callback %%%%%%%%%%
init(_Args) ->
    io:format("~p: Init callback was called~n", [?MODULE]),
    SupervisorSpec = #{
        strategy => one_for_one, 
        intensity => 1,
        period => 5},

    ChildSpec = [],

    {ok, {SupervisorSpec, ChildSpec}}.
