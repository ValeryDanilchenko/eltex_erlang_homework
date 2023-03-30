# Homework #06. Eltex.Academy Erlang #


_______________________________
В данной работе на практике познакомился с BitSintax и процесами в Erlang

№1 В функции ipv4 при обработке случая с невалидными данными я использовал erlang:error(Reason), т.к. в данной ситуации целесообразней действовать в соответствии с принципом Let it crash, ведь если в функцию попадают неверные данные, ее дальнейшее выполнение теряет всякий смысл.

№2.2 При помощи spawn создается новый процесс никак не связанный с self(), следовательно self() не изменится при создании нового процесса, и не изменится при завершении новгого процесса с ошибкой

№2.3 реализована функция ожидающая сообщений заданного формата, которая вызывает  erlang:error(Reason) при нарушении формата, или вызывает функцию ipv4 при передачи правильного сообщения
________________________________


## Task 1 ##
    Eshell V12.2.1  (abort with ^G)
    1> c("protocol.erl").
    {ok,protocol}
    2> DataWrongFormat = <<4:4, 6:4, 0:8, 0:3>>.
    <<70,0,0:3>>
    3> DataWrongVer = <<6:4, 6:4, 0:8, 232:16, 0:16, 0:3, 0:13, 0:8, 0:8, 0:16, 0:32, 0:32, 0:32, "hello" >>.
    <<102,0,0,232,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,104,
      101,108,108,111>>
    4> Data1 = <<4:4, 6:4, 0:8, 232:16, 0:16, 0:3, 0:13, 0:8, 0:8, 0:16, 0:32, 0:32, 0:32, "hello" >>.
    <<70,0,0,232,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,104,
      101,108,108,111>>
    5> Data2 = << 4:4, 6:4, 0:8, 312:16, 0:16, 0:3, 0:13, 0:8, 0:8, 0:16, 0:32, 0:32, 0:32, "status code 200" >>.
    <<70,0,1,56,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,115,
      116,97,116,117,...>>
    
    
    6> protocol:ipv4(DataWrongFormat).   
    Invalid data <<70,0,0:3>> 
    ** exception error: no match of right hand side value <<70,0,0:3>>
         in function  protocol:ipv4/1 (protocol.erl, line 27)
    
    7> protocol:ipv4(DataWrongVer).     
    Invalid data <<102,0,0,232,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,104,101,108,
                   108,111>>
    ** exception error: no match of right hand side value
                        <<102,0,0,232,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 
                          0,0,104,101,108,108,111>>
         in function  protocol:ipv4/1 (protocol.erl, line 27)
    
    8> protocol:ipv4(Data1).         
    Received data <<"hello">>
    {ipv4,4,6,0,232,0,0,0,0,0,0,0,0,<<0,0,0,0>>,<<"hello">>}
    
    9> protocol:ipv4(Data2).  
    Received data <<"status code 200">>
    {ipv4,4,6,0,312,0,0,0,0,0,0,0,0,
          <<0,0,0,0>>,
          <<"status code 200">>}

## Task 2 ##

### Task 2.1 ###
    10> self().
    <0.94.0>
    11> spawn(protocol, ipv4, [Data1]).
    Received data <<"hello">>
    <0.99.0>
    12>

### Task 2.2 ###
    12> self().
    <0.94.0>
    
    13> spawn(protocol, ipv4, [DataWrongFormat]).
    Invalid data <<70,0,0:3>>
    <0.102.0>    
    14> =ERROR REPORT==== 22-Mar-2023::19:07:51.378679 ===
    Error in process <0.102.0> with exit value:
    {{badmatch,<<70,0,0:3>>},
     [{protocol,ipv4,1,[{file,"protocol.erl"},{line,27}]}]}

    14> self().
    <0.94.0>

    15> spanw(fun() -> protocol:ipv4(Data2) end).
    ** exception error: undefined shell command spanw/1
    16> spawn(fun() -> protocol:ipv4(Data2) end).
    Received data <<"status code 200">>
    <0.107.0>


### Task 2.3 ###

    17> ListenerPid = spawn(protocol, ipv4_listener, []).
    <0.110.0>

    18> self().
    <0.105.0>

    19> ListenerPid ! {ipv4, self(), Data2}.
    Received data <<"status code 200">> 
    {ipv4,<0.105.0>,
          <<70,0,1,56,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,115,
            116,...>>}

    20> flush().
    Shell got {ipv4,4,6,0,312,0,0,0,0,0,0,0,0,<<0,0,0,0>>,<<"status code 200">>}
    ok

    21> f(ListenerPid).
    ok
    22> ListenerPid = spawn(fun() -> protocol:ipv4_listener() end).
    <0.145.0>

    23> Msg = {ipv4, self(), DataWrongFormat}.
    {ipv4,<0.141.0>,<<70,0,0:3>>}
    24> erlang:send(ListenerPid, Msg).
    Invalid data <<70,0,0:3>> 
    {ipv4,<0.141.0>,<<70,0,0:3>>}

    25> =ERROR REPORT==== 22-Mar-2023::20:25:52.174476 ===
    Error in process <0.145.0> with exit value:
    {{badmatch,<<70,0,0:3>>},
     [{protocol,ipv4,1,[{file,"protocol.erl"},{line,27}]},
      {protocol,ipv4_listener,0,[{file,"protocol.erl"},{line,33}]}]}

    25> flush().
    ok
    
    26> ListenerPid ! {{ipv4, 1}, "Wrong args"}.
    Invalid message received: {{ipv4,1},"Wrong args"}
    {{ipv4,1},"Wrong args"}
    
    27> =ERROR REPORT==== 22-Mar-2023::20:49:49.260320 ===
    Error in process <0.152.0> with exit value:
    {badarg,[{protocol,ipv4_listener,0,[{file,"protocol.erl"},{line,36}]}]}    






