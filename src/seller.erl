%%%-------------------------------------------------------------------
%%% @author kamotora
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 14. апр. 2021 21:21
%%%-------------------------------------------------------------------
-module(seller).
-author("kamotora").

%% API
-export([seller/0, main/0]).

-import(common, [nop/1, send/2, say/2, sayEx/1, quoted/1, cookie/0, init/0, rand/1, rand/2]).

name() -> seller.

seller() ->
  receive
    {Product, "Paid"} ->
      send(warehouse, Product, "Delete"),
      receive
        {Product, Price, false} ->
          send(paymentSystem, {Product, Price, "Refund"});
        {Product, Price, true} ->
          send(customer, Product)
      end
  end, timer:sleep(rand(500, 1500)), seller().

main() -> Seller_PID = spawn(fun() -> common:init(), seller() end),
  global:register_name(name(), Seller_PID), nop(self()).