%%%-------------------------------------------------------------------
%%% @author kamotora
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 14. апр. 2021 21:23
%%%-------------------------------------------------------------------
-module(paymentSystem).
-author("kamotora").

%% API
-export([main/0]).

-import(common, [nop/1, send/2, quoted/1, cookie/0, start/0, rand/1, rand/2]).

name() -> paymentSystem.

paymentSystem(Orders) ->
  log:say(""),
  log:sayEx(["Payment system wait payment"]),
  receive
    {OrderId, Product, Price, Type} when Type == "Paid" ->
      log:sayEx(["Get payment for ", quoted(Product), ", amount: ", Price]),
      ets:insert(Orders, {OrderId, "Paid"}),
      send(seller, {OrderId, Product, Type}),
      log:sayEx(["Send seller, that ", quoted(Product), " was paid, price: ", Price]);
    {OrderId, Product, Price, Type} when Type == "Refund" ->
      log:sayEx(["Get refund for ", quoted(Product), ", amount: ", Price]),
      refundOrder(OrderId, Orders),
      send(customer, {OrderId, Price, "Refund"})
  end, timer:sleep(rand(500, 1500)), paymentSystem(Orders).

refundOrder(Orders, OrderId) ->
  case getStatus(Orders, OrderId) of
    "Paid" -> ets:insert(Orders, {OrderId, "Refund"});
    true -> erlang:error(notFoundOrNotPaid)
  end.

getStatus(Orders, OrderId) ->
  getStatus(ets:lookup(Orders, OrderId)).
getStatus([{_, Status} | _]) -> Status;
getStatus(List) when length(List) == 0-> notFound.


main() -> PaymentSystem_PID = spawn(
  fun() ->
    common:start(),
    paymentSystem(ets:new(orders, [])) end),
  global:register_name(name(), PaymentSystem_PID), nop(self()).
