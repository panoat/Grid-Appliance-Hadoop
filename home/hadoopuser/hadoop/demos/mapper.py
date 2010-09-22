#!/usr/bin/env python

"""Figure out whether each number is even or odd."""

import sys


for line in sys.stdin:
    num, _ignored = line[:-1].split("\t")
    is_odd = int(num) % 2
    print "%s\t%s" % (is_odd, num)
