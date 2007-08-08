
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
    
    def __str__(self):
        return self.shortname
    
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
	Unit('s', 'second'),
	Unit('g', 'gram')
]

derivedUnits = [
    Unit('N', 'newton', 1, {'kilo':1, 'gram':1, 'meter':1, 'second':-2}),
    Unit('J', 'joule', 1, {'newton':1, 'meter':1}),
    Unit('W', 'watt', 1, {'joule':1, 'second':-1}),
    
    Unit('min', 'minute', 60, {'second':1}),
    Unit('h', 'hour', 3600, {'second':1}),
    
    Unit('ft', 'foot', 0.3048, {'meter':1}),
    Unit('lb', 'pound', 0.45359237, {'kilo':1, 'gram':1}),
    
    Unit(None, 'speed of light', 299792458, {'meter':1, 'second':-1}),
    Unit('au', 'astronomical unit', 149598000000, {'meter':1})
]

prefixes = [
    Unit('k', 'kilo', 1000),
    Unit('m', 'milli', 0.001),
]

def buildUnitDict(list):
    dict = {}
    for u in list:
        dict[u.shortname] = u
        dict[u.longname] = u
    return dict

units = buildUnitDict(baseUnits + derivedUnits)
prefixes = buildUnitDict(prefixes)

