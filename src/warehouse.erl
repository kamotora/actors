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
-export([]).

-import(common, [nop/1, send/2, say/2, sayEx/1, quoted/1, cookie/0, init/0, rand/1, rand/2, products/0]).

-record(product, {count = 0, price = 0.0}).

name() -> warehouse.

%%{Product, {Count, Price}}
generateEntry(K) -> {K, #product{count = rand(1, 5), price = rand(0, 100)}}.

generateStorage() ->
  maps:from_list(lists:map(fun generateEntry/1, products())).
%%  Storage = ets:new(storage, []),

subCount(ProductName, Storage) ->
  ProductInfo = maps:get(ProductName, Storage),
  maps:put(ProductName, #product{count = ProductInfo#product.count - 1, price = ProductInfo#product.price}, Storage),
  maps:get(ProductName, Storage).

warehouse(Storage) ->
%%  вместо select, delete разделять по тому, кто послал запрос
  receive
    {Product, "Select"} ->
      sayEx(["Warehouse search ", quoted(Product), " in storage"]),
      CountAndPrice = maps:get(Product, Storage, {0, 0}),
      send(operator, CountAndPrice);
    {Product, "Delete"} ->
      sayEx(["Warehouse delete one ", quoted(Product), " from storage"]),
      {Count, Price} = subCount(Product, Storage),
      send(seller, {Product, Price, Count >= 0})
  end, timer:sleep(rand(500, 1500)), warehouse(Storage).

main() -> Warehouse_PID = spawn(fun() -> common:init(), warehouse(generateStorage()) end),
  global:register_name(name(), Warehouse_PID), nop(self()).