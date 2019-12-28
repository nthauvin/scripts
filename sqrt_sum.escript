#!/usr/bin/env escript

-mode(compile).

main ([]) -> batch();
main ([N_str]) ->
    run(list_to_integer(N_str)).

run (N) ->
    T0 = ts(),
    Numbers = lists:seq(1, N),
    Squares = squares(N),
    Nexts = nexts(N, Numbers, Squares),
    T1 = ts(),
    Result = find_sequence(N, Numbers, Nexts),
    T2 = ts(),
    ets:delete(Nexts),
    Sequence = case Result of
                   {ok, Seq} -> Seq;
                   _ -> []
               end,
    io:fwrite("~p;~p;~p;~w~n", [N, T1-T0, T2-T1, Sequence]),
    Result.

squares (N) ->
    lists:foldl(fun(I, Acc) -> sets:add_element(I*I, Acc)
                end, sets:new(), lists:seq(1, N + N - 1)).

nexts(N, Numbers, Squares) ->
    Tab = ets:new(nexts, [public, named_table]),
    [insert_next(Tab, Squares, I, J) || I <- Numbers, J <- lists:seq(I+1, N)],
    Tab.

insert_next(Tab, Squares, I, J) ->
    case sets:is_element(I+J, Squares) of
        true ->
            insert_next_couple(Tab, I, J),
            insert_next_couple(Tab, J, I),
            ok;
        _ ->
            no_square
    end.

insert_next_couple (Tab, X, Y) ->
    case ets:lookup(Tab, X) of
        [] -> ets:insert(Tab, {X, [Y]});
        [{_, List}] -> ets:insert(Tab, {X, [Y | List]})
    end.

find_sequence(N, Numbers, Nexts) ->
    Pool_size = erlang:system_info(logical_processors_available),
    find_sequence_pool(N, Numbers, Nexts, Pool_size, []).

find_sequence_pool(N, [],  Nexts, Slots, Workers) when length(Workers) > 0 ->
    wait_for_worker_result(N, [], Nexts, Slots, Workers);
find_sequence_pool(_, [], _, _, []) -> not_found;
find_sequence_pool(N, [Number|Tail], Nexts, Slots, Workers) when Slots > 0 ->
    New_worker = spawn_worker(N, Nexts, [Number]),
    Workers2 = [New_worker | Workers],
    find_sequence_pool(N, Tail, Nexts, Slots-1, Workers2);
find_sequence_pool(N, Numbers, Nexts, Slots, Workers) ->
    wait_for_worker_result(N, Numbers, Nexts, Slots, Workers).

wait_for_worker_result(N, Numbers, Nexts, Slots, Workers) ->
    receive
        {result, {_, {ok, _} = Result}} ->
            [exit(Pid, done) || Pid <- Workers],
            wait_for_termination(Workers),
            Result;
        {result, {Worker, not_found}} ->
            Workers2 = Workers -- [Worker],
            find_sequence_pool(N, Numbers, Nexts, Slots+1, Workers2)
    end.

wait_for_termination([]) -> ok;
wait_for_termination([Worker | Workers]) ->
    case erlang:is_process_alive(Worker) of
        true ->
            timer:sleep(100),
            wait_for_termination([Worker|Workers]);
        _ ->
            wait_for_termination(Workers)
    end.

spawn_worker (N, Nexts, Init_sequence) ->
    Parent = self(),
    spawn(fun() ->
                  Result = solve(N, Nexts, Init_sequence),
                  Parent ! {result, {self(), Result}}
          end).


best_candidates (_, [One], _) -> [One];
best_candidates (Nexts, Neighbours, Sequence) ->
    Count_candidates =
        lists:map(
          fun(C) ->
                  [{_, Choices}] = ets:lookup(Nexts, C),
                  {length(Choices -- Sequence), C}
          end, Neighbours),
    [C || {Count, C} <- lists:sort(Count_candidates), Count /= 0].

solve (N, _, Sequence) when length(Sequence) == N ->
    {ok, Sequence};
solve (N, Nexts, [First | _] = Sequence) ->
    [{_, Neighbours}] = ets:lookup(Nexts, First),
    Possible = Neighbours -- Sequence,
    Best_candidates = best_candidates(Nexts, Possible, Sequence),
    try_candidates(N, Nexts, Sequence, Best_candidates).

try_candidates (_, _, _, []) -> not_found;
try_candidates (N, Nexts, Sequence, [C | Candidates]) ->
    case solve(N, Nexts, [C | Sequence]) of
        not_found -> try_candidates (N, Nexts, Sequence, Candidates);
        Else -> Else
    end.

batch () ->
    batch(7).

batch([N_str]) when is_list(N_str) ->
    batch(list_to_integer(N_str));
batch(X) ->
    run(X),
    batch(X+1).

ts() ->
    erlang:system_time() div 1000000.
