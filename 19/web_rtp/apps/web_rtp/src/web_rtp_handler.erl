-module(web_rtp_handler).
-author("ValeryDanilchenko").

-export([handle/2]).
-export([init/2]).

init(Req, State) ->
    io:format("Handler was called!~nReq: ~p~nState: ~p~n", [Req, State]),

    Method = cowboy_req:method(Req),
    HasBody = cowboy_req:has_body(Req),

    case {Method, HasBody} of
        {<<"GET">>, false} ->
            handle(Req, State);
        {_, _} ->
            ok
        end,

    {ok, Req, State}.


%% @doc function starting supervisor process
handle(Req, State) ->
    Path = binary:split(cowboy_req:path(Req), <<"/">>, [global, trim_all]),
    io:format("Path: ~p~n", [Path]),

    case Path of
        [<<"call">>, <<"broadcast">>] ->
            {ok, DeliverRes, State} = broadcast_handler(Req, State);
       [<<"call">>, <<"abonent">>, AbonentNumber] ->
            {ok, DeliverRes, State} = abonent_handler(AbonentNumber, Req, State);
        _ ->
            DeliverRes = cowboy_req:reply(404, #{}, <<"Oops! Requested page not found.">>, Req)
    end,
    
    io:format("Reuqest was handelled!~n", []),
    {ok, DeliverRes, State}.

broadcast_handler(Req, State) ->
    Body = <<"This is a response for /call/broadcast">>,
    Response = jsone:encode(#{response => Body}),
    DeliverRes= cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, Response, Req),
  
    {ok, DeliverRes, State}.


abonent_handler(AbonentNumber, Req, State) ->
    Body = <<"This is a response for /call/abonent/{abonent_number}">>,
    Response = jsone:encode(#{response => Body, abonent => AbonentNumber}),
    DeliverRes = cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, Response, Req),
  
    {ok, DeliverRes, State}.