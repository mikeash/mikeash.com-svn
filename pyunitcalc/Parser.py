
import Tokenizer

class Parser:
    def __init__(self, str):
        self.tokenizer = Tokenizer.Tokenizer(str)
    
    def parse(self):
        self.str = ""
        while 1:
            t = self.tokenizer.nextToken()
            if t == None:
                break
            self.str += t[1]
    
    def calc(self):
        return self.str
