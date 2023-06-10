-module(web_rtp_handler).
-author("ValeryDanilchenko").


-export([init/2]).
 
init(Req, State) ->
    io:format("Handler was called!~nReq: ~p~nState: ~p~n", [Req, State]),

    Method = cowboy_req:method(Req),
    HasBody = cowboy_req:has_body(Req),

    case {Method, HasBody} of
        {<<"GET">>, false} ->
            handle_get(Req);
        {<<"POST">>, true} ->
            handle_post(Req);
        {<<"DELETE">>, false} ->
            handele_delete(Req);
        {_, _} ->
            ok
        end,
    {ok, Req, State}.

%% @doc function handeling GET /abonent/<NUM> and GET /abonents requests
handle_get(Req) ->
    Path = binary:split(cowboy_req:path(Req), <<"/">>, [global, trim_all]),
    io:format("Path: ~p~n", [Path]),

    case Path of
        [<<"abonents">>] ->
            Data = web_rtp_db:read_all(),
            ConvertedData = lists:map(fun({Table, Num, Name}) ->
                #{table => Table, num => Num, name => list_to_binary(Name)}
            end, Data),
            Response = jsone:encode(#{response => ConvertedData}),
            DeliverRes= cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, Response, Req);
        [<<"abonent">>, Number ] ->
            Data = web_rtp_db:read(binary_to_integer(Number)),
            ConvertedData = lists:map(fun({Table, Num, Name}) ->
                #{table => Table, num => Num, name => list_to_binary(Name)}
            end, Data),
            Response = jsone:encode(#{response => ConvertedData}),
            DeliverRes= cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, Response, Req);
        _ ->
            DeliverRes = cowboy_req:reply(404, #{}, <<"Oops! Requested page not found.">>, Req)
    end,

    io:format("Reuqest was handelled!~n"),
    {ok, DeliverRes}.


%% @doc function handeling POST /abonent/ {BODY} requests
handle_post(Req) ->
    Path = binary:split(cowboy_req:path(Req), <<"/">>, [global, trim_all]),
    {ok, DataBin, Req0} = cowboy_req:read_body(Req),
    Body = jsone:decode(DataBin),

    io:format("Path: ~p~n", [Path]),
    io:format("DataBin: ~p~n", [DataBin]),
    io:format("Body: ~p~n", [Body]),

    case Path of
        [<<"abonent">>] ->
            {ok, Num} = maps:find(<<"num">>, Body),
            {ok, Name} = maps:find(<<"name">>, Body),
            web_rtp_db:insert(Num, binary_to_list(Name)),
            DeliverRes= cowboy_req:reply(200, #{<<"content-type">> => <<"text/plain">>}, <<"Reuqest was handelled!">>, Req);
        _ ->
            DeliverRes = cowboy_req:reply(404, #{}, <<"Oops! Requested page not found.">>, Req)
    end, 
    ok.

%% @doc function handeling DELETE /abonent/<NUM> requests
handele_delete(Req) ->
    Path = binary:split(cowboy_req:path(Req), <<"/">>, [global, trim_all]),
    io:format("Path: ~p~n", [Path]),

    case Path of
        [<<"abonent">>, Number ] ->
            web_rtp_db:delete(binary_to_integer(Number)),
            DeliverRes= cowboy_req:reply(201, #{<<"content-type">> => <<"text/plain">>}, <<"Reuqest was handelled!">>, Req);
        _ ->
            DeliverRes = cowboy_req:reply(404, #{}, <<"Oops! Requested page not found.">>, Req)
    end,

    io:format("Reuqest was handelled!~n"),
    {ok, DeliverRes}.
