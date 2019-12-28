#!/usr/bin/env escript

-mode(compile).

main ([]) -> batch();
main([Num | _]) ->
    search(list_to_integer(Num)).

is_square(X) ->
    Root = erlang:round(math:sqrt(X)),
    Root * Root == X.

valid_squares(N) ->
    [{A, B}
    || A <- lists:seq(1, N - 1),
       B <- lists:seq(A + 1, N),
       Sum <- [A + B],
       is_square(Sum)].

search(N) ->
    T0 = ts(),
    Graph = digraph:new(),
    Vertices =  maps:from_list([{I, digraph:add_vertex(Graph, ['$v' | I])}
                              || I <- lists:seq(1, N)]),
    lists:foreach(fun ({A, B}) ->
                        Va = maps:get(A, Vertices),
                        Vb = maps:get(B, Vertices),
                        digraph:add_edge(Graph, Va, Vb),
                        digraph:add_edge(Graph, Vb, Va)
                end, valid_squares(N)),
    T1 = ts(),
    Result = case try_find_path(N, Graph, digraph:vertices(Graph), []) of
                 {ok, Solution} -> [I || ['$v' | I] <- Solution];
                 Else -> Else
             end,
    T2 = ts(),
    io:fwrite("~p;~p;~p;~w~n", [N, T1-T0, T2-T1, Result]),
    Result.

find_path(1, _, V, Acc) -> {ok, [V | Acc]};
find_path(N, Graph, V, Acc) ->
    case digraph:out_neighbours(Graph, V) of
        [] -> error;
        Candidates ->
            digraph:del_vertex(Graph, V),
            case try_find_path(N - 1, Graph, Candidates, [V | Acc]) of
                error ->
                    digraph:add_vertex(Graph, V),
                    lists:foreach(fun (W) ->
                                          digraph:add_edge(Graph, V, W),
                                          digraph:add_edge(Graph, W, V)
                                  end,
                                  Candidates),
                    error;
                Ok ->
                    Ok
            end
    end.

try_find_path(N, Graph, Vs, Acc) ->
    Sorted = lists:sort(fun (A, B) ->
                                digraph:out_degree(Graph, A)
                                =< digraph:out_degree(Graph, B)
                        end, Vs),
    do_try_find_path(N, Graph, Sorted, Acc).

do_try_find_path(_, _, [], _) -> error;
do_try_find_path(N, Graph, [V | Vs], Acc) ->
    case find_path(N, Graph, V, Acc) of
        error -> do_try_find_path(N, Graph, Vs, Acc);
        Ok -> Ok
    end.

ts() ->
    erlang:system_time() div 1000000.

batch () ->
    batch(7).

batch([N_str]) when is_list(N_str) ->
    batch(list_to_integer(N_str));
batch(X) ->
    search(X),
    batch(X+1).
