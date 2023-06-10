# Homework #12. Eltex.Academy Erlang #

_______________________________
Реализовал keylist и keylist_mgr на основе gen_server, оформил к ним документацию и спеки, тесты для keylist. Проверил работу модулей с помощью Eshell и Eunit 
______________

## Task 1 ##
### Проверка модуля keylist ###
    Eshell V12.2.1  (abort with ^G)
    1> c(keylist).
    {ok,keylist}
   
    3> keylist:start(keylist1).
    {ok,{<0.92.0>,#Ref<0.4016829279.2647130113.241284>}}

    4> keylist:start_link(keylist2).
    {ok,<0.94.0>}

    5> keylist:add(keylist1, bob, 11, "comment").
    {ok,{state,[{bob,11,"comment"}],1}}
    6> keylist:add(keylist1, dod, 22, "comment").
    {ok,{state,[{dod,22,"comment"},{bob,11,"comment"}],2}}
    7> keylist:add(keylist1, dad, 33, "comment").
    {ok,{state,[{dad,33,"comment"},
                {dod,22,"comment"},
                {bob,11,"comment"}],
            3}}

    8> keylist:add(keylist1, bad, 44,  "comment").
    {ok,{state,[{bad,44,"comment"},
                {dad,33,"comment"},
                {dod,22,"comment"},
                {bob,11,"comment"}],
            4}}
    9> keylist:is_member(keylist1, bob).                
    {true,5}
    10> keylist:find(keylist1, bob).     
    {{bob,11,"comment"},6}
    11> keylist:print_state(keylist1).
    [{bad,44,"comment"},
    {dad,33,"comment"},
    {dod,22,"comment"},
    {bob,11,"comment"}]
    12> keylist:take(keylist1, bob).  
    {ok,{value,{bob,11,"comment"},
            [{bad,44,"comment"},{dad,33,"comment"},{dod,22,"comment"}]},
        7}

    13> keylist:print_state(keylist1).   
    [{bad,44,"comment"},{dad,33,"comment"},{dod,22,"comment"}]
    14> keylist:take(keylist1, bob).     
    {false,badkey,8}
    15> keylist:find(keylist1, bob).
    {false,9}
    16> keylist:delete(keylist1, bob).
    {ok,{state,[{bad,44,"comment"},
                {dad,33,"comment"},
                {dod,22,"comment"}],
            10}}

    17> keylist:delete(keylist1, dod).
    {ok,{state,[{bad,44,"comment"},{dad,33,"comment"}],11}}

    18> keylist:print_state(keylist1).
    [{bad,44,"comment"},{dad,33,"comment"}]

### Тесты для модуля keylist ###
    21> c(keylist_test).
    {ok,keylist_test}

    22> eunit:test(keylist_test).
        All 5 tests passed.
    ok
---

## Task 2 ##
### Проверка модуля keylist ###
    18> c(keylist_mgr).
    keylist_mgr.erl:4:2: Warning: undefined callback function handle_cast/2 (behaviour 'gen_server')
    %    4| -behaviour(gen_server).
    %     |  ^

    {ok,keylist_mgr}
    19> keylist_mgr:start().
    {ok,{<0.137.0>,#Ref<0.2922963125.2112618507.202941>}}
    20> keylist_mgr:start_child(#{name => keylist1, restart => temporary}).
    {ok,<0.139.0>}
    21> keylist_mgr:start_child(#{name => keylist2, restart => permanent}).
    Msg received by <0.139.0>: Aded new process keylist2 with pid <0.141.0>
    {ok,<0.141.0>}
    22> keylist_mgr:start_child(#{name => keylist2, restart => temporary}).
    Process keylist2 is alredy started
    {error,already_started}
    23> keylist_mgr:start_child(#{name => keylist3, restart => temporary}).
    {ok,<0.144.0>}
    Msg received by <0.141.0>: Aded new process keylist3 with pid <0.144.0>
    Msg received by <0.139.0>: Aded new process keylist3 with pid <0.144.0>
    24>

### Остановка keylist_mgr через stop_child и stop ###
    24> keylist_mgr:stop_child(keylist1).                                  
    {ok,{state,[{keylist3,<0.144.0>},{keylist2,<0.141.0>}],
            [<0.141.0>]}}
    25>
    25>
    25> keylist_mgr:stop().              
    ok
    26> whereis(keylist_mgr).
    undefined
    27> whereis(keylist1).   
    undefined
    28> whereis(keylist2).
    undefined
    29> whereis(keylist3).
    undefined

### Тесты для модуля keylist_mgr ###
    31> eunit:test(keylist_mgr_test).
    All 3 tests passed.
    ok

### Перезапуск keylist ###
    1> keylist_mgr:start().
    {ok,{<0.82.0>,#Ref<0.3406602343.509083650.152669>}}
    2> keylist_mgr:start_child(#{name => keylist1, restart => temporary}).
    {ok,<0.84.0>}

    3> keylist_mgr:start_child(#{name => keylist2, restart => permanent}).
    Msg received by <0.84.0>: Aded new process keylist2 with pid <0.86.0>
    {ok,<0.86.0>}

    4> exit(whereis(keylist1), normal).
    true
    5> whereis(keylist1).
    <0.84.0>
    6> exit(whereis(keylist1), kill).  
    Process <0.84.0> 'DOWN' with reason: killed
    true
    7> whereis(keylist1).
    undefined

    8> exit(whereis(keylist2), normal).
    true
    9> whereis(keylist2).
    <0.86.0>
    10> exit(whereis(keylist2), kill).  
    Process <0.86.0> 'DOWN' with reason: killed. Restared with PID <0.94.0>
    true
    11> whereis(keylist2).
    <0.94.0>

### Завершение keylist_mgr с помощью exit ###
    14> keylist_mgr:start().
    {ok,{<0.100.0>,#Ref<0.3406602343.509083650.152741>}}
    15> keylist_mgr:start_child(#{name => keylist1, restart => temporary}).
    {ok,<0.102.0>}
    16> keylist_mgr:start_child(#{name => keylist2, restart => permanent}).
    Msg received by <0.102.0>: Aded new process keylist2 with pid <0.104.0>
    {ok,<0.104.0>}
    17>
    17>
    17> whereis(keylist_mgr).
    <0.100.0>
    18> exit(whereis(keylist_mgr), normal).
    true
    19> whereis(keylist_mgr).
    undefined
    20>                      
    20>
    20>
    20>
    20> keylist_mgr:start().
    {ok,{<0.111.0>,#Ref<0.3406602343.509083650.152776>}}
    21> keylist_mgr:start_child(#{name => keylist1, restart => temporary}).
    {ok,<0.113.0>}
    22>
    22>
    22> exit(whereis(keylist_mgr), kill).  
    true
    23> whereis(keylist_mgr).
    undefined
    24>