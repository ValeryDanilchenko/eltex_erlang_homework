WebRtp
=====

An OTP application realise Web API using Mnesia Database, cowboy, jsone.



Requests. POST
-----
    Request:
    POST http://localhost:8080/abonent/ 
    Body: {"num": 1000, "name": "Bob"}

    Client console:
    Reuqest was handelled!

    Server console: 
    Handler was called!
    Req: #{bindings => #{},body_length => 28,cert => undefined,has_body => true,
        headers =>
            #{<<"accept">> => <<"*/*">>,
                <<"accept-encoding">> => <<"gzip, deflate, br">>,
                <<"connection">> => <<"keep-alive">>,
                <<"content-length">> => <<"28">>,
                <<"content-type">> => <<"application/json">>,
                <<"host">> => <<"localhost:8080">>,
                <<"postman-token">> => <<"d8e2b562-4f1b-419c-b785-c3aa08935c0f">>,
                <<"user-agent">> => <<"PostmanRuntime/7.32.2">>},
        host => <<"localhost">>,host_info => undefined,method => <<"POST">>,
        path => <<"/abonent">>,path_info => undefined,
        peer => {{127,0,0,1},59604},
        pid => <0.278.0>,port => 8080,qs => <<>>,ref => http,
        scheme => <<"http">>,
        sock => {{127,0,0,1},8080},
        streamid => 1,version => 'HTTP/1.1'}
    State: []
    Path: [<<"abonent">>]
    DataBin: <<"{\"num\": 1000, \"name\": \"Bob\"}">>
    Body: #{<<"name">> => <<"Bob">>,<<"num">> => 1000}
    Record was insert with code: {atomic,ok}



Requests. GET

    Request:
    GET http://localhost:8080/abonent/<NUM>


    Client console:
    {
        "response": [
            {
                "name": "Bob",
                "num": 1000,
                "table": "abonent"
            }
        ]
    }

    Server console: 

    Handler was called!
    Req: #{bindings => #{abonent_number => <<"1000">>},
        body_length => 0,cert => undefined,has_body => false,
        headers =>
            #{<<"accept">> => <<"*/*">>,
                <<"accept-encoding">> => <<"gzip, deflate, br">>,
                <<"connection">> => <<"keep-alive">>,
                <<"host">> => <<"localhost:8080">>,
                <<"postman-token">> => <<"aabe6e7c-7b6b-452a-8ce1-28553a05c3e3">>,
                <<"user-agent">> => <<"PostmanRuntime/7.32.2">>},
        host => <<"localhost">>,host_info => undefined,method => <<"GET">>,
        path => <<"/abonent/1000">>,path_info => undefined,
        peer => {{127,0,0,1},46568},
        pid => <0.290.0>,port => 8080,qs => <<>>,ref => http,
        scheme => <<"http">>,
        sock => {{127,0,0,1},8080},
        streamid => 3,version => 'HTTP/1.1'}
    State: []
    Path: [<<"abonent">>,<<"1000">>]
    Reuqest was handelled!

    Request:
    GET http://localhost:8080/abonents

    Client console:
    {
        "response": [
            {
                "name": "Bob",
                "num": 1000,
                "table": "abonent"
            },
            {
                "name": "Jack",
                "num": 1001,
                "table": "abonent"
            },
            {
                "name": "Ivan",
                "num": 1002,
                "table": "abonent"
            }
        ]
    }

    Server console: 
    Handler was called!
    Req: #{bindings => #{},body_length => 0,cert => undefined,has_body => false,
        headers =>
            #{<<"accept">> => <<"*/*">>,
                <<"accept-encoding">> => <<"gzip, deflate, br">>,
                <<"connection">> => <<"keep-alive">>,
                <<"host">> => <<"localhost:8080">>,
                <<"postman-token">> => <<"79691fd6-05b5-42eb-b5f4-7dfef419e2ce">>,
                <<"user-agent">> => <<"PostmanRuntime/7.32.2">>},
        host => <<"localhost">>,host_info => undefined,method => <<"GET">>,
        path => <<"/abonents">>,path_info => undefined,
        peer => {{127,0,0,1},60664},
        pid => <0.303.0>,port => 8080,qs => <<>>,ref => http,
        scheme => <<"http">>,
        sock => {{127,0,0,1},8080},
        streamid => 1,version => 'HTTP/1.1'}
    State: []
    Path: [<<"abonents">>]
    Reuqest was handelled!
    


Requests. DELETE

    Request:
    DELETE http://localhost:8080/abonent/<NUM>


    Client console:
    Reuqest was handelled!

    Server console: 
    Handler was called!
    Req: #{bindings => #{abonent_number => <<"1000">>},
        body_length => 0,cert => undefined,has_body => false,
        headers =>
            #{<<"accept">> => <<"*/*">>,
                <<"accept-encoding">> => <<"gzip, deflate, br">>,
                <<"connection">> => <<"keep-alive">>,
                <<"host">> => <<"localhost:8080">>,
                <<"postman-token">> => <<"e208e91a-3d1d-4a5e-9691-63971bba35c2">>,
                <<"user-agent">> => <<"PostmanRuntime/7.32.2">>},
        host => <<"localhost">>,host_info => undefined,method => <<"DELETE">>,
        path => <<"/abonent/1000">>,path_info => undefined,
        peer => {{127,0,0,1},43714},
        pid => <0.306.0>,port => 8080,qs => <<>>,ref => http,
        scheme => <<"http">>,
        sock => {{127,0,0,1},8080},
        streamid => 1,version => 'HTTP/1.1'}
    State: []
    Path: [<<"abonent">>,<<"1000">>]
    Reuqest was handelled!
    Record was deleted with code: {atomic,ok}

Comunication with database with Shell

    1> web_rtp_db:read_all().
    [{abonent,1001,"Jack"},{abonent,1002,"Ivan"}]
    2> web_rtp_db:insert(1004, "Dan").
    Record was insert with code: {atomic,ok}
    ok
    3> web_rtp_db:read(1004).
    [{abonent,1004,"Dan"}]
    4> web_rtp_db:delete(1004). 
    Record was deleted with code: {atomic,ok}
    ok
    5> web_rtp_db:read_all().
    [{abonent,1001,"Jack"},{abonent,1002,"Ivan"}]
    6> web_rtp_db:stop().      
    Database was terminated with reason: normal
    ok
    7> web_rtp_db:read_all().
    ** exception exit: {noproc,{gen_server,call,[web_rtp_db,{read_all}]}}
        in function  gen_server:call/2 (gen_server.erl, line 239)
