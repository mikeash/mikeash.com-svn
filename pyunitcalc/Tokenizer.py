
import tokenize
import StringIO

class Tokenizer:
    def __init__(self, str):
        self.generator = tokenize.generate_tokens(StringIO.StringIO(str).readline)
    
    def nextToken(self):
        try:
            return self.generator.next()
        except StopIteration:
            return None
