# Homework #15. Eltex.Academy Erlang #

_______________________________
В ходе данной работы разобрался с gen_statem, реализовал состояние suspended, в которое переходит дверь на 10 секунд, после 3 неудачных попыток ввести код

Сделал спеку и документацию к API функциям. Получилось добавить тесты 
______________

## Task ##
    1> c(door).
    {ok,door}

Инициализируем дверь

    2> door:start([1, 2, 3, 4]).
    Initializing locked door.
    {ok,<0.87.0>}

Вводим правильный код

    3> door:enter(1).
    Received Msg {enter,1} LoopData {data,[1,2,3,4],1,[]}
    Entered len: 1
    Code len: 4
    {ok,next}
    4> door:enter(2).
    Received Msg {enter,2} LoopData {data,[1,2,3,4],1,[1]}
    Entered len: 2
    Code len: 4
    {ok,next}
    5> door:enter(3).
    Received Msg {enter,3} LoopData {data,[1,2,3,4],1,[2,1]}
    Entered len: 3
    Code len: 4
    {ok,next}
    6> door:enter(4).
    Received Msg {enter,4} LoopData {data,[1,2,3,4],1,[3,2,1]}
    Entered len: 4
    Code len: 4
    {ok,opened}

Игнорируем попытки ввести новый код, пока дверь открыта

    7> door:enter(4).
    Ignored 4. Door already opened
    {error,already_opened}
    Timeout, the door will be locked
    
Вводим неверный код несколько раз

    8> door:enter(4).
    Received Msg {enter,4} LoopData {data,[1,2,3,4],1,[]}
    Entered len: 1
    Code len: 4
    {ok,next}
    9> door:enter(4).
    Received Msg {enter,4} LoopData {data,[1,2,3,4],1,[4]}
    Entered len: 2
    Code len: 4
    {ok,next}
    10> door:enter(4).
    Received Msg {enter,4} LoopData {data,[1,2,3,4],1,[4,4]}
    Entered len: 3
    Code len: 4
    {ok,next}
    11> door:enter(4).
    Received Msg {enter,4} LoopData {data,[1,2,3,4],1,[4,4,4]}
    Entered len: 4
    Code len: 4
    {error,wrong_code}


    12> door:enter(4).
    Received Msg {enter,4} LoopData {data,[1,2,3,4],2,[]}
    Entered len: 1
    Code len: 4
    {ok,next}
    13> door:enter(4).
    Received Msg {enter,4} LoopData {data,[1,2,3,4],2,[4]}
    Entered len: 2
    Code len: 4
    {ok,next}
    14> door:enter(4).
    Received Msg {enter,4} LoopData {data,[1,2,3,4],2,[4,4]}
    Entered len: 3
    Code len: 4
    {ok,next}
    15> door:enter(4).
    Received Msg {enter,4} LoopData {data,[1,2,3,4],2,[4,4,4]}
    Entered len: 4
    Code len: 4
    {error,wrong_code}
    
    
    16> door:enter(4).
    Received Msg {enter,4} LoopData {data,[1,2,3,4],3,[]}
    Entered len: 1
    Code len: 4
    {ok,next}
    17> door:enter(4).
    Received Msg {enter,4} LoopData {data,[1,2,3,4],3,[4]}
    Entered len: 2
    Code len: 4
    {ok,next}
    18> door:enter(4).
    Received Msg {enter,4} LoopData {data,[1,2,3,4],3,[4,4]}
    Entered len: 3
    Code len: 4
    {ok,next}
    19> door:enter(4).
    Received Msg {enter,4} LoopData {data,[1,2,3,4],3,[4,4,4]}
    Entered len: 4
    Code len: 4
    {error,attempt_limit_reached}
    
Игнорируем попытки ввода кода пока дверь заблокирована

    20> door:enter(4).
    Ignored 4. Door suspended
    {error,suspended}
    21> door:enter(4).
    Ignored 4. Door suspended
    {error,suspended}
    22> door:enter(4).
    Ignored 4. Door suspended
    {error,suspended}
    Door enabled to enter code

Дверь разблокирована продолжаем ввод кода

    23> door:enter(4).
    Received Msg {enter,4} LoopData {data,[1,2,3,4],1,[]}
    Entered len: 1
    Code len: 4
    {ok,next}
  
Проверяем тесты для состояний: locked, open, suspended

    15> c(door_test).
    {ok,door_test}
    16> eunit:test(door_test).
        All 3 tests passed.
    ok
