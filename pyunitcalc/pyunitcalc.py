#!/usr/bin/python

import DebugPrint
import StringIO
import sys

from CalcException import CalcException
import Parser

def calc(str):
    parser = Parser.Parser(str)
    parser.parse()
    return parser.calc()

DebugPrint.enable()

if len(sys.argv) < 2:
    input = sys.stdin
else:
    input = StringIO.StringIO('\n'.join(sys.argv[1:]))

while True:
    str = input.readline()
    if not str:
        break
    str = str.strip()
    if str:
        try:
            print calc(str)
        except CalcException, inst:
            print "error:", inst

