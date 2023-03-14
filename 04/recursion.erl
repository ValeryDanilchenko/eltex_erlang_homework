-module(recursion).

-export([tail_fac/1, duplicate/1, tail_duplicate/1]).

tail_fac(N) when is_integer(N), N >=0 -> 
    tail_fac(N, 1);
tail_fac(Error) ->
    io:format("Error, invalid arg\nNumbers must be non-negative integers.\n\"~p\" - given.~n", [Error]),
    {error, badarg}.

tail_fac(0, Acc) -> Acc;
tail_fac(N, Acc) -> tail_fac(N-1, N * Acc).


duplicate([]) -> [];
duplicate(List) when is_list(List) ->
    [Head|Tail] = List,
    [Head, Head| duplicate(Tail)];
duplicate(Error) ->
    io:format("Error, invalid arg\nMust be list.\n\"~p\" - given.~n", [Error]),
    {error, badarg}.


tail_duplicate(List) when is_list(List)->
    tail_duplicate(List, []);
tail_duplicate(Error) ->
    io:format("Error, invalid arg\nMust be list.\n\"~p\" - given.~n", [Error]),
    {error, badarg}.

tail_duplicate([], Acc) -> lists:reverse(Acc);
tail_duplicate(List, Acc) ->
    [Head|Tail] = List,
    tail_duplicate(Tail, [Head, Head| Acc]).
