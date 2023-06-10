-module(keylist_test).

-include_lib("eunit/include/eunit.hrl").

-define(TEST_KEYLIST_NAME1, keylist1).


keylist_test_() ->
  {
    setup, 
    fun setup/0,
    fun teardown/1,
    [
      fun test_add/0,
      fun test_is_member/0,
      fun test_take/0,
      fun test_delete/0,
      fun test_find/0
    ]
}.




setup() ->
  {_, {Pid, _Monitor}} = keylist:start(?TEST_KEYLIST_NAME1),
  #{pid => Pid}.

teardown(#{pid := _Pid}) ->
  ok = keylist:stop(?TEST_KEYLIST_NAME1),
  ok.

test_add() ->
  ?assertMatch({ok, {state, [{key1, "Value1", "Comment1"}], 1}},
    keylist:add(?TEST_KEYLIST_NAME1, key1, "Value1", "Comment1")).


test_is_member() ->
  ?assertMatch({true,  2}, keylist:is_member(?TEST_KEYLIST_NAME1, key1)),
  ?assertMatch({false, 3}, keylist:is_member(?TEST_KEYLIST_NAME1, key2)).


test_take() ->  
  ?assertMatch({ok, {value, {key1, "Value1", "Comment1"}, []}, 4}, 
    keylist:take(?TEST_KEYLIST_NAME1, key1)),
  ?assertMatch({false, badkey, 5}, 
    keylist:take(?TEST_KEYLIST_NAME1, key1)).

test_delete() ->
  ?assertMatch({ok, {state, [], 6}}, 
    keylist:delete(?TEST_KEYLIST_NAME1, key1)),
  ?assertMatch({ok, {state, [{key2, "Value2", "Comment2"}], 7}}, 
    keylist:add(?TEST_KEYLIST_NAME1, key2, "Value2", "Comment2")),
  ?assertMatch({ok, {state, [], 8}}, 
    keylist:delete(?TEST_KEYLIST_NAME1, key2)).

test_find() ->
  ?assertMatch({ok, {state, [{key3, "Value3", "Comment3"}], 9}},
    keylist:add(?TEST_KEYLIST_NAME1, key3, "Value3", "Comment3")),
  ?assertMatch({false, 10},
    keylist:find(?TEST_KEYLIST_NAME1, key1)),
  ?assertMatch({{key3, "Value3", "Comment3"}, 11},
    keylist:find(?TEST_KEYLIST_NAME1, key3)).
  


