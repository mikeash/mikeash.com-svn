
import re

class Tokenizer:
    def __init__(self, str):
        self.str = str
        self.regexes = [
            re.compile("[-+]?[0-9]+\\.?[0-9]*"), # number
            re.compile("[-+]?[0-9]*\\.?[0-9]+"), # number with leading .
            re.compile("[a-zA-Z]+(^[1-9][0-9]*)?"), # unit
            re.compile(".") # catchall
        ]
    
    def nextToken(self):
        self.str = self.str.strip()
        for r in self.regexes:
            match = r.match(self.str)
            if match:
                ret = match.group()
                self.str = self.str[len(ret):]
                return ret
        return None
