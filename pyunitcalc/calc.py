#!/usr/bin/python

from CalcException import CalcException
import cgi
import Parser
import sys

sys.stderr = sys.stdout

print "Content-Type: text/plain"
print ""

form = cgi.FieldStorage()
if not form.has_key("expression"):
    print "No input found"
else:
    expr = form["expression"].value
    try:
        parser = Parser.Parser(expr)
        parser.parse()
        print parser.calc()
    except CalcException, inst:
        print "error:", inst

