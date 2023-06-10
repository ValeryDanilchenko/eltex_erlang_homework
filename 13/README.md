# Homework #13. Eltex.Academy Erlang #

_______________________________
Выбрал для таблицы  public, ordered_set 
public - для того, чтобы все процессы могли обращаться к таблице
ordered_set - для того, чтобы ключи были отсортированы по ключу.
______________

    2> c(keylist).
    {ok,keylist}
    3> c(keylist_mgr).
    keylist_mgr.erl:4:2: Warning: undefined callback function handle_cast/2 (behaviour 'gen_server')
    %    4| -behaviour(gen_server).
    %     |  ^

    {ok,keylist_mgr}
    4> keylist_mgr:start().
    {ok,{<0.95.0>,#Ref<0.2095796034.1837367297.17271>}}
    5> keylist_mgr:start_child(#{name => keylist1, restart => temporary}).
    {ok,<0.97.0>}
    6> keylist_mgr:start_child(#{name => keylist2, restart => temporary}).
    Msg received by <0.97.0>: Aded new process keylist2 with pid <0.99.0>
    {ok,<0.99.0>}
    7> keylist_mgr:start_child(#{name => keylist3, restart => permanent}). 
    Msg received by <0.99.0>: Aded new process keylist3 with pid <0.101.0>
    Msg received by <0.97.0>: Aded new process keylist3 with pid <0.101.0>
    {ok,<0.101.0>}
    8>
    8>
    8>
    8> keylist:add(keylist1, key1, "value1", "comment1").
    {ok,{keylist_element,key1,"value1","comment1"}}
    9> keylist:add(keylist1, key2, "value1", "comment1").
    {ok,{keylist_element,key2,"value1","comment1"}}
    10> keylist:add(keylist1, key3, "value1", "comment1").
    {ok,{keylist_element,key3,"value1","comment1"}}
    11>
    11>
    11> keylist:add(keylist2, key4, "value1", "comment1").
    {ok,{keylist_element,key4,"value1","comment1"}}
    12> keylist:add(keylist2, key5, "value1", "comment1").
    {ok,{keylist_element,key5,"value1","comment1"}}
    13> keylist:add(keylist3, key6, "value1", "comment1").
    {ok,{keylist_element,key6,"value1","comment1"}}
    14> keylist:add(keylist3, key7, "value1", "comment1").
    {ok,{keylist_element,key7,"value1","comment1"}}
    15>
    15>
    15>
    15> keylist:is_member(keylist1, key2). 
    true
    16> keylist:is_member(keylist2, key6).
    true
    17> keylist:find(keylist1, key1).     
    {ok,{keylist_element,key1,"value1","comment1"}}
    18> keylist:take(keylist1, key1).
    {ok,{keylist_element,key1,"value1","comment1"}}
    19> keylist:find(keylist1, key1).
    {false,badkey}
    20> keylist:delete(keylist1, key2).
    ok
    21> ets:tab2list(keylist_ets).
    [{keylist_element,key3,"value1","comment1"},
    {keylist_element,key4,"value1","comment1"},
    {keylist_element,key5,"value1","comment1"},
    {keylist_element,key6,"value1","comment1"},
    {keylist_element,key7,"value1","comment1"}]
    22>