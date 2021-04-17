%%%-------------------------------------------------------------------
%%% @author kamotora
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. апр. 2021 21:12
%%%-------------------------------------------------------------------
-module(tests).
-author("kamotora").

-include_lib("eunit/include/eunit.hrl").
-import(common, [injectPostfix/1, pingNodes/2]).

inject_postfix_test() ->
  ?assertEqual(["test1@127.0.1.0", "test2@127.0.1.0"], injectPostfix(["test1", "test2"])).

ping_nodes_test() ->
  ?assertEqual({[], fail}, pingNodes(["toExcept"], nodes())).
