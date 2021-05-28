%%%-------------------------------------------------------------------
%%% @author kamotora
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 14. апр. 2021 21:24
%%%-------------------------------------------------------------------
-module(warehouse).
-author("kamotora").

%% API
-export([main/0]).

-import(common, [nop/1, send/2, quoted/1, cookie/0, start/0, rand/1, rand/2, products/0]).

-record(product, {count = 0, price = 0.0}).

name() -> warehouse.

%%{Product, {product, Count, Price}}
generateEntry(K) -> {K, #product{count = rand(1, 10), price = rand(0, 15)}}.

generateStorage() ->
  Storage = ets:new(orders, []),
  ets:insert(Storage, lists:map(fun generateEntry/1, products())),
  Storage.

getNewCount(CurCount) when CurCount =< 0 -> 0;
getNewCount(CurCount) -> CurCount - 1.

subCount(Storage, ProductName) ->
  {Count, Price} = findProduct(Storage, ProductName),
  common:sendToJava(["Warehouse want delete 1 ", ProductName, ". Current params: count: ", Count, ", price: ", Price]),
  ets:insert(Storage, {ProductName, #product{count = getNewCount(Count), price = Price}}).

findProduct(Storage, Product) ->
  findProduct(ets:lookup(Storage, Product)).

findProduct([{_, {_, Count, Price}} | _]) ->
  {Count, Price};
findProduct([]) ->
  {0, 0.0}.

warehouse(Storage) ->
  common:sendToJava([""]),
  receive
    {Product, "Select"} ->
      common:sendToJava(["Warehouse search ", quoted(Product), " in storage"]),
      {Count, Price} = findProduct(Storage, Product),
      send(operator, {Product, Price, Count});
    {Product, "Delete"} ->
      common:sendToJava(["Warehouse delete one ", quoted(Product), " from storage"]),
      subCount(Storage, Product),
      {Count, Price} = findProduct(Storage, Product),
      send(seller, {Product, Price, Count >= 0})
  end, timer:sleep(rand(500, 1500)), warehouse(Storage).

%%main() -> Warehouse_PID = spawn(
%%  fun() ->
%%
%%%%    erlang:set_cookie(node(), cookie()),
%%    common:start(),
%%    warehouse(generateStorage())
%%  end),
%%  global:register_name(name(), Warehouse_PID),
%%  nop(self()).

main() ->
  Pid = spawn(fun() ->
    erlang:set_cookie(node(), cookie()),
    common:start(),
    warehouse(generateStorage())
  end),
  erlang:register(name(), Pid),
  global:register_name(name(), Pid),
  io:format("server started with pid (~p)~n", [Pid]),
  common:nop(self()).