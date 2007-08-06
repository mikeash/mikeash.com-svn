
class Number:
    def __init__(self, str):
        self.value = int(str)
    
    def __str__(self):
        return str(self.value)
    
    def process(self, infixStack, postfixStack):
        postfixStack.append(self)
    
    def calc(self, stack):
        stack.append(self)
    
    def eval(self, op, other):
        a = self.value
        b = other.value
        res = None
        if op == '+':
            res = a + b
        elif op == '-':
            res = a - b
        elif op == '*':
            res = a * b
        elif op == '/':
            res = a / b
        return Number(res)


