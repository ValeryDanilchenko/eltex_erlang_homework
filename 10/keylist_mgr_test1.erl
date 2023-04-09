-module(keylist_mgr_test1).
-include_lib("eunit/include/eunit.hrl").


-define(TEST_PROCESS_NAME, keylist1).
-define(TEST_PARAMETR, temporary).
-define(TEST_REASON, somereason).

keylist_mgr_test_() ->
    {
        setup, 
        fun setup/0,
        fun teardown/1,
        fun () ->
            [
                test_start_child(),
                test_get_names(),
                test_stop_child()
            ]
    end

    }.



setup() ->
    {ok, Pid, _} = keylist_mgr:start(),
    keylist_mgr:start_child(#{name => ?TEST_PROCESS_NAME, restart => ?TEST_PARAMETR}),
    #{pid => Pid}.

teardown(#{pid := _Pid}) ->
    keylist_mgr:stop(),
    receive
        {'DOWN', _Ref, process, _Pid, _Reason} ->
            ok
    end.

test_start_child() ->
    {_, _, start_child_res} = keylist_mgr:start_child(#{name => ?TEST_PROCESS_NAME, restart => ?TEST_PARAMETR}),
    ?assertMatch({error, {already_started}}, wait_result()).

test_get_names() ->
    {_, _, names} = keylist_mgr:get_names(),
    ?assertMatch({ok, [?TEST_PROCESS_NAME]}, names).

test_stop_child() ->
    keylist_mgr:stop_child(?TEST_PROCESS_NAME),
    ?assertMatch({ok, []}, wait_result()).


wait_result() ->
    receive
        Msg -> Msg
    end.