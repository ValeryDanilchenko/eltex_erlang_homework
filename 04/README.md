# Homework #04. Eltex.Academy Erlang #



## Task 1 ##


    Eshell V12.2.1  (abort with ^G)
    1> rr("converter.hrl").
    [conv_info]
    2> c("converter.erl").
    {ok,converter}
    
    3> converter:rec_to_rub(#conv_info{type = usd, amount = 100, commission = 0.01}).
    {ok,7549.0}
    
    4> converter:rec_to_rub(#conv_info{type = peso, amount = 12, commission = 0.02}).
    {ok,35.76}
    
    5> converter:rec_to_rub(#conv_info{type = yene, amount = 30, commission = 0.02}).
    Error, invalid arg {conv_info,yene,30,0.02}
    {error,badarg}
    
    6> converter:rec_to_rub(#conv_info{type = euro, amount = -15, commission = 0.02}).
    Error, invalid arg {conv_info,euro,-15,0.02}
    {error,badarg}


## Task 2 ##

    9> c("converter.erl"). 
    {ok,converter}  
    
    10> converter: map_to_rub(#{type => usd, amount => 100, commission => 0.01}).
    {ok,7549.0}
    
    11> converter: map_to_rub(#{type => peso, amount => 12, commission => 0.02}).
    {ok,35.76}
    
    12> converter: map_to_rub(#{type => yene, amount => 30, commission => 0.02}).
    Error, invalid arg #{amount => 30,commission => 0.02,type => yene}
    {error,badarg}
    
    13> converter: map_to_rub(#{type => euro, amount => -15, commission => 0.02}).
    Error, invalid arg #{amount => -15,commission => 0.02,type => euro}
    {error,badarg}


## Task 3 ##

### Task 3.1 ###

    14> c("recursion.erl"). 
    {ok,recursion}      
    
    15> X = 5.
    5
    
    16> recursion:tail_fac(X).
    120
    
    17> recursion:tail_fac(0).
    1



### Task 3.2 ###
    18> f(X).
    ok
    19> X = [12, 4, 7, 1].
    [12,4,7,1]
    20> recursion:duplicate(X).
    [12,12,4,4,7,7,1,1]
    21> recursion:duplicate([]).
    []
    22> recursion:tail_duplicate(X).
    [12,12,4,4,7,7,1,1]
    23> recursion:tail_duplicate([]).
    []


## Task 4 ##

    25> Fac = fun recursion:tail_fac/1.
    fun recursion:tail_fac/1
    26> Duplicate = fun recursion:tail_duplicate/1.    
    fun recursion:tail_duplicate/1

    27> Fac(6).
    720
    
    28> Duplicate([1, 5, 17]).
    [1,1,5,5,17,17]


## Task 5 ##
    Multiply = fun(X,Y) -> X*Y end.
    #Fun<erl_eval.43.65746770>
    30> Multiply(9, 5).
    45
    
    38> ToRub = fun({usd, Amount}) when is_integer(Amount), Amount > 0->{ok, Amount * 75.5};
    ({euro, Amount}) when is_integer(Amount), Amount > 0->{ok, Amount * 80};
    ({lari, Amount}) when is_integer(Amount), Amount > 0->{ok, Amount * 29};
    ({peso, Amount}) when is_integer(Amount), Amount > 0->{ok, Amount * 3};
    ({krone, Amount}) when is_integer(Amount), Amount > 0->{ok, Amount * 10};
    (Error) -> io:format("Error, invalid arg ~p~n",[Error]),{error, badarg} end.
    #Fun<erl_eval.44.65746770>
    
    39> ToRub({usd, 100}). 
    {ok,7550.0}
    
    40> ToRub({peso, 12}).
    {ok,36}
    
    41> ToRub({yene, 30}).
    Error, invalid arg {yene,30}
    {error,badarg}
    
    42> ToRub({euro, -15}).
    Error, invalid arg {euro,-15}
    {error,badarg}       







