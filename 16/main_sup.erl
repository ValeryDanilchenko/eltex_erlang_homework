-module(main_sup).
-author("ValeryDanilchenko").

-behaviour(supervisor).

%% API
-export([start_link/0, stop_child/1]).

%% Callback
-export([init/1]).

%%%%%%%%%% API %%%%%%%%%%

%% @doc API function starting supervisor process
-spec(start_link() -> {ok, pid()}).
start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

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
        intensity => 10,
        period => 60,
        auto_shutdown => any_significant
    },

    ChildSpec = [
        #{
            id => keylist_sup,
            start => {keylist_sup, start_link, []},
            restart => transient,
            shutdown => infinity,
            significant => true,
            type => supervisor
        },
        #{
            id => keylist_mgr,
            start => {keylist_mgr, start, []},
            restart => transient,
            significant => true,
            shutdown => 5000
        }
    ],

    {ok, {SupervisorSpec, ChildSpec}}.
