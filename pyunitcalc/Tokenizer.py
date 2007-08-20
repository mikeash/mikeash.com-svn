
import re

class Tokenizer:
    def __init__(self, str):
        self.str = str
        self.stack = []
        self.regexes = [
            re.compile("[0-9]+\\.?[0-9]*"), # number
            re.compile("[0-9]*\\.?[0-9]+"), # number with leading .
            re.compile("[a-zA-Z]+([a-zA-Z ]+[a-zA-Z])*"), # unit
            re.compile(".") # catchall
        ]
        keywords = ['in', 'to']
        self.keywordRegexes = re.compile("(^| )(" + "|".join(keywords) + ")($| )")
    
    def nextToken(self):
        if self.stack:
            return self.stack.pop()
        self.str = self.str.strip()
        for r in self.regexes:
            match = r.match(self.str)
            if match:
                ret = match.group()
                self.str = self.str[len(ret):]
                self.pushTokensInString(ret)
                return self.stack.pop()
        return None
    
    def pushTokensInString(self, s):
        components = self.keywordRegexes.split(s)
        components.reverse()
        components = [x.strip() for x in components]
        components = filter(lambda x: len(x) > 0, components)
        self.stack.extend(components)
    
    def pushBack(self, token):
        self.stack.append(token)
    
    def peek(self):
        t = self.nextToken()
        self.pushBack(t)
        return t
