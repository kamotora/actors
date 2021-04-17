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

-import(common, [nop/1, send/2, quoted/1, cookie/0, rand/1, rand/2]).

name() -> seller.

seller() ->
  log:say(""),
  receive
    {OrderId, Product, "Paid"} ->
      log:sayEx(["Seller search ", quoted(Product), " in warehouse"]),
      send(warehouse, {Product, "Delete"}),
      receive
        {Product, Price, false} ->
          log:sayEx(["Seller NOT found ", quoted(Product), " in warehouse"]),
          send(paymentSystem, {OrderId, Product, Price, "Refund"});
        {Product, _, true} ->
          log:sayEx(["Seller FOUND ", quoted(Product), " in warehouse"]),
          send(customer, {OrderId, Product})
      end
  end, timer:sleep(rand(500, 1500)), seller().


main() -> Seller_PID = spawn(
  fun() ->
    common:start(),
    seller() end),
  global:register_name(name(), Seller_PID), nop(self()).