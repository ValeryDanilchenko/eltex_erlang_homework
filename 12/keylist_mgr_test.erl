-module(keylist_mgr_test).
-include_lib("eunit/include/eunit.hrl").


-define(TEST_PROCESS_NAME, keylist1).
-define(TEST_PARAMETR, temporary).

keylist_mgr_test_() ->
    {
        setup, 
        fun setup/0,
        fun teardown/1,
        [
            fun test_start_child/0,
            fun test_get_names/0,
            fun test_stop_child/0
        ]
 
    }.


setup() ->
    {ok, {Pid, _}} = keylist_mgr:start(),
    #{pid => Pid}.

teardown(#{pid := _Pid}) ->
    keylist_mgr:stop().


test_start_child() ->
    ?assertMatch({ok, _Pid}, 
        keylist_mgr:start_child(#{name => ?TEST_PROCESS_NAME, restart => ?TEST_PARAMETR})),
    ?assertMatch({error, already_started}, 
        keylist_mgr:start_child(#{name => ?TEST_PROCESS_NAME, restart => ?TEST_PARAMETR})).

test_get_names() ->
    ?assertMatch({ok, [?TEST_PROCESS_NAME]}, keylist_mgr:get_names()).

test_stop_child() ->
    ?assertMatch({ok,{state,[],[]}}, keylist_mgr:stop_child(?TEST_PROCESS_NAME)).


