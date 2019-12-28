# The Square Sum Problem

https://oeis.org/A090461

https://www.youtube.com/watch?v=G1m7goLCJDY

https://www.youtube.com/watch?v=7_ph5djCCnM

http://mersenneforum.org/showthread.php?p=477787

**Find a permutation of the integers 1 to N so that the sum of adjacent numbers is a square.**

Here are a few solutions using different languages, including relative times for N = 30 and N = 3000

| Language | File             | Comment | Time for N = 30 | Time for N = 3000 |
| ---      | ---              | ---     | ---             | ---               |
| Erlang   | sqrt_sum.digraph.escript | Using digraph module to handle vertives/edges (thanks Art) | 0.16s | 1.9s |
| Erlang   | sqrt_sum.escript | less neighbours first + concurrency | 0.16s | 14.7s |
| Python   | sqrt_sum4.py     | less neighbours first + without recursion | 0.12s | 22.3s |
| Python   | sqrt_sum2.py     | valid sums hash table (same issue, and pretty slow) | 2.3s | Kaboum |
| Python   | sqrt_sum.py      | "brute force" recursive version (hits Python max recursion threshold pretty quickly) | 8.7s | Kaboum   |
| Prolog   | sqrt_sum.pl      | Naive Prolog version (enter `solve(30,X).` in shell) | 15s | Kaboum |
