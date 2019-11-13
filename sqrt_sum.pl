:- use_module(library(clpfd)).

is_sum_sqrt(X, Y) :-
     Z*Z #= (X+Y), Z #>0.

test([]).
test([_]).
test([X, Y | Rest]) :-
    is_sum_sqrt(X, Y),
    test([Y | Rest]).

solve(N, Vars) :-
    length(Vars, N),
    Vars ins 1..N,
    all_different(Vars),
    test(Vars),
    label(Vars).
