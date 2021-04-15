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

-import(common, [nop/1, send/2, say/2, sayEx/1, quoted/1, cookie/0, init/0, rand/1, rand/2, products/0]).

name() -> customer.

getRandomProduct() -> lists:nth(rand:uniform(length(products())), products()).

%%todo разбить на функции
customer() -> Product = getRandomProduct(),
  send(operator, Product),
  sayEx(["Customer want a ", quoted(Product)]),
  receive
    {0, _} -> sayEx(["Not found ", quoted(Product)]);
    {Count, Price} when Price > 10 ->
      sayEx(["We have ", quoted(Product), ", count: ", Count, ", price: ", Price]),
      sayEx(["Customer want buy a ", quoted(Product)]),
      send(paymentSystem, {Product, Price, "Paid"});
    {_, _} ->
      sayEx([quoted(Product), " very expensive, customer go away..."])
  after 5000 -> sayEx(["Customer timeout..."])
  end,

  sayEx(["Customer wait product ", quoted(Product), " or refund"]),
  receive
    {Price, "Refund"} -> sayEx(["Customer getting refund on amount ", Price, " ... :( "]);
    {Product} ->
      sayEx(["Customer getting ", quoted(Product)])
  after 5000 -> sayEx(["Customer timeout..."])
  end, timer:sleep(rand(500, 1500)), customer().

main() -> Customer_PID = spawn(fun() ->
%%  common:init(),
  customer() end),
  global:register_name(name(), Customer_PID), nop(self()).


