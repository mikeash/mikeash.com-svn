

debugPrintEnabled = False

def enable():
    global debugPrintEnabled
    debugPrintEnabled = True

def debugPrint(str):
    if debugPrintEnabled:
        print str
