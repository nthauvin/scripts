 #!/usr/bin/python

import sys
import math

if (len(sys.argv) < 2):
    print ("Missing sequence size")
    exit(1)

Max = int(sys.argv[1])
Candidates = list(range(1,Max+1))

def solve (sequence, remaining, candidate_index):
    if (candidate_index >= len(remaining)):
        return []
    else:
        last = sequence[-1]
        candidate = remaining[candidate_index]
        if math.sqrt(last + candidate).is_integer():
            sequence_candidate = sequence + [candidate]
            if (len(sequence_candidate) == Max) :
                return [sequence_candidate]
            else:
                remaining_candidate = [x for x in remaining if x != candidate]
                branch = solve(sequence_candidate, remaining_candidate, 0)
                next_branch = solve(sequence, remaining, candidate_index+1)
                return branch + next_branch
        else:
            return solve(sequence, remaining, candidate_index+1)

results = []
for start in Candidates:
    remaining = [x for x in Candidates if x != start]
    results = results + solve([start], remaining, 0)

[print(x) for x in results]
