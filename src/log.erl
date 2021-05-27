%%%-------------------------------------------------------------------
%%% @author kamotora
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. апр. 2021 23:07
%%%-------------------------------------------------------------------
-module(log).
-author("kamotora").
-export([sayEx/1, say/1, say/2]).

say(Message, [Params]) -> io:format(Message ++ "~n", Params).

-spec log:say(Message) -> true when Message :: string().
say(_Message) -> io:format(string:concat(_Message, "~n")).

%% todo логгер в java, передавая pid(от кого) и сам лог. Адрес логера можно захардкодить здесь
-spec log:sayEx(Strings) -> true when Strings :: list().
sayEx(_Strings) -> say(lists:concat(_Strings)).




