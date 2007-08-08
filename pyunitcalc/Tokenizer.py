
import re

class Tokenizer:
    def __init__(self, str):
        self.str = str
        self.stack = []
        self.regexes = [
            re.compile("[-+]?[0-9]+\\.?[0-9]*"), # number
            re.compile("[-+]?[0-9]*\\.?[0-9]+"), # number with leading .
            re.compile("[a-zA-Z]+([a-zA-Z ]+[a-zA-Z])*"), # unit
            re.compile(".") # catchall
        ]
    
    def nextToken(self):
        if self.stack:
            return self.stack.pop()
        self.str = self.str.strip()
        for r in self.regexes:
            match = r.match(self.str)
            if match:
                ret = match.group()
                self.str = self.str[len(ret):]
                return ret
        return None
    
    def pushBack(self, token):
        self.stack.append(token)
    
    def peek(self):
        t = self.nextToken()
        self.pushBack(t)
        return t
