-module(uuid).
-export([v4/0]).

v4() ->
  <<A:32, B:16, C:16, D:16, E:48>> = crypto:strong_rand_bytes(16),
  io_lib:format("~8.16.0b-~4.16.0b-4~3.16.0b-~4.16.0b-~12.16.0b",
    [A, B, C band 16#0fff, D band 16#3fff bor 16#8000, E]).