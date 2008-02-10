#!/usr/bin/python

import unittest

from CalcException import CalcException
import Parser

class TestParser(unittest.TestCase):
    def calc(self, s):
        parser = Parser.Parser(s)
        parser.parse()
        return str(parser.calc())
    
    def _testTuples(self, tuples):
        for t in tuples:
            try:
                self.assertEqual(self.calc(t[0]), t[1])
            except Exception, inst:
                print "error in %s, expected %s, got exception: %s" % (t[0], t[1], inst)
                raise inst
    
    def testOperators(self):
        tests = [('2+3', '5.0'), ('2-3', '-1.0'),
                 ('3*4', '12.0'), ('10/4', '2.5'),
                 ('2^8', '256.0')]
        self._testTuples(tests)
    
    def testPrecedence(self):
        tests = [('2+3*4', '14.0'),
                 ('(2+3)*4', '20.0'),
                 ('2+3-4+5-6', '0.0'),
                 ('2^3*4', '32.0'),
                 ('-2^2', '-4.0')]
        self._testTuples(tests)
    
    def testConstants(self):
        tests = [('speed of light', '299792458.0m/s'),
                 ('e', '2.71828183'),
                 ('pi', '3.14159265359')]
        self._testTuples(tests)
    
    def testUnits(self):
        tests = [('1inch^3 in L', '0.016387064L'),
                 ('1ft + 1m', '1.3048m'),
                 ('1mbps * 1 day', '10800000000.0B'),
                 ('10kt * 1', '10.0kt'),
                 ('10kt + 0m/s', '5.14444444444m/s'),
                 ('1*10^9ugm/s^2 in N', '1.0N'),
                 ('1*10^9ugm/s^2 to N', '1.0N')]
        self._testTuples(tests)
    
    def testUnitPlurals(self):
        tests = [('12 inches in feet', '1.0feet'),
                 ('120 miles / 2 hours in MPH', '60.0MPH'),
                 ('1 calorie in joules', '4.184J')]
        self._testTuples(tests)
    
    def testReciprocalConversions(self):
        tests = [('1 hour/1 mile in mph', '1.0mph'),
                 ('1 hour/60 mile in mph', '60.0mph'),
                 ('2 days/gallon in mL/s', '0.0219063183158mL/s')]
        self._testTuples(tests)

unittest.main()