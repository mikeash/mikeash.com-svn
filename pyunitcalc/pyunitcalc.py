#!/usr/bin/python

import sys
import Parser

def calc(str):
    parser = Parser.Parser(str)
    parser.parse()
    return parser.calc()

if len(sys.argv) < 2:
    print "please supply an argument"
else:
    print calc(sys.argv[1])
