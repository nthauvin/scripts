#!/usr/bin/env python3

"""

This modules combines neighbours cache and derecursion optimization
to solve the Square-sum problem

Computes the solutions from N=7 when no argument is passed
Computes the solution for N if passed as an argument
"""

import sys
import math
import time
import concurrent.futures

Max = 0
if (len(sys.argv) == 2):
    Max = int(sys.argv[1])

def gen_squares(N):
    """
    Computes all the perfect squares i*i for i in 1 to N
    Can be used as a cache for later computations
    """
    squares = set([])
    i = 1
    while i*i <= N + (N-1) :
        squares.add(i*i);
        i = i + 1
    return squares

def gen_nexts(N, numbers, squares):
    """
    Computes a dictionnary of available moves for each number
    """
    nexts = dict()
    for i in numbers :
        for j in range(i+1, N+1):
            if i+j in squares:
                nexts[i] = nexts.get(i, []) + [j]
                nexts[j] = nexts.get(j, []) + [i]
    return nexts

def find_sequence (N, numbers, nexts):
    """
    Find solution sequences for starting numbers
    Returns (True, sequence) when found of (False, _} otherwise
    """
    if len(numbers) == 0:
        return (False, [])
    first = numbers[0]
    (found, sequence) = solve(N, nexts, [first], [nexts[first]])
    if found:
        return (found, sequence)
    else:
        return find_sequence(N, numbers[1:], nexts)

def best_candidates (nexts, neighbours, sequence):
    """
    Given a list of possible neighbours, sort them so that next numbers
    with less edges come first
    """
    if len(neighbours) == 1:
        return neighbours
    else:
        Stats = []
        for n in neighbours:
            Choices = [x for x in nexts[n] if x not in sequence]
            Count = len(Choices)
            if Count != 0:
                Stats.append((len(Choices), n))
        Stats.sort()
        return [x for (count, x) in Stats]

def solve (N, nexts, sequence, graphs):
    """
    sequence solver without recursion to preserve Python call stack
    'sequence' is the sequence being built, node after node
    'Graph' is the corresponding list of still available choice graphs
    eg : sequence = [3,       1]
         graphs =   [[6, 13], [8],
    Means that for number 3, available choices are 6 and 13
    (sorted by preference)
    If 3 results in a dead branch, new backtracked state would be:
         sequence = [1]
         graphs =   [8]
    leading to sequence = [8, 1]
               graphs = []
    """
    while len(sequence) < N and len(sequence) > 0:
        candidates = graphs[0].copy() # wtf ? corrupts nexts without copy()
        if candidates == []:
            sequence.pop(0)
            graphs.pop(0)
        else:
            number = sequence[0]
            candidate = candidates.pop(0)
            graphs[0] = candidates
            neighbours = nexts.get(candidate, [])
            possible = [x for x in neighbours if x not in sequence]
            New_candidates = best_candidates(nexts, possible, sequence)
            sequence.insert(0, candidate)
            graphs.insert(0, New_candidates)
    if (len(sequence) == N):
        return (True, sequence)
    else:
        return (False, [])

def run(x):
    """
    Computes a valid segment for N
    """
    t0 = round(time.time()*1000)
    numbers = list(range(1, x+1))
    squares = gen_squares(x)
    nexts = gen_nexts(x, numbers, squares)
    t1 = round(time.time()*1000)
    (found, result) = find_sequence(x, numbers, nexts)
    t2 = round(time.time()*1000)
    print (x, t1-t0, t2-t1, result, sep=';')
    return result

# Main loop : compute sequence for N if given, otherwise computes from 7

if Max == 0:
    x=7
    while True:
        run(x)
        x = x + 1
else:
    run(Max)

