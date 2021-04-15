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
-export([paymentSystem/0, main/0]).

-import(common, [nop/1, send/2, say/2, sayEx/1, quoted/1, cookie/0, init/0, rand/1, rand/2]).

name() -> paymentSystem.

paymentSystem() ->
  sayEx(["Payment system wait payment"]),
  receive
    {Product, Price, Type} when Type == "Paid" ->
      sayEx(["Get payment for ", quoted(Product), ", amount: ", Price]),
      check(Price),
      send(seller, {Product, Type});
    {Product, Price, Type} when Type == "Refund" ->
      sayEx(["Get refund for ", quoted(Product), ", amount: ", Price]),
      check(Price),
      send(customer, {Price, "Refund"})
  end.

main() -> PaymentSystem_PID = spawn(fun() -> common:init(), paymentSystem() end),
  global:register_name(name(), PaymentSystem_PID), nop(self()).


check(Price) ->
  if
    Price > 0 -> true;
    true -> erlang:error(errorPayment)
  end.