# Homework #11. Eltex.Academy Erlang #
    
_______________________________


______________


Выполнение функций в Eshell:

1. `string:tokens/2`

`string:tokens/2` разбивает строку на токены с использованием заданного разделителя и возвращает список строк.

```erlang
1> string:tokens("one two three", " ").
["one","two","three"]
2> string:tokens("o+n-e tw-+o th+-ree", " +-").
["o","n","e","tw","o","th","ree"]
```

2. `string:join/2`

`string:join/2` объединяет список строк с использованием указанного разделителя и возвращает строку.

```erlang
3> string:join(["one", "two", "three"], ", ").
"one, two, three"
```

3. `string:strip/1` и `string:strip/2`

`string:strip/1` удаляет начальные и конечные пробелы из строки и возвращает новую строку. `string:strip/2` позволяет указать другой список символов, которые также будут удалены.

```erlang
3> string:strip("  hello  ").
"hello"
4> string:strip("###hello###", "#").
"hello"
5> string:strip("###hello###", left,  $#). 
"hello###"
```

4. `string:to_upper/1` и `string:to_lower/1`

`string:to_upper/1` преобразует строку в верхний регистр и возвращает новую строку. `string:to_lower/1` делает то же самое, но преобразует строку в нижний регистр.

```erlang
5> string:to_upper("hello").
"HELLO"
6> string:to_lower("HeLlO").
"hello"
```

5. `string:to_integer/1` и `erlang:list_to_integer/1`

`string:to_integer/1` преобразует строку, представляющую целое число, в целое число и возвращает его. `erlang:list_to_integer/1` делает то же самое, но принимает список цифр вместо строки.

```erlang
7> string:to_integer("4256").
4256
8> erlang:list_to_integer([4,2,5,6]).
4256
```

6. `erlang:byte_size/1`

`erlang:byte_size/1` возвращает размер бинарного объекта в байтах.

```erlang
9> erlang:byte_size(<<"hello">>).
5
```

7. `erlang:split_binary/2`

`erlang:split_binary/2` разбивает бинарный объект на части с помощью указанного разделителя и возвращает список бинарных объектов.

```erlang
10> erlang:split_binary(<<"one,two,three">>, ",").
[<<"one">>,<<"two">>,<<"three">>]
```

8. `erlang:binary_part/3`

`erlang:binary_part/3` извлекает подстроку указанной длины из бинарного объекта, начиная с указанной позиции.

```erlang
11> erlang:binary_part(<<"hello wrold">>, 2, 3).
<<"llo">>
12> erlang:binary_part(<<"hello wrold">>, 4, 5).
<<"o wro">>
```

9. `binary:split/2`

`binary:split/2` разбивает бинарный объект на части с помощью указанного разделителя и возвращает список бинарных объектов.

```erlang
12> binary:split(<<"one,two,three">>, <<",">>).
[<<"one">>,<<"two">>,<<"three">>]
```

10. `binary:match/2` и `binary:matches/3`

`binary:match/2` проверяет, содержится ли заданная подстрока в бинарном объекте. `binary:matches/3` делает то же самое, но принимает дополнительный параметр - начальную позицию поиска.

```erlang
13> binary:match(<<"hello">>, <<"ll">>).
true
14> binary:matches(<<"hello">>, <<"l">>, 3).
true
```

11. `binary:replace/3`

`binary:replace/3` заменяет все вхождения одного бинарного объекта на другой бинарный объект.

```erlang
15> binary:replace(<<"one two one two">>, <<"one">>, <<"three">>).
<<"three two three two">>
```

12. `binary_to_list/1` и `list_to_binary/1`

`binary_to_list/1` преобразует бинарный объект в список целых чисел. `list_to_binary/1` делает то же самое, но преобразует список целых чисел в бинарный объект.

```erlang
16> binary_to_list(<<"hello">>).
[104, 101, 108, 108, 111]
17> list_to_binary([104, 101, 108, 108, 111]).
<<"hello">>
```

13. `lists:flatten/1`

`lists:flatten/1` сглаживает вложенный список, преобразуя его в одномерный список.

```erlang
18> lists:flatten([1, [2, [3]], 4]).
[1,2,3,4]
```