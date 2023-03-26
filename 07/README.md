# Homework #07. Eltex.Academy Erlang #


_______________________________
В ходе выполнения заданий я изучил и применил на практике следующие аспекты работы с процессами в Erlang:

1. Создание и использование рекордов для хранения состояния процесса.
2. Реализация функции loop/1 для обработки сообщений и обновления состояния процесса.
3. Запуск процессов с помощью функций start/1 и start_link/1, регистрация процессов с именами и установка мониторов или связей между процессами.
4. Отправка сообщений процессам и обработка результатов.
5. Завершение процессов с помощью функции exit/2 и изучение влияния завершения процессов на связанные процессы.
6. Изучение флага trap_exit и его использование для перехвата сообщений 'EXIT' от завершающихся процессов, что позволяет контролировать поведение текущего процесса при завершении связанных процессов.

В результате проделанной работы я получил практическиие навыки работы с процессами в Erlang, а также понимание взаимодействия процессов, обработки ошибок и завершения процессов. 
________________________________


## Task 1 ##
    Eshell V12.2.1  (abort with ^G)
    1> c(keylist).
    {ok,keylist}
    2> rr(keylist).
    [state]
    3> Pid = spawn(keylist, loop, [#state{list = [{andy, 99, "man"}], counter = 0}]).
    <0.90.0>
    4> Pid ! {self(), add, jack, 50, "man"}. 
    {<0.80.0>,add,jack,50,"man"}
    5> flush().
    Shell got {ok,1}
    ok
    6> Pid ! {self(), add, jhon, 30, "also man"}. 
    {<0.80.0>,add,jhon,30,"also man"}
    7> flush().
    Shell got {ok,2}
    ok
    8> Pid ! {self(), is_member, jack, 30, "also man"}.
    {<0.80.0>,is_member,jack,30,"also man"}
    9> flush().
    ok
    10> Pid ! {self(), is_member, jack, 30}.            
    {<0.80.0>,is_member,jack,30}
    11> flush().
    ok
    12> Pid ! {self(), is_member, jack}.     
    {<0.80.0>,is_member,jack}
    13> flush().
    Shell got {true,3}
    ok
    14> Pid ! {self(), take, jack}.     
    {<0.80.0>,take,jack}
    15> flush().
    Shell got {{ok,50,"man"},4}
    ok
    16> Pid ! {self(), find, jhon}.
    {<0.80.0>,find,jhon}
    17> flush().
    Shell got {{ok,30,"also man"},5}
    ok
    18> Pid ! {self(), delete, jhon}.
    {<0.80.0>,delete,jhon}
    19> flush().
    Shell got {ok,6}
    ok

## Task 2 ##
    Eshell V12.2.1  (abort with ^G)
    1> c(keylist).
    {ok,keylist}
    2> self().
    <0.80.0>
    3> {ok, PidMonitor, MonitorRef} = keylist:start(monitored).
    {ok,<0.88.0>,#Ref<0.3382185195.3996385281.127627>}
    4> PidLinked = keylist:start_link(linked).
    <0.90.0>
    5> PidLinked ! {self(), add, "key1", "value1", "comment1"}.
    {<0.80.0>,add,"key1","value1","comment1"}
    6> PidLinked ! {self(), add, "key2", "value2", "comment2"}.
    {<0.80.0>,add,"key2","value2","comment2"}
    7> PidLinked ! {self(), is_member, "key1"}.
    {<0.80.0>,is_member,"key1"}
    8> PidLinked ! {self(), find, "key2"}.
    {<0.80.0>,find,"key2"}
    9> PidLinked ! {self(), delete, "key1"}.
    {<0.80.0>,delete,"key1"}
    10> flush().
    Shell got {ok,1}
    Shell got {ok,2}
    Shell got {true,3}
    Shell got {{ok,"value2","comment2"},4}
    Shell got {ok,5}
    ok


## Task 3 ##

    10> self().
    <0.80.0>
    11> PidMonitored = whereis(monitored).
    <0.88.0>
    12> exit(PidMonitored, normal).
    true
    13>
    13> flush().
    ok
    14> self().                           
    <0.80.0>
    15> PidMonitored = whereis(monitored).
    <0.88.0>
    16> exit(PidMonitored, killed).
    true
    17> flush().
    Shell got {'DOWN',#Ref<0.3382185195.3996385281.127627>,process,<0.88.0>,
                      killed}
    ok
    18> PidMonitored = whereis(monitored).
    ** exception error: no match of right hand side value undefined
    19>
    19>
    19> self().
    <0.105.0>
    20>
    20>
    20>
    20>
    20>
    20> PidLinked = whereis(linked).
    ** exception error: no match of right hand side value undefined
    21> PidLinked.
    <0.90.0>
    22> exit(PidLinked, killed).
    true
    23>
    23> flush().
    ok
    24> self().
    <0.108.0>
Так как процесс Linked был связан с вашим текущим процессом, завершение процесса Linked также завершит текущий процесс, и self() изменится.

## Task 4 ##
    1> self().
    <0.80.0>
    2> process_flag(trap_exit, true).
    false
    3> PidLinked = keylist:start_link(linked).
    <0.84.0>
    4> exit(PidLinked, killed).
    true
    5> flush().
    Shell got {'EXIT',<0.84.0>,killed}
    ok
    6>
    6> self().
    <0.80.0>
 Так как установлен флаг trap_exit, текущий процесс будет перехватывать сообщения 'EXIT' от завершающихся процессов, вместо того чтобы завершаться вместе с ними. В результате self() останется прежним.
 
## Task 5 ##
    Eshell V12.2.1  (abort with ^G)
    1> self().
    <0.80.0>
    2> process_flag(trap_exit, false).
    false
    3> PidLinked1 = keylist:start_link(linked1)
    3> .
    <0.84.0>
    4> PidLinked2 = keylist:start_link(linked2).
    <0.86.0>
    5> exit(PidLinked1, killed).
    ** exception exit: killed
    6> self().
    <0.88.0>
    7> flush().
    ok
    8> process_info(PidLinked2).
    undefined
Так как установлен флаг trap_exit в значение false, текущий процесс не будет перехватывать сообщения 'EXIT' от завершающихся процессов и завершится вместе с процессом Linked1. В результате self() изменится.

Поскольку процесс Linked2 также был связан с текущим процессом, он также завершится, когда текущий процесс завершится из-за завершения процесса Linked1. 

