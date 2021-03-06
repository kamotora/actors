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
  common:sendToJava([""]),
  common:sendToJava(["Payment system wait payment"]),
  receive
    {OrderId, Product, Price, Type} when Type == "Paid" ->
      common:sendToJava(["Get payment for ", quoted(Product), ", amount: ", Price]),
      ets:insert(Orders, {OrderId, "Paid"}),
      send(seller, {OrderId, Product, Type}),
      common:sendToJava(["Send seller, that ", quoted(Product), " was paid, price: ", Price]);
    {OrderId, Product, Price, Type} when Type == "Refund" ->
      common:sendToJava(["Get refund for ", quoted(Product), ", amount: ", Price]),
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
getStatus(List) when length(List) == 0 -> notFound.


%%main() -> PaymentSystem_PID = spawn(
%%  fun() ->
%%%%    erlang:set_cookie(node(), cookie()),
%%    common:start(),
%%    paymentSystem(ets:new(orders, [])) end),
%%  global:register_name(name(), PaymentSystem_PID),
%%  nop(self()).

main() ->
  Pid = spawn(
    fun() ->
      erlang:set_cookie(node(), cookie()),
      common:start(),
      paymentSystem(ets:new(orders, [])) end),
  erlang:register(name(), Pid),
  global:register_name(name(), Pid),
  io:format("server started with pid (~p)~n", [Pid]),
  common:nop(self()).
