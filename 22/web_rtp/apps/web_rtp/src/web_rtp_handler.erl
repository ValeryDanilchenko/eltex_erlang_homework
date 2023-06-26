-module(web_rtp_handler).
-author("ValeryDanilchenko").

-include_lib("nkserver/include/nkserver_callback.hrl").

-export([init/2, call_abonent/1]).
 
init(Req, State) ->
    io:format("Handler was called!~nReq: ~p~nState: ~p~n", [Req, State]),
    % nksip:start_link(test_ip_set, #{sip_listen=>"sip:127.0.0.1:5060"}).
    % % % % nksip:start_link(test_ip_set, #{sip_listen=>"sip:10.0.20.11:5060"}).
    % nksip_uac:options(test_ip_set, "sip:10.0.20.11", [{sip_pass, "1234"}]).
    % nksip_uac:options(test_ip_set, "<sip:10.0.20.11;transport=tcp>", [{sip_pass, "1234"}]).
    % nksip_uac:register(test_ip_set, "sip:user@10.0.20.11:5060", [{from, "sip:101@test.domain"}, {to, "sip:102@test.domain"}, {get_meta, [all_headers]}]).
    % nksip_uac:register(test_ip_set, "<sip:10.0.20.11;transport=tcp>", [{to, "sip:102@10.0.20.11"}, {get_meta, [all_headers]}]).

    % nksip_uac:register(test_ip_set, "<sip:101:1234@10.0.20.11;transport=tcp>", [{from, "sip:101@10.0.20.11"},{sip_pass, "1234"}, {get_meta, [<<"contact">>]}]).
    % nksip_uac:register(test_ip_set, "<sip:10.0.20.11;transport=tcp>", [{from, "sip:102@10.0.20.11"},{sip_pass, "1234"}, {get_meta, [<<"contact">>]}]).  


    % nksip_uac:invite(test_ip_set, "<sip:102@10.0.20.11;transport=tcp>", [{route, "<sip:10.0.20.11;transport=tcp>"}, {get_meta, [all_headers]}]). 
    % nksip_uac:invite(test_ip_set_client1, "<sip:102:1234@10.0.20.11;transport=tcp>", [{route, "<sip:10.0.20.11;transport=tcp;lr>"}, {get_meta, [all_headers]}]). 

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
                #{
                    table => Table, 
                    num => Num, 
                    name => list_to_binary(Name),
                    msg => list_to_binary(element(2, call_abonent(integer_to_list(Num))))
                }
            end, Data),
            Response = jsone:encode(#{response => ConvertedData}),
            DeliverRes= cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, Response, Req);
        [<<"abonent">>, Number ] ->
            Data = web_rtp_db:read(binary_to_integer(Number)),
            {ok, RespMsg} = call_abonent(binary_to_list(Number)),
            ConvertedData = lists:map(fun({Table, Num, Name}) ->
                #{
                    table => Table, 
                    num => Num, 
                    name => list_to_binary(Name),
                    msg => list_to_binary(RespMsg)
                }
            end, Data),
            Response = jsone:encode(#{response => ConvertedData}),
            DeliverRes= cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, Response, Req);
        _ ->
            DeliverRes = cowboy_req:reply(404, #{}, <<"Oops! Requested page not found.">>, Req)
    end,

    io:format("Reuqest was handelled!~n"),
    {ok, DeliverRes}.

call_abonent(AbonentId) ->  
    case AbonentId of 
        "102" ->
            From_Uri = "sip:104@test.domain",
            SrvId = test_ip_104;
            % SrvId = list_to_atom("string_" ++ integer_to_list(Num)),
        _->
            From_Uri = "sip:102@test.domain",
            SrvId = test_ip_102
    end,

    io:format("Abonent ID: ~p~n SrvId: ~p~nFrom: ~p~n", [AbonentId, SrvId, From_Uri]),

    case whereis(SrvId) of
        _Pid ->
            nksip_uac:register(SrvId, "sip:10.0.20.11", [{sip_pass, "1234"}, contact, {meta, ["contact"]}]);
        undefined ->
            nksip:start_link(SrvId, #{sip_from => From_Uri,plugins => [nksip_uac_auto_auth], sip_listen => "<sip:all:5060;transport=udp>"}),
            nksip_uac:register(SrvId, "sip:10.0.20.11", [{sip_pass, "1234"}, contact, {meta, ["contact"]}])
    end,

    % nksip:start_link(test_ip_102, #{sip_from => "sip:102@test.domain",plugins => [nksip_uac_auto_auth], sip_listen => "<sip:all:5060;transport=udp>"}).
    % nksip_uac:register(test_ip_102, "sip:10.0.20.11", [{sip_pass, "1234"}, contact, {meta, ["contact"]}]).
    % {ok,200,[{dialog, DialogId}]}= nksip_uac:invite(test_ip_102, "sip:101@test.domain", [auto_2xx_ack, {sip_pass, "1234"},{route, "<sip:10.0.20.11;lr>"}, {body, nksip_sdp:new()}, {meta, [all_headers]}]).
    % nksip_dialog:get_metas([srv_id, local_uri, remote_uri, local_target, remote_target, invite_local_sdp, invite_remote_sdp], DlgId).

    % MediaList = element(18, element(2, Meta)).
    % web_rtp_handler:call_abonent(101).
    % Uri = "sip:101@test.domain",

    % nksip_uac:invite(test_ip_102, "sip:101@test.domain", [auto_2xx_ack, {sip_pass, "1234"},{route, "<sip:10.0.20.11;lr>"}, {body, nksip_sdp:new()}, get_request, {get_meta, [supported, require]}, {require, "100rel"}]).

    nksip_app:put(sync_call_time, 30000),
    nksip_config:set_config(),

    Uri = "sip:" ++ AbonentId ++ "@test.domain",
    Opts =  [
                auto_2xx_ack, 
                get_request,
                {sip_pass, "1234"},
                {route, "<sip:10.0.20.11;lr>"}, 
                {body, nksip_sdp:new()}
            ],
    case nksip_uac:invite(SrvId, Uri, Opts) of
        {ok,200,[{dialog, DialogId}]} -> 
            io:format("Dialog ID:~p~n", [DialogId]),

            {ok, Meta} = nksip_dialog:get_meta(invite_remote_sdp, DialogId),
            io:format("Request Meta:~p~n~n", [Meta]),

            [MediaList | _] = element(18, Meta),
            Port = element(3, MediaList),
            PBX_IP =  binary_to_list(element(3, element(8, MediaList))),
            io:format("Port: ~p~nIp: ~p~n~n", [Port, PBX_IP]),
            
            % MediaList = element(18, Meta),
            % PBX_IP = "172.31.171.252",
            % PBX_IP = "10.0.20.11",
            % Port = 1080,
            
            CurrentDir = "cd apps/web_rtp",
            ConvertVoice = "ffmpeg -i priv/voice/generate.wav -codec:a pcm_mulaw -ar 8000 -ac 1 priv/voice/output.wav -y",
            StartVoice = "./voice_client priv/voice/output.wav " ++ PBX_IP ++ " " ++ erlang:integer_to_list(Port),
            Cmd = CurrentDir ++ " && " ++ ConvertVoice ++ " && " ++ StartVoice,
            Res = os:cmd(Cmd),
            
            io:format("Cmd ~p~nResult ~p~n", [Cmd, Res]),
        
            nksip_uac:bye(DialogId, []),

            Response = "Dialog was started with code 200.\nDialog was finished succesfully!\n",
            io:format("Response: ~p~n", [Response]);
        {ok,480,_}->
            Response = "Dialog wasn't started.\nAbonent " ++ AbonentId ++ " is temporary unavailable\n",
            io:format("Response: ~p~n", [Response]);
        {ok,404,_} ->
            Response = "Error! Dialog wasn't started.\nAbonent " ++ AbonentId ++ " is NOT FOUND!\n",
            io:format("Response: ~p~n", [Response]);
        {ok, Code, _} -> 
            Response = "Response code " ++ Code ++ "!\nAn error ocured!\n",
            io:format("Response: ~p~n", [Response]);
        _ -> 
            Response = "Error! An unhandled error occurred during invite request!\n",
            io:format("Response: ~p~n", [Response])
    end,
    {ok, Response}.
    



%% @doc function handeling POST /abonent/ {BODY} requests
handle_post(Req) ->
    Path = binary:split(cowboy_req:path(Req), <<"/">>, [global, trim_all]),
    {ok, DataBin, _Req0} = cowboy_req:read_body(Req),
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
    {ok, DeliverRes}.

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
