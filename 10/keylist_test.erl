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

% keylist_test_() ->
% {
%     inorder,
%         [
%           fun setup/0,
%           fun test_add/0,
%           fun test_is_member/0,
%           fun test_take/0,
%           fun test_delete/0,
%           fun test_find/0,
%           fun teardown/0
%         ]
%   }.


setup() ->
  {Pid, _} = keylist:start(?TEST_KEYLIST_NAME1),
  #{pid => Pid}.

teardown(#{pid := _Pid}) ->
  keylist:stop(?TEST_KEYLIST_NAME1),
  ok.

test_add() ->
  keylist:add(?TEST_KEYLIST_NAME1, key1, "Value1", "Comment1"),
  ?assertMatch({ok, {state, [{key1, "Value1", "Comment1"}], 1}}, wait_result()).


test_is_member() ->
  keylist:is_member(?TEST_KEYLIST_NAME1, key1),
  ?assertMatch({true, {state, [{key1, "Value1", "Comment1"}], 2}}, wait_result()),
  keylist:is_member(?TEST_KEYLIST_NAME1, key2),
  ?assertMatch({false, {state, [{key1, "Value1", "Comment1"}], 3}}, wait_result()).


test_take() ->
  keylist:take(?TEST_KEYLIST_NAME1, key1),
  ?assertMatch({ok, {value, {key1, "Value1", "Comment1"}, []}, 4},wait_result()),
  keylist:take(?TEST_KEYLIST_NAME1, key1),
  ?assertMatch({ok, false, 5}, wait_result()).

test_delete() ->
  keylist:delete(?TEST_KEYLIST_NAME1, key1),
  ?assertMatch({ok, {state, [], 6}},wait_result()),
  keylist:add(?TEST_KEYLIST_NAME1, key2, "Value2", "Comment2"),
  ?assertMatch({ok, {state, [{key2, "Value2", "Comment2"}], 7}}, wait_result()),
  keylist:delete(?TEST_KEYLIST_NAME1, key2),
  ?assertMatch({ok, {state, [], 8}},wait_result()).

test_find() ->
  keylist:add(?TEST_KEYLIST_NAME1, key3, "Value3", "Comment3"),
  ?assertMatch({ok, {state, [{key3, "Value3", "Comment3"}], 9}}, wait_result()),
  keylist:find(?TEST_KEYLIST_NAME1, key1),
  ?assertMatch({false, {state, [{key3, "Value3", "Comment3"}], 10}},wait_result()),
  keylist:find(?TEST_KEYLIST_NAME1, key3),
  ?assertMatch({{key3, "Value3", "Comment3"}, {state, [{key3, "Value3", "Comment3"}], 11}},wait_result()).
  


wait_result() ->
  receive
    Msg -> Msg
  end.

