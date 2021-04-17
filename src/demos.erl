-module(demos).
-author("kamotora").

%% API
-export([ spawnDemo/0,
  saySomething/2, pingPongDemo/0, ping/2,
  pong/0, testUUID/0]).

saySomething(_, 0) ->
  done;
saySomething(What, Times) ->
  io:format("~p~n", [What]),
  saySomething(What, Times - 1).

ping(0, Pong_PID) ->
  Pong_PID ! finished,
  log:say("Ping finished");

ping(N, Pong_PID) ->
  Pong_PID ! {ping, self()},
  receive
    pong ->
      io:format("Ping received pong~n", [])
  end,
  ping(N - 1, Pong_PID).

pong() ->
  receive
    finished ->
      log:say("Pong finished");
    {ping, Ping_PID} ->
      io:format("Pong received ping~n", []),
%%      log:say("Pong received ping"),
      Ping_PID ! pong,
      pong()
  end.

spawnDemo() ->
  spawn(demos, saySomething, [hello, 3]),
  spawn(demos, saySomething, [goodbye, 3]).

pingPongDemo() ->
  Pong_PID = spawn(demos, pong, []),
  spawn(demos, ping, [3, Pong_PID]).

testUUID() ->
  erlang:display(uuid:v4()),
  log:say(uuid:v4()),
  log:sayEx(["This is UUID:", uuid:v4()]).
