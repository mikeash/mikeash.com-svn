
import Tokenizer
import Number
import Operator

import re


class Parser:
    def __init__(self, str):
        self.tokenizer = Tokenizer.Tokenizer(str)
        
        self.kOperator = "operator"
        self.kNumber = "number"
        
        self.regexes = {
            re.compile("[-+\\*/]"):self.parseOperator,
            re.compile("[-+]?[0-9]+\\.?[0-9]*"):self.parseNumber,
            re.compile("[-+]?[0-9]*\\.?[0-9]+"):self.parseNumber
        }
            
    
    def nextToken(self):
        return self.tokenizer.nextToken()
    
    def parse(self):
        self.postfixStack = []
        self.infixStack = []
        while self.parseNextToken():
            pass
        while len(self.infixStack) > 0:
            self.postfixStack.append(self.infixStack.pop())
    
    def parseNextToken(self):
        t = self.nextToken()
        if t == None:
            return False
        
        print "parsing", t
        if len(t) < 1:
            print "empty token!"
        for r in self.regexes:
            if r.match(t):
                value = self.regexes[r](t)
                value.process(self.infixStack, self.postfixStack)
                return True
        print "unknown token %s" % t
        return False
    
    def parseNumber(self, t):
        return Number.Number(t)
    
    def parseOperator(self, t):
        return Operator.Operator(t)
    
    def calc(self):
        print [x.__str__() for x in self.postfixStack]
        finalStack = []
        for x in self.postfixStack:
            x.calc(finalStack)
        return finalStack[0]
