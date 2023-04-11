# Homework #09. Eltex.Academy Erlang #


_______________________________
В ходе выполнения задания на языке Erlang, мы успешно реализовали модуль keylist_mgr, который управляет процессами keylist.

______________


## Task 1 ##
Создание процесса-менеджера и рабочих процессов с помощью API функций 

    3> keylist_mgr: start().
    {ok,<0.92.0>,#Ref<0.2183591503.3877371905.228914>}

    4> keylist_mgr: start_child(keylist1).
    {<0.80.0>,start_child,keylist1}
    5> keylist_mgr: start_child(keylist2).
    {<0.80.0>,start_child,keylist2}

---

Отправка сообщений в рабочй процесс с помощью API для модуля keylist

    6> keylist:add(keylist1, bob, 23, "male").
    {<0.80.0>,add,bob,23,"male"}
    7> keylist:add(keylist1, kate, 20, "female").
    {<0.80.0>,add,kate,20,"female"}
    8> keylist:add(keylist1, jack, 40, "male").  
    {<0.80.0>,add,jack,40,"male"}

    9> flush().
    Shell got {ok,<0.94.0>}
    Shell got {ok,<0.96.0>}
    Shell got {ok,1}
    Shell got {ok,2}
    Shell got {ok,3}
    ok

    10> keylist:find(keylist1, jack).            
    {<0.80.0>,find,jack}
    11> keylist:take(keylist1, jack).
    {<0.80.0>,take,jack}
    12> keylist:is_member(keylist1, jack).
    {<0.80.0>,is_member,jack}

    13> flush().
    Shell got {{ok,40,"male"},4}
    Shell got {{ok,40,"male"},5}
    Shell got {false,6}
    ok
    14> keylist:delete(keylist1, kate).    
    {<0.80.0>,delete,kate}
    15> flush().
    Shell got {ok,7}
    ok
    16> keylist:delete(keylist1, jack).
    {<0.80.0>,delete,jack}
    17> flush().
    Shell got {ok,8}
    ok
    18> keylist:find(keylist1, jack).  
    {<0.80.0>,find,jack}
    19> flush().
    Shell got {not_found,9}
    ok
    20> keylist:find(keylist1, kate).
    {<0.80.0>,find,kate}
    21> keylist:find(keylist1, bob). 
    {<0.80.0>,find,bob}
    22> flush().
    Shell got {not_found,10}
    Shell got {{ok,23,"male"},11}
    ok
    23>




    Eshell V12.2.1  (abort with ^G)
    1> c(keylist_mgr).
    {ok,keylist_mgr}
    2> keylsit_mgr:start().
    ** exception error: undefined function keylsit_mgr:start/0
    3> keylist_mgr:start().
    {ok,<0.89.0>,#Ref<0.93793695.3874750465.164959>}
    4> keylist_mgr:start_child(keylist1).
    {<0.87.0>,start_child,keylist1}
    5> keylist_mgr:start_child(keylist2).
    {<0.87.0>,start_child,keylist2}
    6> keylist_mgr:start_child(keylist3).
    {<0.87.0>,start_child,keylist3}
    7> keylist_mgr:stop_child(keylist3). 
    Process <0.95.0> undefined
    {<0.87.0>,stop_child,keylist3}
    8> keylist_mgr:get_names().         
    {<0.87.0>,get_names}
    9> flush().
    Shell got {ok,<0.92.0>}
    Shell got {ok,<0.93.0>}
    Shell got {ok,<0.95.0>}
    Shell got {ok,{state,[{keylist2,<0.93.0>},{keylist1,<0.92.0>}]}}
    Shell got {ok,[keylist2,keylist1]}
    ok
    10> keylist_mgr:stop().     
    {stop}
    11> flush().
    ok
    12> whereis(keylist_mgr).
    <0.89.0>
    13> keylist_mgr ! stop().
    ** exception error: undefined shell command stop/0
    14> whereis(keylist1).   
    <0.92.0>
    15> exit(whereis(keylist1), normal).
    true
    16> whereis(keylist1).
    <0.92.0>
    17> exit(whereis(keylist1), kill).  
    Process <0.92.0> 'DOWN' with reason: killed
    true
    18> whereis(keylist1).
    undefined
    19> whereis(keylist2).
    <0.93.0>
    20> exit(whereis(keylist_mgr), normal).
    Process <0.103.0> undefined
    true
    21> whereis(keylist_mgr).
    <0.89.0>
    22> exit(whereis(keylist_mgr), kill).  
    true
    23> whereis(keylist_mgr).
    undefined
    24> flush().
    ok
    25> keylist_mgr:start().
    {ok,<0.116.0>,#Ref<0.93793695.3874750465.165070>}
    26> keylist_mgr:start_child(keylist1).
    {<0.103.0>,start_child,keylist1}
    27> keylist_mgr:start_child(keylist2).
    {<0.103.0>,start_child,keylist2}
    28> keylist_mgr:start_child(keylist3).
    {<0.103.0>,start_child,keylist3}
    29> keylist_mgr ! stop;
    29> keylist_mgr ! stop.
    * 2:13: syntax error before: '!'
    29> keylist_mgr ! stop.
    stop
    30> flush().
    Shell got {ok,<0.118.0>}
    Shell got {ok,<0.120.0>}
    Shell got {ok,<0.122.0>}
    Shell got {'DOWN',#Ref<0.93793695.3874750465.165070>,process,<0.116.0>,kill}
    ok
    31> c(keylist_mgr).
    {ok,keylist_mgr}
    32> keylist_mgr:start().
    {ok,<0.132.0>,#Ref<0.93793695.3874750465.165157>}
    33> keylist_mgr:start_child(keylist1).
    {<0.103.0>,start_child,keylist1}
    34> keylist_mgr:start_child(keylist2).
    {<0.103.0>,start_child,keylist2}
    35> keylist_mgr:start_child(keylist3).
    {<0.103.0>,start_child,keylist3}
    36> keylist_mgr:stop().  
    stop
    37> flush().
    Shell got {ok,<0.134.0>}
    Shell got {ok,<0.136.0>}
    Shell got {ok,<0.138.0>}
    Shell got {'DOWN',#Ref<0.93793695.3874750465.165157>,process,<0.132.0>,kill}
    ok
    38>



