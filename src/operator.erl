%%%-------------------------------------------------------------------
%%% @author kamotora
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 14. апр. 2021 21:13
%%%-------------------------------------------------------------------
-module(operator).
-author("kamotora").

%% API
-export([operator/0, main/0]).

-import(common, [nop/1, send/2, quoted/1, cookie/0, start/0, rand/1, rand/2]).

name() -> operator.

operator() ->
  log:say(""),
  receive
    {Product} ->
      log:sayEx(["Operator search ", quoted(Product), " in warehouse"]),
      send(warehouse, {Product, "Select"});
    {Product, _, Count} when Count == 0 ->
      log:sayEx(["Operator not found ", Product, " in warehouse :("]),
      send(customer, {Product, 0});
    {Product, Price, Count} when Count > 0 ->
      log:sayEx(["Operator FOUND ", Product, " in warehouse, count:", Count,", price:", Price]),
      send(customer, {uuid:v4(), Product, Price, Count})
  end, timer:sleep(rand(500, 1500)), operator().

main() -> Operator_PID = spawn(
  fun() ->
    common:start(),
    operator() end),
  global:register_name(name(), Operator_PID),
  nop(self()).
