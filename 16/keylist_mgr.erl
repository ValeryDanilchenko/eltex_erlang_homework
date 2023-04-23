-module(keylist_mgr).
-author("ValeryDanilchenko").

-behaviour(gen_server).

%% @type includes info about starting process: it`s name and is it permonentor not
%% if it is we will restrt it by the time it crash
-type(parameters() :: #{
    name => atom(),
    restart => permanent | temporary | transient
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
-export([ start/0, stop/0, stop_async/0, start_child/1, stop_child/1,  get_names/0, get_state/0]). 

%% Callback
-export([init/1, terminate/2, handle_call/3, handle_cast/2, handle_info/2]).


%%%%%%%%%% API %%%%%%%%%%

%% @doc API function for spawn linked generic server process
-spec(start() -> {ok, pid()}).
start() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).


%% @doc API function for stop process manager and stop all child processes
-spec(stop() -> ok).
stop() ->
    gen_server:stop(?MODULE).

%% @doc async API function for generic server stop_async process to exit with 'normal' reason
-spec(stop_async() -> ok).
stop_async() ->
    gen_server:cast(?MODULE, stop_async).

%% @doc sync API function initialising starting the child process
-spec(start_child(parameters()) -> 
    {ok, pid()} | {error, already_started}).
start_child(#{name := _Name , restart := _Restart} = Params) ->
    gen_server:call(?MODULE, {start_child, Params}).

%% @doc sync API function for stop the child process
-spec(stop_child(Name :: atom()) -> 
    {ok, state()} | {error, undefined}).   
stop_child(Name) ->
    gen_server:call(?MODULE, {stop_child, Name}).

%% @doc sync API function returns info about child processes
-spec(get_names() -> list(atom())).
get_names() ->
    gen_server:call(?MODULE, get_names).

%% @doc sync API function returns state
-spec(get_state() -> state()).
get_state() ->
    gen_server:call(?MODULE, get_state).

%%%%%%%%%% CALLBACK %%%%%%%%%%

init(_Args) ->
    io:format("~p: Init callback was called~n", [?MODULE]),
    erlang:monitor(process, whereis(keylist_sup)),
    ets:new(keylist_ets, [public, set, named_table, {keypos, 2}]),
    {ok, #state{}}.


handle_call({start_child, #{name := Name, restart := Restart} = Params}, _From, #state{children = Children, permanent = Permanent} = State)
    when is_list(Children), is_list(Permanent), is_atom(Name), is_atom(Restart) ->
        case proplists:is_defined(Name, Children) of
                true ->
                    io:format("~p: Process ~p is alredy started  ~n", [?MODULE, Name]),
                    {reply, {error, already_started}, State};
                false ->
                    {ok, Pid} = keylist_sup:start_child(Params),
                    erlang:monitor(process, Pid), 
                    case Restart of
                        permanent ->
                            NewState = State#state{children = [{Name, Pid} | Children], permanent = [Pid | Permanent]};
                        transient -> 
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
                Pid = erlang:whereis(Name),
                keylist_sup:stop_child(Name),
                NewState = State#state{children = proplists:delete(Name, Children),
                        permanent = lists:delete(Pid, Permanent)},
                {reply, {ok, NewState}, NewState};
            false ->
                {reply, {error, undefined}, State}
        end;
handle_call(get_state, _From, State)->
    {reply, State, State};
handle_call(get_names, _From, #state{children = Children} = State) when is_list(Children) ->
    Names = proplists:get_keys(Children),
    {reply, Names, State}.

        
handle_cast(stop_async, State) ->
    terminate(reason, State),
    {noreply, State}.
        

handle_info({'DOWN', _Ref, process, Pid, Reason}, #state{children = Children, permanent = Permanent} = State)
    when is_list(Children), is_list(Permanent), is_pid(Pid), is_atom(Reason) ->
        case erlang:whereis(keylist_sup) of
            undefined ->
                timer:sleep(1000),
                case erlang:whereis(keylist_sup) of
                    undefined ->
                        io:format("~p: Process ~p 'DOWN' with reason: ~p~n",[?MODULE, keylist_sup, Reason]);
                    SupPid ->
                        io:format("~p: Process ~p 'DOWN' with reason: ~p. Restared with PID ~p~n", [?MODULE, keylist_sup, Reason, SupPid]),
                        erlang:monitor(process, SupPid)
                end,
                    {noreply, #state{}};  
            _SupPid ->
                case lists:keyfind(Pid, 2, Children) of
                    {Name, Pid} ->
                        case lists:member(Pid, Permanent) of
                            true ->
                                timer:sleep(1000),
                                NewPid = erlang:whereis(Name),
                                NewState = State#state{children = [{Name, NewPid} | proplists:delete(Name, Children)],  
                                    permanent = [NewPid | lists:delete(Pid, Permanent)]},
                                io:format("~p: Process ~p 'DOWN' with reason: ~p. Restared with PID ~p~n", [?MODULE, Pid, Reason, NewPid]);
                            false ->
                                NewState = State#state{children = proplists:delete(Name, Children), permanent = Permanent},
                                io:format("~p: Process ~p 'DOWN' with reason: ~p~n",[?MODULE, Pid, Reason])
                        end,
                        {noreply, NewState};
                    false ->
                        {noreply, State}
                end
        end;
handle_info(Msg, State) ->
    io:format("~p: Received message: ~p~n", [?MODULE, Msg]),
    {noreply, State}.


terminate(_Reason, #state{children = Children}) ->
    lists:foreach(
                fun({Name, _Pid}) ->
                    keylist_sup:stop_child(Name)
                end,
                Children),
                ok.