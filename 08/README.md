# Homework #08. Eltex.Academy Erlang #


_______________________________
В ходе выполнения задания на языке Erlang, мы успешно реализовали модуль keylist_mgr, который управляет процессами keylist.

______________


## Task 2 ##
### Task 2.1 ###
    Eshell V12.2.1  (abort with ^G)
    1> keylist_mgr:start().
    {ok,<0.82.0>,#Ref<0.3604071473.4087087105.214663>}
    2> keylist_mgr ! {self(), start_child, keylist1}.
    {<0.80.0>,start_child,keylist1}
    3> keylist_mgr ! {self(), start_child, keylist2}.
    {<0.80.0>,start_child,keylist2}
    4> keylist_mgr ! {self(), start_child, keylist3}.
    {<0.80.0>,start_child,keylist3}
    5>
    5> self().
    <0.80.0>
    6> flush().
    Shell got {ok,<0.85.0>}
    Shell got {ok,<0.86.0>}
    Shell got {ok,<0.88.0>}
    ok
### Task 2.2 ###
    7> keylist3 ! {self(), add, bob, 23, "male"}. 
    {<0.80.0>,add,bob,23,"male"}
    8>
    8> keylist3 ! {self(), add, jack, 30, "male"}. 
    {<0.80.0>,add,jack,30,"male"}
    9>
    9> keylist3 ! {self(), add, kate, 20, "female"}. 
    {<0.80.0>,add,kate,20,"female"}
    10>
    10> keylist3 ! {self(), find, kate}.              
    {<0.80.0>,find,kate}
    11>
    11> keylist3 ! {self(), take, kate}. 
    {<0.80.0>,take,kate}
    12>
    12> keylist3 ! {self(), find, kate}. 
    {<0.80.0>,find,kate}
    13>
    13> flush().
    Shell got {ok,1}
    Shell got {ok,2}
    Shell got {ok,3}
    Shell got {{ok,20,"female"},4}
    Shell got {{ok,20,"female"},5}
    Shell got {not_found,6}
    ok
___
## Task 3 ##
### Task 3.1 ###
    7> exit(whereis(keylist1), somereason).
    Process <0.85.0> exited with reason: somereason
    true
    8> flush().
    ok
    9> whereis(keylist1).
    undefined
    10> self().
    <0.80.0>
 
 Менеджер в loop ожидает сообщение о там что процесс завершился. Далее проверятся, является ли завершенный процесс child. Если является - удаляем процесс из State, и выводим: "Process ~p 'DOWN' with reason: ~p~n".
 Иначе выводим "Process ~p undefined ~n"
 Мы не отправляем никаких сообщений From, следовательно во flush() ничего не придет. вместо этого мы выводим сообщение в логи
 self() не меняется т.к. включен process_flag(trap_exit, true).
 _____

### Task 3.2 ###
    10> exit(whereis(keylist_mgr), somereason).
    Process <0.80.0> exited with reason: somereason
    true
    11> flush().
    ok
    12> whereis(keylist_mgr).
    <0.82.0>

 При попытке завершить процесс с помощью exit(Pid, Reason), процесс воспринимает Reason как normal и игнорирует выполнение команды exit(), т.к. ожидает сообщения в loop.  Сигнал на завершение процесса преобразуется в сообщение формата {'EXIT', From, Reason}, т.е. процесс не завершается,а получает сам в себя сообщение и обрабатывает это сообщение.

 Завершить процесс можн лишь если использовать exit(Pid, kill)

 flush() остается пустым, self() не измезняется
_____

### Task 3.3 ###
    13> keylist_mgr ! stop.
    stop
    14> flush().
    Shell got {'DOWN',#Ref<0.2026988680.3273129987.47765>,process,<0.82.0>,kill}
    ok
    15> self().
    <0.80.0>
    16> whereis(keylist_mgr).
    undefined
    17> whereis(keylist2).   
    undefined
    18> whereis(keylist3).   
    undefined
    19>

 Чтобы завершить процесс мы используем stop -> exit(kill), инчае процессс просто проигнорирует сигнал. После выполнения stop процесс падает, передавая сообщение к self()
 Все связанные процессы тоже завершаются.
 
 self() не изменяется, т.к. он - монитор для менеджера
 flush() - {'DOWN',#Ref<0.602031755.2759852033.77272>,process,<0.82.0>,killed}
 





