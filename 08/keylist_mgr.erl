-module(keylist_mgr).
-behaviour(gen_server).

-export([start_link/0, loop/1]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-record(state, {children = []}).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

init([]) ->
    {ok, #state{}}.

handle_call({start_child, Name}, _From, #state{children = Children} = State) ->
    case proplists:lookup(Name, Children) of
        {Name, _Pid} ->
            {reply, {error, already_exists}, State};
        false ->
            {ok, Pid} = keylist:start_link(Name),
            NewChildren = [{Name, Pid} | Children],
            {reply, {ok, Pid}, State#state{children = NewChildren}}
    end;

handle_call({stop_child, Name}, _From, #state{children = Children} = State) ->
    case proplists:lookup(Name, Children) of
        {Name, Pid} ->
            keylist:stop(Pid),
            NewChildren = proplists:delete(Name, Children),
            {reply, ok, State#state{children = NewChildren}};
        false ->
            {reply, {error, not_found}, State}
    end;

handle_call(stop, _From, State) ->
    {stop, normal, ok, State};

handle_call(get_names, _From, #state{children = Children} = State) ->
    Names = [Name || {Name, _Pid} <- Children],
    {reply, Names, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info({'EXIT', Pid, Reason}, #state{children = Children} = State) ->
    io:format("Process ~p exited with reason: ~p~n", [Pid, Reason]),
    NewChildren = proplists:delete_value(Pid, Children),
    {noreply, State#state{children = NewChildren}}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

loop(#state{children = Children} = State) ->
    receive
        {From, start_child, Name} ->
            handle_call({start_child, Name}, From, State),
            loop(State);
        {From, stop_child, Name} ->
            handle_call({stop_child, Name}, From, State),
            loop(State);
        {From, get_names} ->
            handle_call(get_names, From, State),
            loop(State);
        stop ->
            handle_call(stop, self(), State)
    end.