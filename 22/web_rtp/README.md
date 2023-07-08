WebRtp
=====

Предварительная версия Курсовой работы 


WEB RTP осуществляет обзовн абонентов, подключенных к виртуальной АТС

Успешно реализованны требования:
- Все абоненты хранятся в БД Mnesia
- присутствует REST API для осуществления обзвона всех абонентов или одного определенного по номеру телефона, а так же для добавления или удаления абонетов из БД, соответственно

        HTTP GET/call/abonents
        HTTP GET/call/abonent/{abonent_number}
        HTTP POST/call/abonent/{"num":abonent_number, "name":"abonent_name"}
        HTTP DELETE/call/abonent/{abonent_number}
- обзвон реализоваy среди абонентов, подключенных к виртуальной АТС ECSS10 с применением протоколов SIP и SDP,
и использованием библиотеки nk_sip
- проект разработан на языке Erlang и собран с помощью Rebar3, в проекте так же содержатся файлы для работы с RTP на языке C применением библиотеки oRTP

Будет реализовано в послед. версиях:
- реализация Docker контейнера для проекта
- корректная передача голосовых пакетов в клиент Zoiper5
- коррекция схемы обзовна всех абонентов из бд 
- коррекция sip INVITE запросов на удаленный клиент


Вопросы
====
1. ### Как правильно передавать голосовые пакеты в Zoiper 5?
    Получилось успешно скомпилировать rtpsend.c, и получить доступ к voice_client? так же получилось переконвертировать файлы.
    Из метаданных диалога(invite_remote_sdp) получилось достать порт(меняется для каждого нового диалога) и удаленный IP:

            Port: 12322
            Ip: "10.0.10.11"

            invite_remote_sdp:
            {sdp,<<"0">>,<<"-">>,3896793808,3896793808,
                  {<<"IN">>,<<"IP4">>,<<"10.0.10.11">>},
                  <<"ECSS-10">>,undefined,undefined,undefined,undefined,
                  undefined,[],
                  [{0,0,[]}],
                  undefined,undefined,[],
                  [{sdp_m,<<"audio">>,12322,1,<<"RTP/AVP">>,
                          [<<"0">>],
                          undefined,
                          {<<"IN">>,<<"IP4">>,<<"10.0.10.11">>},
                          [],undefined,
                          [{<<"rtpmap">>,[<<"0">>,<<"PCMU/8000/1">>]},
                           {<<"inactive">>,[]}]}]}

    После ввода команды возвращается результат, судя по которому можно сказать что передача пакетов прошла успешно, но в Zoiper ничего не слышно:

            Result "ffmpeg version 4.4.2-0ubuntu0.22.04.1 Copyright (c) 2000-2021 the FFmpeg developers\n  built with gcc 11 (Ubuntu 11.2.0-19ubuntu1)\n  configuration: --prefix=/usr --extra-version=0ubuntu0.22.04.1 --toolchain=hardened --libdir=/usr/lib/x86_64-linux-gnu --incdir=/usr/include/x86_64-linux-gnu --arch=amd64 --enable-gpl --disable-stripping --enable-gnutls --enable-ladspa --enable-libaom --enable-libass --enable-libbluray --enable-libbs2b --enable-libcaca --enable-libcdio --enable-libcodec2 --enable-libdav1d --enable-libflite --enable-libfontconfig --enable-libfreetype --enable-libfribidi --enable-libgme --enable-libgsm --enable-libjack --enable-libmp3lame --enable-libmysofa --enable-libopenjpeg --enable-libopenmpt --enable-libopus --enable-libpulse --enable-librabbitmq --enable-librubberband --enable-libshine --enable-libsnappy --enable-libsoxr --enable-libspeex --enable-libsrt --enable-libssh --enable-libtheora --enable-libtwolame --enable-libvidstab --enable-libvorbis --enable-libvpx --enable-libwebp --enable-libx265 --enable-libxml2 --enable-libxvid --enable-libzimg --enable-libzmq --enable-libzvbi --enable-lv2 --enable-omx --enable-openal --enable-opencl --enable-opengl --enable-sdl2 --enable-pocketsphinx --enable-librsvg --enable-libmfx --enable-libdc1394 --enable-libdrm --enable-libiec61883 --enable-chromaprint --enable-frei0r --enable-libx264 --enable-shared\n  libavutil      56. 70.100 / 56. 70.100\n  libavcodec     58.134.100 / 58.134.100\n  libavformat    58. 76.100 / 58. 76.100\n  libavdevice    58. 13.100 / 58. 13.100\n  libavfilter     7.110.100 /  7.110.100\n  libswscale      5.  9.100 /  5.  9.100\n  libswresample   3.  9.100 /  3.  9.100\n  libpostproc    55.  9.100 / 55.  9.100\nGuessed Channel Layout for Input Stream #0.0 : mono\nInput #0, wav, from 'priv/voice/generate.wav':\n  Duration: 00:00:01.16, bitrate: 768 kb/s\n  Stream #0:0: Audio: pcm_s16le ([1][0][0][0] / 0x0001), 48000 Hz, mono, s16, 768 kb/s\nStream mapping:\n  Stream #0:0 -> #0:0 (pcm_s16le (native) -> pcm_mulaw (native))\nPress [q] to stop, [?] for help\nOutput #0, wav, to 'priv/voice/output.wav':\n  Metadata:\n    ISFT            : Lavf58.76.100\n  Stream #0:0: Audio: pcm_mulaw ([7][0][0][0] / 0x0007), 8000 Hz, mono, s16, 64 kb/s\n    Metadata:\n      encoder         : Lavc58.134.100 pcm_mulaw\nsize=       0kB time=00:00:00.00 bitrate=N/A speed=   0x    \rsize=       9kB time=00:00:01.15 bitrate=  64.7kbits/s speed= 143x    \nvideo:0kB audio:9kB subtitle:0kB other streams:0kB global headers:0kB muxing overhead: 0.995671%\n"
