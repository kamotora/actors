%%%-------------------------------------------------------------------
%%% @author kamotora
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 14. апр. 2021 21:05
%%%-------------------------------------------------------------------
-module(customer).
-author("kamotora").

%% API
-export([main/0, customer/0]).

-import(common, [send/2, quoted/1, cookie/0, start/0, rand/1, rand/2, products/0]).

name() -> customer.

getRandomProduct() -> lists:nth(rand:uniform(length(products())), products()).

%%todo разбить на функции
customer() ->
  log:say(""),
  log:say("Waiting product from Java"),
  receive
    Product ->
      log:sayEx(["Customer want a ", quoted(Product)]),
      receive
        {_Product, 0} when Product == _Product ->
          log:sayEx(["Not found ", quoted(Product)]);
        {OrderId, _Product, Price, Count} when Price =< 10, Product == _Product ->
          %%      payOrder
          log:sayEx(["We have ", quoted(Product), ", count: ", Count, ", price: ", Price]),
          log:sayEx(["Customer want buy a ", quoted(Product), ". OrderID:", OrderId]),
          send(paymentSystem, {OrderId, Product, Price, "Paid"}),
          %%      waitProduct
          log:sayEx(["Customer wait product ", quoted(Product), " or refund"]),
          receive
            {_OrderId, Price, "Refund"} when OrderId == _OrderId ->
              log:sayEx(["Customer getting refund on amount ", Price, " ... :( "]);
            {_OrderId, Product} when OrderId == _OrderId ->
              log:sayEx(["Customer SUCCESSFULLY getting ", quoted(Product)])
          after 5000 -> log:sayEx(["Customer waits for a very long time, he go away..."])
          end;
        {_, _, Price, _} when Price >= 10 ->
          log:sayEx([quoted(Product), " very expensive. Customer have only 10 shekels, customer go away..."])
      after 5000 -> log:sayEx(["Customer waits for a very long time, he go away..."])
      end
  end, customer().

main() -> Customer_PID = spawn(fun() ->
  common:start(),
  customer() end),
  global:register_name(name(), Customer_PID),
  common:nop(self()).


