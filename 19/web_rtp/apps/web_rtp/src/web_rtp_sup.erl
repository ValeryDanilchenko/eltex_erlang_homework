%%%-------------------------------------------------------------------
%% @doc web_rtp top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(web_rtp_sup).
-author("ValeryDanilchenko").

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Callback
-export([init/1]).

-define(SERVER, ?MODULE).

%%%%%%%%%% API %%%%%%%%%%
%% @doc API function starting supervisor process
start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).


%%%%%%%%%% Callback %%%%%%%%%%
init([]) ->
    io:format("Module ~p was started!~n", [?MODULE]),
    SupFlags = #{strategy => one_for_all,
                 intensity => 0,
                 period => 1},
    ChildSpecs = [],
    {ok, {SupFlags, ChildSpecs}}.

