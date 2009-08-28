#!/usr/bin/python

from Foundation import *
import sys


mainBrowser = NSNetServiceBrowser.alloc().init()

class NetServiceDelegate(NSObject):
    def init(self):
        self = super(NetServiceDelegate, self).init()
        self._resolvingServices = []
        self._subBrowsers = {}
        self._hostnameAddresses = {}
        self._hostnameTypes = {}
        return self
    
    def dummy_(self, timer):
        pass
    
    def netServiceBrowser_didFindService_moreComing_(self, browser, service, moreComing):
        if browser == mainBrowser:
            self._makeSubbrowser(service)
        else:
            service.setDelegate_(self)
            service.resolveWithTimeout_(5.0)
            self._resolvingServices.append(service)
    
    def _makeSubbrowser(self, service):
        type = service.type()
        name = service.name()
        identifier = (type, name)
        if identifier not in self._subBrowsers:
            components = type.split('.')
            if len(components) >= 2:
                searchType = name + '.' + components[0] + '.'
                searchDomain = components[1] + '.'
                subBrowser = NSNetServiceBrowser.alloc().init()
                subBrowser.setDelegate_(self)
                subBrowser.searchForServicesOfType_inDomain_(searchType, searchDomain)
                self._subBrowsers[identifier] = subBrowser
    
    def netServiceDidResolveAddress_(self, service):
        hostname = service.hostName()
        if hostname not in self._hostnameTypes:
            self._hostnameTypes[hostname] = []
        self._hostnameTypes[hostname].append(service.type())
        
        if hostname not in self._hostnameAddresses:
            self._hostnameAddresses[hostname] = []
        addresses = [x[0] for x in service.addresses()]
        for addr in addresses:
            if addr not in self._hostnameAddresses[hostname]:
                self._hostnameAddresses[hostname].append(addr)
    
    def printAndExit_(self, timer):
        groups = []
        for hostname in sorted(self._hostnameAddresses.keys()):
            lines = []
            
            lines.append('%s - %s' % (hostname, ', '.join(sorted(self._hostnameAddresses[hostname]))))
            for type in sorted(self._hostnameTypes[hostname]):
                lines.append('\t' + type)
            groups.append('\n'.join(lines))
        print ('\n' + '=' * 30 + '\n').join(groups)
        sys.exit(0)


delegate = NetServiceDelegate.alloc().init()
mainBrowser.setDelegate_(delegate)
mainBrowser.searchForServicesOfType_inDomain_('_services._dns-sd._udp.', '')

# stupid workaround to let ^C actually kill the script, which doesn't
# work when we're blocked in Foundation
NSTimer.scheduledTimerWithTimeInterval_target_selector_userInfo_repeats_(0.5, delegate, 'dummy:', None, True)

NSTimer.scheduledTimerWithTimeInterval_target_selector_userInfo_repeats_(5.0, delegate, 'printAndExit:', None, True)

NSRunLoop.currentRunLoop().run()
