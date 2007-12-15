#!/usr/bin/env python

import DebugPrint
import readline
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
    readfun = raw_input
else:
    readfun = StringIO.StringIO('\n'.join(sys.argv[1:])).readline

while True:
    str = readfun()
    if not str:
        break
    str = str.strip()
    if str:
        try:
            print calc(str)
        except CalcException, inst:
            print "error:", inst

