#!/usr/bin/env python

"""Count and sum the even and odd numbers."""

import sys


counts = {0: 0, 1: 0}
sums = counts.copy()
for line in sys.stdin:
    is_odd, num = map(int, line[:-1].split("\t"))
    counts[is_odd] += 1
    sums[is_odd] += num
for i in range(2):
    name = {0: "even", 1: "odd"}[i]
    print "%s\tcount:%s sum:%s" % (name, counts[i], sums[i])
