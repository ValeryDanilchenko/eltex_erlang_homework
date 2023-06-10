# Homework #16. Eltex.Academy Erlang #

_______________________________
В ходе данной работы добавил к keylist супервизоров.
Решил поэксперементировать с выбором стратегии для main_sup, в коде реализована стратегия one_for_one, в контексте данной работы не самая подходящая стратегия, для корректной работы требуются костыли.  Наиболее логично подходящая для данной ситуации стратегия -  one_for_all, так как keylist_sup и  keylist_mgr не безсмысленны друг без друга. Так же для данного супервизора поработать с auto_shutdown

Для keylist_sup выбрал стратегию one_for_one, так как все keylist процессы не связаны непосредственно между собой. Хотел реализовать стратегию simple_one_for_one, но в таком случае мы не можем динамически выбирать restart для child процесса


Чтобы keylist_mgr мог корректно следить за keylist, при создаании процесса ставлю мониторы и обрабатываю {'DOWN', _Ref, process, Pid, Reason}.

Вопрос:
В handle_info в keylist_mgr обрабатываю случай, когда keylist процесс падает и перезапускается, нам необходимо добавить в #state.children новый пид процесса, но мы обрабатываем {'DOWN', _Ref, process, Pid, Reason} быстрее чем процесс перезапустися. Я захардкодил это с помощью timer:sleep(). Но как сделать, чтобы сообщение о там что keylist процесс упал, было гарантированно обработано после его перезапуска?
______________

