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
-export([main/0, customer/0, init/0]).

-import(common, [send/2, quoted/1, cookie/0, start/0, rand/1, rand/2, products/0]).

name() -> customer.

getRandomProduct() -> lists:nth(rand:uniform(length(products())), products()).

%%todo разбить на функции
customer() ->
  common:sendToJava(customerReceiver, ["Waiting product from Java"]),
  receive
    {Product} ->
      common:sendToJava(customerReceiver, ["Customer want a ", quoted(Product)]),
      send(operator, {Product}),
      receive
        {_Product, 0} when Product == _Product ->
          common:sendToJava(customerReceiver, ["Not found ", quoted(Product)]);
        {OrderId, _Product, Price, Count} when Price =< 10, Product == _Product ->
          %%      payOrder
          common:sendToJava(customerReceiver, ["We have ", quoted(Product), ", count: ", Count, ", price: ", Price]),
          common:sendToJava(customerReceiver, ["Customer want buy a ", quoted(Product), ". OrderID:", OrderId]),
          send(paymentSystem, {OrderId, Product, Price, "Paid"}),
          %%      waitProduct
          common:sendToJava(customerReceiver, ["Customer wait product ", quoted(Product), " or refund"]),
          receive
            {_OrderId, Price, "Refund"} when OrderId == _OrderId ->
              common:sendToJava(customerReceiver, ["Customer getting refund on amount ", Price, " ... :( "]);
            {_OrderId, Product} when OrderId == _OrderId ->
              common:sendToJava(customerReceiver, ["Customer SUCCESSFULLY getting ", quoted(Product)])
          after 5000 -> common:sendToJava(customerReceiver, ["Customer waits for a very long time, he go away..."])
          end;
        {_, _, Price, _} when Price >= 10 ->
          common:sendToJava(customerReceiver, [quoted(Product), " very expensive. Customer have only 10 shekels, customer go away..."])
      after 5000 -> common:sendToJava(customerReceiver, ["Customer waits for a very long time, he go away..."])
      end
  end, customer().

%%main() -> Customer_PID = spawn(fun() ->
%%  common:start(),
%%  customer() end),
%%  global:register_name(name(), Customer_PID),
%%  common:nop(self()).

main() ->
  Pid = spawn(
    fun() ->
      erlang:set_cookie(node(), cookie()),
      common:start(),
      customer() end),
  erlang:register(name(), Pid),
  global:register_name(name(), Pid),
  io:format("server started with pid (~p)~n", [Pid]),
  common:nop(self()).

%%main() ->
%%  common:start(),
%%  Pid = spawn(?MODULE, customer, []),
%%  register(customer, Pid),
%%  io:format("server started with pid (~p)~n", [Pid]),
%%  erlang:set_cookie(node(), cookie()),
%%  common:nop(self()).

init() ->
  customer().


