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
-export([]).

-import(common, [nop/1, send/2, say/2, sayEx/1, quoted/1, cookie/0, init/0, rand/1, rand/2]).

name() -> operator.

operator() ->
  receive
    {Product} ->
      sayEx(["Operator search ", quoted(Product), " in warehouse"]),
      send(warehouse, {Product, "Select"});
    {Count, Price} ->
      send(customer, {Count, Price})
  end, timer:sleep(rand(500, 1500)), operator().

main() -> Operator_PID = spawn(fun() -> common:init(), operator() end),
  global:register_name(name(), Operator_PID), nop(self()).
