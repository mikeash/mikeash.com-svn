#!/usr/bin/python

import sys

from CalcException import CalcException
import Parser

def calc(str):
    parser = Parser.Parser(str)
    parser.parse()
    return parser.calc()

if len(sys.argv) < 2:
    print "please supply an argument"
else:
    try:
        print calc(sys.argv[1])
    except CalcException, inst:
        print "error:", inst

