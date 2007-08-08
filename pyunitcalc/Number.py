
from CalcException import CalcException
import Units

class Number:
    def __init__(self, str):
        self.value = float(str)
        self.units = {}
    
    def __str__(self):
        topList = []
        botList = []
        for unit in self.units:
            exponent = abs(self.units[unit])
            if exponent > 1:
                s = "%s^%s " % (unit, exponent)
            else:
                s = str(unit)
            if self.units[unit] > 0:
                topList.append(s)
            elif self.units[unit] < 0:
                botList.append(s)
            else:
                raise Exception("unit count for %s is 0" % unit)
        
        s = "".join(topList)
        if len(botList) > 0:
            s = s.strip() + '/'
            s += "".join(botList)
        return str(self.value) + s
    
    def isNumber(self):
        return True
    
    def addUnitStr(self, unitStr):
        units = Units.parseUnits(unitStr)
        for unit in units:
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
    
    def makeBaseUnits(self):
        changed = False
        for unit in self.units.keys():
            base = unit.baseUnits
            if base != None:
                changed = True
                count = self.units[unit]
                del self.units[unit]
                self.addBaseUnits(base, unit.baseQuantity, count)
                break
        if changed:
            self.makeBaseUnits()
        return changed
    
    def addBaseUnits(self, base, baseQuantity, count):
        self.value *= baseQuantity ** count
        for baseStr in base:
            self.addUnitCount(Units.getBaseUnit(baseStr), base[baseStr] * count)
        self.reduceUnits()
    
    def checkCompatibleUnits(self, other):
        if not self.units == other.units:
            if self.makeBaseUnits() or other.makeBaseUnits():
                self.checkCompatibleUnits(other)
            else:
                raise CalcException("incompatible units in %s and %s" % (self, other))
    
    def process(self, infixStack, postfixStack):
        postfixStack.append(self)
    
    def calc(self, stack):
        stack.append(self)
    
    def eval(self, op, other):
        if op == '+' or op == '-':
            self.checkCompatibleUnits(other)
            a = self.value
            b = other.value
            if op == '+':
                n = Number(a + b)
            elif op == '-':
                n = Number(a - b)
            n.addUnits(self.units)
        else:
            a = self.value
            b = other.value
            if op == '*':
                n = Number(a * b)
                n.addUnits(self.units)
                n.addUnits(other.units)
                n.makeBaseUnits()
            elif op == '/':
                n = Number(a / b)
                n.addUnits(self.units)
                n.subtractUnits(other.units)
                n.makeBaseUnits()
        return n
            


