%%%-------------------------------------------------------------------
%%% @author kamotora
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 14. апр. 2021 20:09
%%%-------------------------------------------------------------------
-module(common).
-author("kamotora").

%% API
-export([nop/0, nop/1, nameOf/1, send/2, say/2, quoted/1, say/1, sayEx/1,
  pingNodes/1, nodes/0, injectPostfix/1, init/0, init/1, rand/1, rand/2, products/0]).

nop(Name) -> io:format("~w waits for a wonder ... ~n", [Name]),
  receive
    Message -> io:format("Got msg=~p~n", [Message])
  end,
  nop(Name).

nop() ->
  io:format("~w waits for a wonder ... ~n", [self()]),
  receive
    Message -> io:format("Got msg=~p~n", [Message])
  end,
  nop().

nameOf(Atom) -> global:whereis_name(Atom).

send(To, Message) -> nameOf(To) ! Message, sent.

say(Message, [Params]) -> io:format(Message ++ "~n", Params).
say(Message) -> io:format(Message ++ "~n").
sayEx(Strings) -> io:format(string:join(Strings, " ") ++ "~n").

quoted(String) -> "'" ++ String ++ "'".
% Returns all nodes available.
nodes() -> injectPostfix(["customer", "operator",
  "paymentSystem", "seller", "warehouse"]).

injectPostfix([Head | Tail]) -> [Head ++ "@127.0.0.1"] ++ injectPostfix(Tail);
injectPostfix([]) -> [].

rand(Ceil) -> floor(rand:uniform() * Ceil).
rand(From, To) -> floor(From + rand:uniform() * (To - From)).

init() -> case pingNodes(nodes())
          of
            {Pings, fail} -> say("Reached nodes: ~p", [[Pings]]),
              timer:sleep(1000), % 1 second
              init([Pings]);
            {_, done} -> say("All nodes were reached"), done
          end.

init([Performed]) -> case pingNodes(Performed, nodes())
                     of
                       {Pings, fail} -> say("Reached nodes: ~p", [[Pings]]),
                         timer:sleep(1000),
                         init([Pings]);
                       {_, done} -> say("All nodes were reached"), done
                     end.

% External
pingNodes(List) -> pingNodes([], List).

% Ping all nodes (except members of 'Except') to make sending by its names possible
pingNodes(Except, [Head | Tail]) ->
  case lists:member(Head, Except)
  of
    true -> pingNodes(Except, Tail);
    false ->
      case net_adm:ping(list_to_atom(Head))
      of
        pong -> pingNodes(Except ++ [Head], Tail, done);
        pang -> pingNodes(Except, Tail, fail)
      end
  end;
pingNodes(Except, []) -> {Except, fail}.

pingNodes(Except, [Head | Tail], Result) ->
  case lists:member(Head, Except)
  of
    true -> pingNodes(Except, Tail, Result);
    false ->
      case net_adm:ping(list_to_atom(Head))
      of
        % pulls saved Result
        pong -> pingNodes(Except ++ [Head], Tail, Result);
        % no response means overriding previous successful pings
        pang -> pingNodes(Except, Tail, fail)
      end
  end;

% Returns such values as
%   {[<Except + Successful pinged nodes>], done.} - in case if all nodes were pinged.
%   {[<Except + Successful pinged nodes>], fail.} - in case if not all of the nodes were pinged.
pingNodes(Except, [], Result) -> {Except, Result}.

products() ->
  ["Book", "Phone", "Card", "Notebook", "Speakers", "TV"].

