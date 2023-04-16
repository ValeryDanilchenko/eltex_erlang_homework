# Homework #14. Eltex.Academy Erlang #

_______________________________

______________
    Eshell V12.2.1  (abort with ^G)
    1> c(keylist).
    {ok,keylist}
    2> c(keylist_mgr).
    {ok,keylist_mgr}
    
    3> keylist_mgr:start().
    {ok,{<0.94.0>,#Ref<0.369690005.2862350337.106932>}}
    4> keylist_mgr:start_child(#{name => keylist1, restart => temporary}).
    {ok,<0.96.0>}
    5> keylist_mgr:start_child(#{name => keylist2, restart => temporary}).
    Msg received by <0.96.0>: Aded new process keylist2 with pid <0.98.0>
    {ok,<0.98.0>}
    6> keylist_mgr:start_child(#{name => keylist3, restart => temporary}).
    Msg received by <0.98.0>: Aded new process keylist3 with pid <0.100.0>
    Msg received by <0.96.0>: Aded new process keylist3 with pid <0.100.0>
    {ok,<0.100.0>}

    7> keylist:add(keylist1, key1, "value1", "comment1").
    {ok,{keylist_element,key1,"value1","comment1",<0.96.0>}}
    8> keylist:add(keylist1, key2, "value1", "comment1").
    {ok,{keylist_element,key2,"value1","comment1",<0.96.0>}}
    9> keylist:add(keylist1, key3, "value1", "comment1").
    {ok,{keylist_element,key3,"value1","comment1",<0.96.0>}}
    10>
    10>
    10> keylist:add(keylist2, key3, 3, "comment3").       
    {ok,{keylist_element,key3,3,"comment3",<0.98.0>}}
    11> keylist:add(keylist2, key4, 4, "comment4").
    {ok,{keylist_element,key4,4,"comment4",<0.98.0>}}
    12> keylist:add(keylist3, key5, 5, "comm5").   
    {ok,{keylist_element,key5,5,"comm5",<0.100.0>}}
    13> keylist:add(keylist3, key6, 6, "comm6").
    {ok,{keylist_element,key6,6,"comm6",<0.100.0>}}


    14> keylist:match(keylist1, '$1').
    {ok,[[{keylist_element,key6,6,"comm6",<0.100.0>}],
        [{keylist_element,key5,5,"comm5",<0.100.0>}],
        [{keylist_element,key4,4,"comment4",<0.98.0>}],
        [{keylist_element,key3,"value1","comment1",<0.96.0>}],
        [{keylist_element,key3,3,"comment3",<0.98.0>}],
        [{keylist_element,key2,"value1","comment1",<0.96.0>}],
        [{keylist_element,key1,"value1","comment1",<0.96.0>}]]}


    15> keylist:print_state(keylist2).
    [{keylist_element,key4,4,"comment4",<0.98.0>},
    {keylist_element,key3,3,"comment3",<0.98.0>}]

    
    19> rr("keylist_element.hrl").
    [keylist_element]

    20> keylist:match(keylist1, #keylist_element{key='$1', value="value1", comment='$2', _ = '_'}).
    {ok,[[key3,"comment1"],
        [key2,"comment1"],
        [key1,"comment1"]]}
    

    21> keylist:match_object(keylist1, #keylist_element{comment='comment1', _ = '_'}).                    
    {ok,[]}

    22> keylist:match_object(keylist1, #keylist_element{key = key3, _ = '_'}).
    {ok,[#keylist_element{key = key3,value = "value1",
                        comment = "comment1",owner = <0.96.0>},
        #keylist_element{key = key3,value = 3,comment = "comment3",
                        owner = <0.98.0>}]}


    23> keylist:match_object(keylist1, #keylist_element{comment= "comment1", _ = '_'}).
    {ok,[#keylist_element{key = key3,value = "value1",
                        comment = "comment1",owner = <0.96.0>},
        #keylist_element{key = key2,value = "value1",
                        comment = "comment1",owner = <0.96.0>},
        #keylist_element{key = key1,value = "value1",
                        comment = "comment1",owner = <0.96.0>}]}
  


    25> MS = fun( #keylist_element{key = Key, value = Value, owner = Owner}) when Key == key3 -> [ Value, Owner] end.   
    #Fun<erl_eval.44.65746770>
    28> keylist:select(keylist1, MS).
    {ok,[["value1",<0.96.0>],
        [3,<0.98.0>]]}


    29> MS1 = fun( #keylist_element{key = Key, value = Value, comment = Comment, _ = '_'}) when Comment == "comment1" -> [ Key, Value] end.       
    #Fun<erl_eval.44.65746770>
    30> keylist:select(keylist1, MS1).
    {ok,[[key3,"value1"],
        [key2,"value1"],
        [key1,"value1"]]}
   