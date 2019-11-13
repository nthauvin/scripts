#!/usr/bin/env python3

import sys
import math

if (len(sys.argv) < 2):
    print ("Missing sequence size")
    exit(1)

Max = int(sys.argv[1])
Candidates = list(range(1,Max+1))

# List of reachable squares. Worst case: (N-1) + (N)
Squares = set([])
i = 1
while i*i <= Max + Max - 1 :
    Squares.add(i*i);
    i = i +1

# Dict of possible next numbers after first
Next = dict()
for i in Candidates :
    for j in [x for x in Candidates if x!=i]:
        if i+j in Squares:
            Next[i] = Next.get(i, []) + [j]

def solve(sequence):
    if (len(sequence) == Max):
        return [sequence.copy()]
    last = sequence[-1]
    candidates = [c for c in Next[last] if c not in sequence]
    sequences = []
    for c in candidates:
        sequences = sequences + solve(sequence + [c])
    return [x for x in sequences if len(x) == Max]

results = []
for start in Candidates:
    results = results + solve([start])

[print(r) for r in results]
