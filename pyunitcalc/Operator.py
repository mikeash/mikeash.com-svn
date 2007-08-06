
class Operator:
    def __init__(self, str):
        self.operator = str
    
    def __str__(self):
        return self.operator
    
    def precedence(self):
        return { '(':-1,
                 '+':1,
        		 '-':1,
        		 '*':2,
        		 '/':2 }[self.operator]
    
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
            if self.precedence() > top.precedence():
                infixStack.append(self)
            else:
                postfixStack.append(infixStack.pop())
                self.process(infixStack, postfixStack)
    
    def calc(self, stack):
        val2 = stack.pop()
        val1 = stack.pop()
        stack.append(val1.eval(self.operator, val2))


