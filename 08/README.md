# Homework #08. Eltex.Academy Erlang #


_______________________________
Место под выводы
________________________________


## Task 1 ##
    Eshell V12.2.1  (abort with ^G)
    1> c(keylist_mgr).
    {ok,keylist_mgr}
    2> c(keylist).
    {ok,keylist}
    3> self().
    <0.80.0>
    4> keylist_mgr:start().
    {ok,<0.93.0>,#Ref<0.3681859221.1228144641.9566>}
    5> keylist_mgr ! {self(), start_child, keylist1}.
    {<0.80.0>,start_child,keylist1}
    6> flush().
    Shell got {ok,<0.95.0>}
    ok
    7> keylist_mgr ! {self(), start_child, keylist2}.
    {<0.80.0>,start_child,keylist2}
    8> flush().
    Shell got {ok,<0.98.0>}
    ok
    9> keylist_mgr ! {self(), start_child, keylist3}.
    {<0.80.0>,start_child,keylist3}
    10> flush().
    Shell got {ok,<0.101.0>}
    ok

## Task  ##
    11> PidKeylist3 = whereis(keylist3).  
    <0.101.0>
    12> keylist3 ! {self(), add, dan, 30, "man"}.    
    {<0.80.0>,add,dan,30,"man"}
    13> flush().
    Shell got {ok,1}
    ok
    14> PidKeylist3 ! {self(), add, ban, 40, "man"}.  
    {<0.80.0>,add,ban,40,"man"}
    15> flush().
    Shell got {ok,2}
    ok
    16> PidKeylist3 ! {self(), {get, dan}}.   
    {<0.80.0>,{get,dan}}
    17> flush().
    ok
    18> PidKeylist3 ! {self(), {find, dan}}.
    {<0.80.0>,{find,dan}}
    19> flush().
    ok
    20> PidKeylist3 ! {self(), {take, dan}}.
    {<0.80.0>,{take,dan}}
    21> flush().
    ok
    22> self().
    <0.80.0>


## Task  ##
    23> exit(whereis(keylist_mgr), normal).    
    Process <0.80.0> exited with reason: normal
    true
    24> flush().
    ok
    25> exit(whereis(keylist_mgr), normal).    
    Process <0.80.0> exited with reason: normal
    true
    26> flush().
    ok
    27> self().
    <0.80.0>
    28> keylist_mgr ! stop.
    stop
    29> flush().
    Shell got {'DOWN',#Ref<0.3681859221.1228144641.9566>,process,<0.93.0>,normal}
    ok
    30> self().
    <0.80.0>
    31> whereis(keylist1).
    <0.95.0>
    32> whereis(keylist2).
    <0.98.0>
    33> whereis(keylist3).
    <0.101.0>








