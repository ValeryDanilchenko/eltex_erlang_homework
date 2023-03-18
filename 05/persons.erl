-module(persons).
-include("person.hrl").
-export([filter/2, all/2, any/2, update/2, get_average_age/1]).


filter(Fun, Persons) when is_function(Fun), is_list(Persons) -> 
    lists:filter(Fun, Persons).
filter(Error) ->
    io:format("Error, invalid arg ~p~n", [Error]),
    {error, badarg}.


all(Fun, Persons) when is_function(Fun), is_list(Persons) ->
    lists:all(Fun, Persons).
all(Error) ->
    io:format("Error, invalid arg ~p~n", [Error]),
    {error, badarg}.


any(Fun, Persons) when is_function(Fun), is_list(Persons) ->
    lists:any(Fun, Persons).
any(Error) ->
    io:format("Error, invalid arg ~p~n", [Error]),
    {error, badarg}.


update(Fun, Persons) when is_function(Fun), is_list(Persons) ->
    lists:map(Fun, Persons).
update(Error) ->
    io:format("Error, invalid arg ~p~n", [Error]),
    {error, badarg}.


get_average_age([]) -> 
    thorw: division_by_zero_error ->
        io:format("Error, division by zero ~n"),
        0;
get_average_age(Persons) when is_list(Persons) ->
    Fun = fun(#person{age = Age}, {AgeAcc, CountAcc}) -> {Age + AgeAcc, CountAcc + 1} end,
    {AgeSum, PersonsCount} = lists:foldl(Fun, {0, 0}, Persons),
    AgeSum/PersonsCount.
get_average_age(Error) ->
    io:format("Error, invalid arg ~p~n", [Error]),
    {error, badarg}.