## Task ##
    1> main_sup:start_link().
    main_sup: Init callback was called
    keylist_sup: Init callback was called
    keylist_mgr: Init callback was called
    {ok,<0.82.0>}
    2>
    2>
    2> keylist_mgr:start_child(#{name => keylist1, restart => temporary}).
    keylist1: Init callback was called
    {ok,<0.86.0>}
    3> keylist_mgr:start_child(#{name => keylist1, restart => permanent}).
    keylist_mgr: Process keylist1 is alredy started
    {error,already_started}
    4> keylist_mgr:start_child(#{name => keylist2, restart => permanent}).
    keylist2: Init callback was called
    keylist1: Added new process keylist2 with pid <0.89.0>
    {ok,<0.89.0>}
    5> keylist_mgr:start_child(#{name => keylist3, restart => permanent}).
    keylist3: Init callback was called
    keylist2: Added new process keylist3 with pid <0.91.0>
    keylist1: Added new process keylist3 with pid <0.91.0>
    {ok,<0.91.0>}
    6> keylist_mgr:start_child(#{name => keylist4, restart => transient}).
    keylist4: Init callback was called
    keylist3: Added new process keylist4 with pid <0.93.0>
    keylist2: Added new process keylist4 with pid <0.93.0>
    keylist1: Added new process keylist4 with pid <0.93.0>
    {ok,<0.93.0>}
    7>
    7>
    7>
    7>
    7>
    7> keylist_mgr:get_names().
    [keylist1,keylist2,keylist3,keylist4]
    8>
    8>
    8> keylist:add(keylist1, key1, "value1", "comment1").
    {ok,{keylist_element,key1,"value1","comment1",keylist1}}
    9> keylist:add(keylist1, key2, "value1", "comment1").
    {ok,{keylist_element,key2,"value1","comment1",keylist1}}
    10> keylist:add(keylist2, key3, "value1", "comment1").
    {ok,{keylist_element,key3,"value1","comment1",keylist2}}
    11> keylist:add(keylist3, key4, "value1", "comment1").
    {ok,{keylist_element,key4,"value1","comment1",keylist3}}
    12> keylist:add(keylist3, key5, "v1", "c1").          
    {ok,{keylist_element,key5,"v1","c1",keylist3}}
    13> keylist:add(keylist4, key6, bob, 11).   
    {ok,{keylist_element,key6,bob,11,keylist4}}
    14>
    14>
    14> keylist:match(keylist1, '$1').
    {ok,[[{keylist_element,key6,bob,11,keylist4}],
        [{keylist_element,key5,"v1","c1",keylist3}],
        [{keylist_element,key4,"value1","comment1",keylist3}],
        [{keylist_element,key3,"value1","comment1",keylist2}],
        [{keylist_element,key2,"value1","comment1",keylist1}],
        [{keylist_element,key1,"value1","comment1",keylist1}]]}
    15>
    15>
    15>
    15> keylist:find(keylist4, key1).        
    {ok,{keylist_element,key1,"value1","comment1",keylist1}}
    16> keylist:take(keylist4, key1).
    {ok,{keylist_element,key1,"value1","comment1",keylist1}}
    17> keylist:match(keylist1, '$1').
    {ok,[[{keylist_element,key6,bob,11,keylist4}],
        [{keylist_element,key5,"v1","c1",keylist3}],
        [{keylist_element,key4,"value1","comment1",keylist3}],
        [{keylist_element,key3,"value1","comment1",keylist2}],
        [{keylist_element,key2,"value1","comment1",keylist1}]]}
    18>
    18>
    18>
    18> keylist:delete(keylist4, key2).
    ok
    19> keylist:match(keylist1, '$1'). 
    {ok,[[{keylist_element,key6,bob,11,keylist4}],
        [{keylist_element,key5,"v1","c1",keylist3}],
        [{keylist_element,key4,"value1","comment1",keylist3}],
        [{keylist_element,key3,"value1","comment1",keylist2}]]}
    20>
    20>
    20>
    20> keylist_mgr:get_names().
    [keylist1,keylist2,keylist3,keylist4]
    21>
    21> keylist_mgr:get_state().       
    {state,[{keylist4,<0.93.0>},
            {keylist3,<0.91.0>},
            {keylist2,<0.89.0>},
            {keylist1,<0.86.0>}],
        [<0.93.0>,<0.91.0>,<0.89.0>]}
    22>
    22>
    22> exit(whereis(keylist1), kill). 
    keylist_mgr: Process <0.86.0> 'DOWN' with reason: killed
    =SUPERVISOR REPORT==== 23-Apr-2023::22:48:06.514045 ===
        supervisor: {local,keylist_sup}
        errorContext: child_terminated
        reason: killed
        offender: [{pid,<0.86.0>},
                {id,keylist1},
                {mfargs,{keylist,start_link,undefined}},
                {restart_type,temporary},
                {significant,false},
                {shutdown,2000},
                {child_type,worker}]

    true
    23>
    23> exit(whereis(keylist2), kill). 
    keylist2: Init callback was called
    =SUPERVISOR REPORT==== 23-Apr-2023::22:48:15.588513 ===
        supervisor: {local,keylist_sup}
        errorContext: child_terminated
        reason: killed
        offender: [{pid,<0.89.0>},
                {id,keylist2},
                {mfargs,{keylist,start_link,[keylist2]}},
                {restart_type,permanent},
                {significant,false},
                {shutdown,2000},
                {child_type,worker}]

    true
    24>
    keylist_mgr: Process <0.89.0> 'DOWN' with reason: killed. Restared with PID <0.111.0>
    24>
    24>
    24> keylist_mgr:get_state().       
    {state,[{keylist2,<0.111.0>},
            {keylist4,<0.93.0>},
            {keylist3,<0.91.0>}],
        [<0.111.0>,<0.93.0>,<0.91.0>]}
    25>
    25>
    25> keylist_mgr:stop_child(keylist4).
    {ok,{state,[{keylist2,<0.111.0>},{keylist3,<0.91.0>}],
            [<0.111.0>,<0.91.0>]}}
    26>
    26>
    26>
    26> whereis(main_sup).
    <0.82.0>
    27> main_sup:stop_child(keylist_sup).
    ok
    keylist_mgr: Process <0.91.0> 'DOWN' with reason: shutdown. Restared with PID undefined
    keylist_mgr: Process keylist_sup 'DOWN' with reason: shutdown
    28>
    28>
    28> whereis(main_sup).
    <0.82.0>
    29>
    29>
    29> keylist_mgr:stop().
    ** exception exit: shutdown
    30> whereis(main_sup). 
    undefined
    31> whereis(keylist_mgr).
    undefined
    32>