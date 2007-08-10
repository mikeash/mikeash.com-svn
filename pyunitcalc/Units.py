
from CalcException import CalcException

class Unit:
    def __init__(self, shortname, longname, baseQuantity = None, baseUnits = None):
        # if two parameters are provided then you get a baseQuantity
        # of 1 and a baseUnits of None, to indicate a base unit
        # if three parameters are provided then you get a baseUnits
        # of {} to indicate a prefix
        # if four parameters are provided it indicates a composite unit
        if not shortname:
            shortname = longname
        self.shortname = shortname
        self.longname = longname
        if baseQuantity == None:
            self.baseQuantity = 1
            self.baseUnits = None
        else:
            self.baseQuantity = baseQuantity
            if baseUnits == None:
                self.baseUnits = {}
            else:
                self.baseUnits = baseUnits
        self.shouldDeriveImmediately = False
        self.isPrefix = False
    
    def __str__(self):
        return self.shortname
    
    def __cmp__(self, other):
        if self.__class__ != other.__class__:
            return -1
        if self.isPrefix and not other.isPrefix:
            return -1
        elif not self.isPrefix and other.isPrefix:
            return 1
        else:
            return cmp(self.longname, other.longname)
    
    def __hash__(self):
        return hash(self.longname)
    
    def setShouldDeriveImmediately(self):
        self.shouldDeriveImmediately = True
    
    def setIsPrefix(self):
        self.isPrefix = True
    
def get(str):
    if units.has_key(str):
        return units[str]
    else:
        raise CalcException("unknown unit %s" % str)

def parseUnits(str):
    str = str.strip()
    for l in range(len(str), 0, -1):
        unit = None
        substr = str[:l]
        if l < len(str) and prefixes.has_key(substr):
            unit = prefixes[substr]
        elif units.has_key(substr):
            unit = units[substr]
        elif constants.has_key(substr):
            unit = constants[substr]
        if unit != None:
            if l == len(str):
                return [unit]
            else:
                return [unit] + parseUnits(str[l:])
    raise CalcException("unknown unit %s" % str)

def getBaseUnit(str):
    if prefixes.has_key(str):
        return prefixes[str]
    elif units.has_key(str):
        return units[str]
    else:
        raise CalcException("unknown unit %s" % str)

baseUnits = [
	Unit('m', 'meter'),
	Unit('g', 'gram'),
	Unit('s', 'second'),
	Unit('A', 'ampere'),
	Unit('K', 'kelvin'),
	
	Unit('B', 'byte'),
	Unit('USD', 'dollar'),
]

derivedUnits = [
    Unit('N', 'newton', 1, {'kilo':1, 'gram':1, 'meter':1, 'second':-2}),
    Unit('J', 'joule', 1, {'newton':1, 'meter':1}),
    Unit('W', 'watt', 1, {'joule':1, 'second':-1}),
    Unit('Pa', 'pascal', 1, {'newton':1, 'meter':-2}),
    Unit('C', 'coulomb', 1, {'ampere':1, 'second':1}),
    Unit('V', 'volt', 1, {'watt':1, 'ampere':-1}),
    Unit('F', 'farad', 1, {'coulomb':1, 'volt':-1}),
    Unit(None, 'ohm', 1, {'volt':1, 'ampere':-1}),
    Unit('S', 'siemens', 1, {'ampere':1, 'volt':-1}),
    Unit('Wb', 'weber', 1, {'volt':1, 'second':1}),
    Unit('T', 'tesla', 1, {'weber':1, 'meter':-2}),
    Unit('H', 'henry', 1, {'weber':1, 'ampere':-1}),
    Unit('L', 'liter', 0.001, {'meter':3}),
    
    Unit('t', 'tonne', 1000000, {'gram':1}),
    
    Unit('min', 'minute', 60, {'second':1}),
    Unit('h', 'hour', 3600, {'second':1}),
    Unit(None, 'day', 24, {'hour':1}),
    Unit(None, 'month', 30.4368499, {'day':1}),
    Unit(None, 'year', 365.242199, {'day':1}),
    
    Unit('Hz', 'hertz', 1, {'second':-1}),
    
    Unit(None, 'angstrom', 0.1, {'nano':1, 'meter':1}),
    Unit('in', 'inch', 0.0254, {'meter':1}),
    Unit('ft', 'foot', 0.3048, {'meter':1}),
    Unit('yd', 'yard', 3, {'foot':1}),
    Unit(None, 'fathom', 6, {'foot':1}),
    Unit('rd', 'rod', 16.5, {'foot':1}),
    Unit('fur', 'furlong', 40, {'rod':1}),
    Unit(None, 'mile', 5280, {'foot':1}),
    Unit('nmile', 'nautical mile', 1852, {'meter':1}),
    
    Unit(None, 'acre', 43560, {'foot':2}),
    Unit(None, 'section', 1, {'mile':2}),
    Unit(None, 'township', 6, {'mile':2}),
    
    Unit('lb', 'pound', 0.45359237, {'kilo':1, 'gram':1}),
    Unit(None, 'stone', 14, {'pound':1}),
    Unit(None, 'ton', 2000, {'pound':1}),
    
    Unit('floz', 'fluid ounce', 1.80468751, {'inch':3}),
    Unit('gi', 'gill', 4, {'fluid ounce':1}),
    Unit(None, 'cup', 8, {'fluid ounce':1}),
    Unit('pt', 'pint', 28.875, {'inch':3}),
    Unit('qt', 'quart', 57.75, {'inch':3}),
    Unit('gal', 'gallon', 231.00000127999999, {'inch':3}),
    
    Unit('kt', 'knot', 1, {'nautical mile':1, 'hour':-1}),
    
    Unit('b', 'bit', 0.125, {'byte':1}),
    Unit('bps', 'bit per second', 1, {'bit':1, 'second':-1}),
    Unit('Bps', 'byte per second', 1, {'byte':1, 'second':-1}),
    Unit('mbps', 'megabit per second', 1000000, {'bit':1, 'second':-1}),
    Unit('mBps', 'megabyte per second', 1000000, {'byte':1, 'second':-1}),
    
    Unit(None, 'hamburger', 15000, {'g':1, 'day':1}),
]

constants = [
    Unit(None, 'speed of light', 299792458, {'meter':1, 'second':-1}),
    Unit('au', 'astronomical unit', 149598000000, {'meter':1}),
    
    Unit('e', 'euler number', 2.71828183),
    Unit(None, 'pi', 3.1415926535897932384626),
    
    Unit('ramius', 'RamiusJMoose', 532.7, {'pound':1}),
]

prefixes = [
    Unit('T', 'tera', 1000000000000),
    Unit('G', 'giga', 1000000000),
    Unit('M', 'mega', 1000000),
    Unit('k', 'kilo', 1000),
    Unit('h', 'hecto', 100),
    Unit('da', 'deka', 10),
    Unit('d', 'deci', 0.1),
    Unit('c', 'centi', 0.01),
    Unit('m', 'milli', 0.001),
    Unit('u', 'micro', 0.000001),
    Unit('n', 'nano', 0.000000001),
]

def buildUnitDict(list):
    dict = {}
    for u in list:
        dict[u.shortname] = u
        dict[u.longname] = u
    return dict

units = buildUnitDict(baseUnits + derivedUnits)

for c in constants: c.setShouldDeriveImmediately()
constants = buildUnitDict(constants)

for p in prefixes: p.setIsPrefix()
prefixes = buildUnitDict(prefixes)

