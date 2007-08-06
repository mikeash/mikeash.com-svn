
class Number:
    def __init__(self, str):
        self.value = int(str)
        self.units = {}
    
    def __str__(self):
        topList = []
        botList = []
        for unit in self.units:
            exponent = abs(self.units[unit])
            if exponent > 1:
                s = "%s^%s" % (unit, exponent)
            else:
                s = unit
            if self.units[unit] > 0:
                topList.append(s)
            else:
                botList.append(s)
        
        list = [str(self.value)]
        list.extend(topList)
        if len(botList) > 0:
            list.append('/')
            list.extend(botList)
        return " ".join(list)
    
    def isNumber(self):
        return True
    
    def addUnit(self, unit):
        self.addUnitCount(unit, 1)
    
    def addUnitCount(self, unit, count):
        if not self.units.has_key(unit):
            self.units[unit] = 0
        self.units[unit] = self.units[unit] + count
    
    def addUnits(self, units):
        for unit in units:
            self.addUnitCount(unit, units[unit])
        self.reduceUnits()
    
    def subtractUnits(self, units):
        inverseUnits = {}
        for unit in units:
            inverseUnits[unit] = -units[unit]
        self.addUnits(inverseUnits)
    
    def reduceUnits(self):
        for unit in self.units.keys():
            if self.units[unit] == 0:
                del self.units[unit]
    
    def checkCompatibleUnits(self, other):
        if not self.units == other.units:
            print "incompatible units!!!"
    
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
        n = Number(res)
        if op == '+' or op == '-':
            self.checkCompatibleUnits(other)
            n.addUnits(self.units)
        elif op == '*':
            n.addUnits(self.units)
            n.addUnits(other.units)
        elif op == '/':
            n.addUnits(self.units)
            n.subtractUnits(other.units)
        return n
            


