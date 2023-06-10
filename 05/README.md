# Homework #05. Eltex.Academy Erlang #


_______________________________
В ходе данной работы познакомился с работой функций all, any, map, filter. Научился использовать lists:foldrl в ходе работы с функцией get_average_age. В файле person.hrl попрактиковался в создании макросов
Разобрался с конструктором списков, аналогичны генераторам в python

В последнем задании проверил как работает обработчик ошибок try cetch
________________________________


## Task 1 ##
    Eshell V12.2.1  (abort with ^G)
    1> rr("person.hrl").
    [person]
    2> Persons = [#person{id=1, name="Bob", age=23, gender=male}, #person{id=2, name="Kate", age=20, gender=female}, #person{id=3, name="Jack", age=34, gender=male}, #person{id=4, name="Nata", age=54, gender=female}].
    [#person{id = 1,name = "Bob",age = 23,gender = male},
     #person{id = 2,name = "Kate",age = 20,gender = female},
     #person{id = 3,name = "Jack",age = 34,gender = male},
     #person{id = 4,name = "Nata",age = 54,gender = female}]
     
     
    3> persons:filter(fun(#person{age = Age}) -> Age >= 30 end, Persons).
    [#person{id = 3,name = "Jack",age = 34,gender = male},
     #person{id = 4,name = "Nata",age = 54,gender = female}]
     
    4> persons:filter(fun(#person{gender = Gender}) -> Gender =:= male end, Persons).
    [#person{id = 1,name = "Bob",age = 23,gender = male},
     #person{id = 3,name = "Jack",age = 34,gender = male}]
     
    5> persons:any(fun(#person{gender = Gender}) -> Gender =:= female end, Persons).
    true
    
    6> persons:all(fun(#person{age = Age}) -> Age >= 20 end, Persons).
    true
    
    7> persons:all(fun(#person{age = Age}) -> Age < 31 end, Persons).
    false
    
    8> UpdateJackAge = fun(#person{name = "Jack", age = Age} = Person) -> Person#person{age = Age+1} end.
    #Fun<erl_eval.44.65746770>
    
    9> persons:update(UpdateJackAge, Persons).                                       
    ** exception error: no function clause matching erl_eval:'-inside-an-interpreted-fun-'(#person{id = 1,name = "Bob",age = 23,gender = male})
         in function  erl_eval:eval_fun/6 (erl_eval.erl, line 834)
         in call from lists:map/2 (lists.erl, line 1243)
    10> f(UpdateJackAge).
    ok
    
    11> UpdateJackAge = fun(#person{name = "Jack", age = Age} = Person) -> Person#person{age = Age+1}; (Person)->Person end.
    #Fun<erl_eval.44.65746770>
    
    12> persons:update(UpdateJackAge, Persons).
    [#person{id = 1,name = "Bob",age = 23,gender = male},
     #person{id = 2,name = "Kate",age = 20,gender = female},
     #person{id = 3,name = "Jack",age = 35,gender = male},
     #person{id = 4,name = "Nata",age = 54,gender = female}]


    13> UpdateWomen = fun(#person{gender = Gender, age = Age} = Women)->
    13> Women#person{age = Age-1};
    13> (Women)->Women 
    13> end.
    #Fun<erl_eval.44.65746770>
    
    14> persons:update(UpdateWomen, Persons).
    [#person{id = 1,name = "Bob",age = 22,gender = male},
     #person{id = 2,name = "Kate",age = 19,gender = female},
     #person{id = 3,name = "Jack",age = 33,gender = male},
     #person{id = 4,name = "Nata",age = 53,gender = female}]


## Task 2 ##
    15> [X || X <- lists:seq(1, 10), X rem 3 == 0].
    [3,6,9]
    16> List = [1, "hello", 100, boo, "boo", 9].
    [1,"hello",100,boo,"boo",9]
    17> [Y * Y || Y <- List, is_integer(Y)].
    [1,10000,81]




## Task 3 ##
    26> c("exceptions.erl").
    {ok,exceptions}
    
    27> exceptions:catch_all(fun() -> 1/0 end).
    Action #Fun<erl_eval.45.65746770> failed, reason badarith
    error
    
    28> exceptions:catch_all(fun() -> throw(custom_exceptions) end).
    Action #Fun<erl_eval.45.65746770> failed, reason custom_exceptions
    throw
    
    29> exceptions:catch_all(fun() -> exit(killed) end).
    Action #Fun<erl_eval.45.65746770> failed, reason killed
    exit
    
    30> exceptions:catch_all(fun() -> erlang:error(runtime_exception) end).
    Action #Fun<erl_eval.45.65746770> failed, reason runtime_exception
    error





