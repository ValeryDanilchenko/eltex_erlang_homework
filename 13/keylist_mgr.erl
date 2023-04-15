-module(keylist_mgr).
-author("ValeryDanilchenko").

-behaviour(gen_server).

-include("keylist_element.hrl").

%% @type includes info about starting process: it`s name and is it permonentor not
%% if it is we will restrt it by the time it crash
-type(parameters() :: #{
    name => atom(),
    restart => permanent | temporary
    }).

-record(state, {
        children = []   :: list({atom(), pid()}),
        permanent = []  :: list(pid())
    }).

-type(state() :: #state{
        children    :: list({atom(), pid()}),
        permanent   :: list(pid())
    }).

%% API 
-export([ start/0, stop/0, start_child/1, stop_child/1,  get_names/0]). 

%% Callback
-export([init/1, terminate/2, handle_call/3, handle_info/2]).


%%%%%%%%%% API %%%%%%%%%%

%% @doc API function for spawn and monitor generic server process
-spec(start() -> 
    {ok, {Pid :: pid(), MonitorRef :: reference()}}).
start() ->
    gen_server:start_monitor({local, ?MODULE}, ?MODULE, [], []).


%% @doc API function for stop process manager and stop all child processes
-spec(stop() -> ok).
stop() ->
    gen_server:stop(?MODULE).

%% @doc sync API function initialising starting the child process
-spec(start_child(parameters()) -> 
    {ok, pid()} | {error, {already_started, pid()}}).
start_child(#{name := _Name , restart := _Restart} = Params) ->
    gen_server:call(?MODULE, {start_child, Params}).

%% @doc sync API function for stop the child process
-spec(stop_child(Name :: atom()) -> 
    {ok, state()} | {error, undefined}).   
stop_child(Name) ->
    gen_server:call(?MODULE, {stop_child, Name}).

%% @doc sync API function returns info about child processes
-spec(get_names() -> {ok, list({atom(), pid()})}).
get_names() ->
    gen_server:call(?MODULE, get_names).


%%%%%%%%%% CALLBACK %%%%%%%%%%

init(_Args) ->
    process_flag(trap_exit, true),
    ets:new(keylist_ets, [public, ordered_set, named_table, {keypos, #keylist_element.key}]),
    {ok, #state{}}.


handle_call({start_child, #{name := Name, restart := Restart}}, _From, #state{children = Children, permanent = Permanent} = State)
    when is_list(Children), is_list(Permanent), is_atom(Name), is_atom(Restart) ->
        case proplists:is_defined(Name, Children) of
                true ->
                    io:format("Process ~p is alredy started  ~n",[Name]),
                    {reply, {error, already_started}, State};
                false ->
                    {ok, Pid} = keylist:start_link(Name),
                    case Restart of
                        permanent -> 
                            NewState = State#state{children = [{Name, Pid} | Children], permanent = [Pid | Permanent]};
                        temporary ->
                            NewState = State#state{children = [{Name, Pid} | Children], permanent = Permanent}
                    end,
                lists:foreach(
                    fun({_, ChildPid}) -> 
                        ChildPid ! {added_new_child, Pid, Name} 
                    end,  Children),                    
                    {reply, {ok, Pid}, NewState}
            end;

handle_call({stop_child, Name}, _From, #state{children = Children, permanent = Permanent} = State) 
    when is_list(Children), is_list(Permanent), is_atom(Name) ->
        case proplists:is_defined(Name, Children) of
            true ->
                keylist:stop(Name),
                NewState = State#state{children = proplists:delete(Name, Children),
                        permanent = lists:delete(whereis(Name), Permanent)},
                {reply, {ok, NewState}, NewState};
            false ->
                {reply, {error, undefined}, State}
        end;

handle_call(get_names, _From, #state{children = Children, permanent = Permanent} = State) 
    when is_list(Children), is_list(Permanent) ->
        Names = proplists:get_keys(Children),
        {reply, {ok, Names}, State};

handle_call(Msg, _From, State) ->
    io:format("Received not recogniseble message: ~p~n", [Msg]),
    {reply, {error, badarg}, State}.



handle_info({'EXIT', Pid, Reason}, #state{children = Children, permanent = Permanent} = State)
    when is_list(Children), is_list(Permanent), is_pid(Pid), is_atom(Reason) ->
        case lists:keyfind(Pid, 2, Children) of
            {Name, Pid} ->
                case lists:member(Pid, Permanent) of
                    true ->
                        {ok, NewPid} = keylist:start_link(Name),
                        NewState = State#state{children = [{Name, NewPid} | proplists:delete(Name, Children)],  
                            permanent = [NewPid | lists:delete(Pid, Permanent)]},
                        io:format("Process ~p 'DOWN' with reason: ~p. Restared with PID ~p~n", [Pid, Reason, NewPid]);
                    false ->
                        NewState = State#state{children = proplists:delete(Name, Children), permanent = Permanent},
                        io:format("Process ~p 'DOWN' with reason: ~p~n",[Pid, Reason])
                end,
                {noreply, NewState};
            false ->
                {noreply, State}
        end.




terminate(_Reason, #state{children = Children}) ->
    lists:foreach(
                fun({Name, _Pid}) ->
                    keylist:stop(Name)
                end,
                Children),
                ok.