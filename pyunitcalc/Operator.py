
from CalcException import CalcException

precedencesList = [
    ('(', ')'),
    ('+', '-'),
    '-unary',
    ('*', '/'),
    ('*unit', '/unit'),
    '^'
]

i = 0
precedences = {}
for x in precedencesList:
    if type(x) != tuple:
        x = (x, )
    for op in x:
        precedences[op] = i
    i += 1

class Operator:
    def __init__(self, str, precedence = None):
        self.operator = str
        if not precedences.has_key(str):
            raise CalcException("unknown operator %s" % str)
        if not precedence:
            precedence = precedences[self.operator]
        self.precedence = precedence
        
    def __str__(self):
        return self.operator
    
    def isNumber(self):
        return False
    
    def process(self, infixStack, postfixStack):
        if self.operator == '(':
            infixStack.append(self)
        elif self.operator == ')':
            while infixStack[-1].operator != '(':
                postfixStack.append(infixStack.pop())
            infixStack.pop()
        elif len(infixStack) == 0:
            infixStack.append(self)
        else:
            top = infixStack[-1]
            if self.precedence > top.precedence:
                infixStack.append(self)
            else:
                postfixStack.append(infixStack.pop())
                self.process(infixStack, postfixStack)
    
    def calc(self, stack):
        val2 = stack.pop()
        val1 = stack.pop()
        stack.append(val1.eval(self.operator, val2))

def unitMultiplyOperator():
    return Operator('*', precedences['*unit'])

def unitDivideOperator():
    return Operator('/', precedences['/unit'])

def unaryMinusOperator():
    return Operator('-', precedences['-unary'])
