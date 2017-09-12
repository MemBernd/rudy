-module(test).
-export([bench/2,dobench/3]).

dobench(N, Host, Port) ->
    dobench (N, Host, Port, []).

dobench(0, _, _, Times) ->
    average(Times);
dobench(N, Host, Port, Times) ->
    dobench(N-1, Host, Port, [bench(Host, Port)|Times]).

bench(Host, Port) ->
    Start = erlang:system_time(micro_seconds),
    run(100, Host, Port),
    Finish = erlang:system_time(micro_seconds),
    Finish -Start.

run(N, Host, Port) ->
    if
        N==0 ->
            ok;
        true ->
            request(Host, Port),
            run(N-1, Host, Port)
    end.

request(Host, Port) ->
    Opt = [list, {active, false}, {reuseaddr, true}],
    {ok, Server} = gen_tcp:connect(Host, Port, Opt),
    gen_tcp:send(Server, http:get("foo")),
    Recv = gen_tcp:recv(Server, 0),
    case Recv of
        {ok, _} ->
            ok;
        {error, Error} ->
            io:format("test: error: ~w~n", [Error])
    end,
    gen_tcp:close(Server).

sumList(List) ->
    sumList(List, 0).
sumList([H|R], Sum) ->
    sumList(R, H + Sum);
sumList([], Sum) ->
    Sum.

average(List) ->
    sumList(List) / length(List).
