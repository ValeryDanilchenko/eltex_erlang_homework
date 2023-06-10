-module(door_test).

-include_lib("eunit/include/eunit.hrl").

-define(TEST_CODE, [6, 5, 8, 1]).


keylist_test_() ->
  {
    setup, 
    fun setup/0,
    fun teardown/1,
    [
      fun test_locked/0,
      fun test_open/0,
      fun test_suspended/0
    ]
}.




setup() ->
  {_, Pid} = door:start(?TEST_CODE),
  #{pid => Pid}.

teardown(#{pid := _Pid}) ->
  door:stop(),
  ok.

test_locked() ->
  ?assertMatch({ok,next},
    door:enter(6)).


test_open() ->
  ?assertMatch([{ok,next}, {ok,next}, {ok, opened}, {error, already_opened}, ok],
    [door:enter(5), 
    door:enter(8),
    door:enter(1), 
    door:enter(1), 
    timer:sleep(4500)]).

test_suspended() ->
  ?assertMatch([ok, {ok,next}, {ok,next}, {ok,next}, {error, wrong_code},
    {ok,next}, {ok,next}, {ok,next}, {error, wrong_code},
    {ok,next}, {ok,next}, {ok,next}, {error, attempt_limit_reached}],
    [timer:sleep(1000),
    door:enter(5), door:enter(8), door:enter(1), door:enter(5), 
    door:enter(8), door:enter(1), door:enter(5), door:enter(8),
    door:enter(1), door:enter(5), door:enter(8), door:enter(1)]).