2. ### Правильно ли реализованат схема взаимодействия абонентов в процессе обзвона
    На данный момент схема обзвона у меня реализованна в следующейм порядке:
    
    Для того чтобы реализовать обзвон всех абонентов необходимо сделать nksip:start_link() для каждого из абонентов зарегестрированных на ECSS10 (web_rtp_nksip_sup.erl):

        start_link() ->
            ChildsSpec = [
                nksip:get_sup_spec(test_ip_102, #{
                    sip_from => "sip:102@test.domain",
                    plugins => [nksip_uac_auto_auth, nksip_100rel],
                    sip_listen => "<sip:all:5060;transport=udp>"
                }),
                nksip:get_sup_spec(test_ip_104, #{
                    sip_from => "sip:104@test.domain",
                    plugins => [nksip_uac_auto_auth, nksip_100rel],
                    sip_listen => "<sip:all:5070;transport=udp>"
                }),
                nksip:get_sup_spec(test_ip_105, #{
                    sip_from => "sip:105@test.domain",
                    plugins => [nksip_uac_auto_auth],
                    sip_listen => "<sip:all:5080;transport=udp>"
                })
            ],
            supervisor:start_link({local, ?MODULE}, ?MODULE, {{one_for_one, 10, 60}, ChildsSpec}).


        %% @private
        init(ChildSpecs) ->
            {ok, ChildSpecs}.

Далее существующих абонентов необходимо зарешестрировать с помощью SIP REGISTER. Я реализовал регистрацию в файле web_rtp_db.erl, то есть при запуске приложения с существующей БД, происходит регистрация всех записанных в ней пользователей:

    handle_cast({register_all},State) ->
        Fun = 
            fun() ->
                mnesia:select(abonent, [{'_', [], ['$_']}])
            end,
        {atomic, Abonents} = mnesia:transaction(Fun),
        lists:map(fun({_Table, Num, _Name}) ->
            SrvId = list_to_atom("test_ip_" ++ integer_to_list(Num)),
            nksip_uac:register(SrvId, "sip:10.0.20.11", [{sip_pass, "1234"}])
        end, Abonents),
        {noreply, State};

так же пользователи регестрируются при обработке запроса на добавление нового пользователя в БД:

    handle_cast({insert, Num, Name},  State) ->
        Rec = #abonent{num = Num, name = Name},
        Fun = 
            fun() ->
                case mnesia:read(abonent, Num) of
                    [] ->
                        mnesia:write(Rec);
                    [_] ->
                        {error, already_exists}
                end
            end,
        Result = mnesia:transaction(Fun),
        io:format("Record was insert with code: ~p~n", [Result]),

        SrvId = list_to_atom("test_ip_" ++ Num),
        nksip_uac:register(SrvId, "sip:10.0.20.11", [{sip_pass, "1234"}]),
        {noreply, State};

далее в ходе выполнения GET запроса, для каждого абонента вызывается функция call_abonent(Number), где отправляется INVITE запрос:

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

Подскажите, как правильнее реализовать отправку INVITE на 102, 104-105, если мы не можем вручную принять вызов со стороный удаленного сервера, и нам возвращается либо {error, timeout} либо {ok, 480, _},
или как то возможно настроить автоответчик на этих адресах?

подойдет ли такая схема обзвона в целом, если её немного оптимизировать, например убрав лишние REGISTER запросы?



