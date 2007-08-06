
import tokenize
import StringIO

class Tokenizer:
    def __init__(self, str):
        self.generator = tokenize.generate_tokens(StringIO.StringIO(str).readline)
        self.isAtEnd = False
    
    def nextToken(self):
        try:
            return self.generator.next()[1]
        except StopIteration:
            self.isAtEnd = True
            return None
    
    def hasTokens(self):
        return not self.isAtEnd
