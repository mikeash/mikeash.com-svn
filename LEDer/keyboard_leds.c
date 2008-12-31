// taken from http://osxbook.com/book/bonus/chapter10/kbdleds/download/keyboard_leds.c
// linked from http://googlemac.blogspot.com/2008/04/manipulating-keyboard-leds-through.html

/*
 * keyboard_leds.c
 * Manipulate keyboard LEDs (capslock and numlock) programmatically.
 *
 * gcc -Wall -o keyboard_leds keyboard_leds.c -framework IOKit
 *     -framework CoreFoundation
 *
 * Copyright (c) 2007,2008 Amit Singh. All Rights Reserved.
 *
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions
 *  are met:
 *  1. Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *  2. Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 *     
 *  THIS SOFTWARE IS PROVIDED BY AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 *  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 *  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 *  ARE DISCLAIMED.  IN NO EVENT SHALL AUTHOR OR CONTRIBUTORS BE LIABLE
 *  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 *  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 *  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 *  HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 *  LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 *  OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 *  SUCH DAMAGE.
 */

#define PROGNAME "keyboard_leds"
#define PROGVERS "0.1"

#include <stdio.h>
#include <getopt.h>
#include <stdlib.h>
#include <sysexits.h>
#include <mach/mach_error.h>

#include <IOKit/IOCFPlugIn.h>
#include <IOKit/hid/IOHIDLib.h>
#include <IOKit/hid/IOHIDUsageTables.h>

static IOHIDElementCookie capslock_cookie = (IOHIDElementCookie)0;
static IOHIDElementCookie numlock_cookie  = (IOHIDElementCookie)0;

void         usage(void);
void  print_errmsg_if_io_err(int expr, char* msg);
void  print_errmsg_if_err(int expr, char* msg);

io_service_t find_a_keyboard(void);
void         find_led_cookies(IOHIDDeviceInterface122** handle);
void         create_hid_interface(io_object_t hidDevice,
                                  IOHIDDeviceInterface*** hdi);

void
usage(void)
{
    fprintf(stderr, "%s (version %s)\n"
			"Copyright (c) 2007,2008 Amit Singh. All Rights Reserved.\n"
			"Manipulate keyboard LEDs\n\n"
			"Usage: %s [OPTIONS...], where OPTIONS is one of the following\n\n"
			"  -c[1|0], --capslock[=1|=0] get or set (on=1, off=0) caps lock LED\n"
			"  -h,      --help            print this help message and exit\n"
			"  -n[1|0], --numlock[=1|=0]  get or set (on=1, off=0) num lock LED\n",
			PROGNAME, PROGVERS, PROGNAME);
}

void
print_errmsg_if_io_err(int expr, char* msg)
{
    IOReturn err = (expr);
	
    if (err != kIOReturnSuccess) {
        fprintf(stderr, "*** %s - %s(%x, %d).\n", msg, mach_error_string(err),
                err, err & 0xffffff);
        fflush(stderr);
        exit(EX_OSERR);
    }
}

void
print_errmsg_if_err(int expr, char* msg)
{
    if (expr) {
        fprintf(stderr, "*** %s.\n", msg);
        fflush(stderr);
        exit(EX_OSERR);
    }
}

io_service_t
find_a_keyboard(void)
{
    io_service_t result = (io_service_t)0;
	
    CFNumberRef usagePageRef = (CFNumberRef)0;
    CFNumberRef usageRef = (CFNumberRef)0;
    CFMutableDictionaryRef matchingDictRef = (CFMutableDictionaryRef)0;
	
    if (!(matchingDictRef = IOServiceMatching(kIOHIDDeviceKey))) {
        return result;
    }
	
    UInt32 usagePage = kHIDPage_GenericDesktop;
    UInt32 usage = kHIDUsage_GD_Keyboard;
	
    if (!(usagePageRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType,
                                        &usagePage))) {
        goto out;
    }
	
    if (!(usageRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType,
                                    &usage))) {
        goto out;
    }
	
    CFDictionarySetValue(matchingDictRef, CFSTR(kIOHIDPrimaryUsagePageKey),
                         usagePageRef);
    CFDictionarySetValue(matchingDictRef, CFSTR(kIOHIDPrimaryUsageKey),
                         usageRef);
	
    result = IOServiceGetMatchingService(kIOMasterPortDefault, matchingDictRef);
	
out:
    if (usageRef) {
        CFRelease(usageRef);
    }
    if (usagePageRef) {
        CFRelease(usagePageRef);
    }
	
    return result;
}

void
find_led_cookies(IOHIDDeviceInterface122** handle)
{
    IOHIDElementCookie cookie;
    CFTypeRef          object;
    long               number;
    long               usage;
    long               usagePage;
    CFArrayRef         elements;
    CFDictionaryRef    element;
    IOReturn           result;
	
    if (!handle || !(*handle)) {
        return;
    }
	
    result = (*handle)->copyMatchingElements(handle, NULL, &elements);
	
    if (result != kIOReturnSuccess) {
        fprintf(stderr, "Failed to copy cookies.\n");
        exit(1);
    }
	
    CFIndex i;
	
    for (i = 0; i < CFArrayGetCount(elements); i++) {
		
        element = CFArrayGetValueAtIndex(elements, i);
		
        object = (CFDictionaryGetValue(element, CFSTR(kIOHIDElementCookieKey)));
        if (object == 0 || CFGetTypeID(object) != CFNumberGetTypeID()) {
            continue;
        }
        if (!CFNumberGetValue((CFNumberRef) object, kCFNumberLongType,
                              &number)) {
            continue;
        }
        cookie = (IOHIDElementCookie)number;
		
        object = CFDictionaryGetValue(element, CFSTR(kIOHIDElementUsageKey));
        if (object == 0 || CFGetTypeID(object) != CFNumberGetTypeID()) {
            continue;
        }
        if (!CFNumberGetValue((CFNumberRef)object, kCFNumberLongType,
                              &number)) {
            continue;
        }
        usage = number;
		
        object = CFDictionaryGetValue(element,CFSTR(kIOHIDElementUsagePageKey));
        if (object == 0 || CFGetTypeID(object) != CFNumberGetTypeID()) {
            continue;
        }
        if (!CFNumberGetValue((CFNumberRef)object, kCFNumberLongType,
                              &number)) {
            continue;
        }
        usagePage = number;
		
        if (usagePage == kHIDPage_LEDs) {
            switch (usage) {
					
				case kHIDUsage_LED_NumLock:
					numlock_cookie = cookie;
					break;
					
				case kHIDUsage_LED_CapsLock:
					capslock_cookie = cookie;
					break;
					
				default:
					break;
            }
        }
    }
	
    return;
}

void
create_hid_interface(io_object_t hidDevice, IOHIDDeviceInterface*** hdi)
{
    IOCFPlugInInterface** plugInInterface = NULL;
	
    io_name_t className;
    HRESULT   plugInResult = S_OK;
    SInt32    score = 0;
    IOReturn  ioReturnValue = kIOReturnSuccess;
	
    ioReturnValue = IOObjectGetClass(hidDevice, className);
	
    print_errmsg_if_io_err(ioReturnValue, "Failed to get class name.");
	
    ioReturnValue = IOCreatePlugInInterfaceForService(
													  hidDevice, kIOHIDDeviceUserClientTypeID,
													  kIOCFPlugInInterfaceID, &plugInInterface, &score);
    if (ioReturnValue != kIOReturnSuccess) {
        return;
    }
	
    plugInResult = (*plugInInterface)->QueryInterface(plugInInterface,
													  CFUUIDGetUUIDBytes(kIOHIDDeviceInterfaceID), (LPVOID)hdi);
    print_errmsg_if_err(plugInResult != S_OK,
                        "Failed to create device interface.\n");
	
    (*plugInInterface)->Release(plugInInterface);
}

io_service_t           hidService = (io_service_t)0;
io_object_t            hidDevice = (io_object_t)0;
IOHIDDeviceInterface **hidDeviceInterface = NULL;

static int setup_led(void)
{
	static int initialized = 0;
	if(initialized)
		return kIOReturnSuccess;
	initialized = 1;
	
    IOReturn               ioReturnValue = kIOReturnError;
	if (!(hidService = find_a_keyboard())) {
        fprintf(stderr, "No keyboard found.\n");
        return ioReturnValue;
    }
	
    hidDevice = (io_object_t)hidService;
	
    create_hid_interface(hidDevice, &hidDeviceInterface);
	
    find_led_cookies((IOHIDDeviceInterface122 **)hidDeviceInterface);
	
    ioReturnValue = IOObjectRelease(hidDevice);
    if (ioReturnValue != kIOReturnSuccess) {
        goto out;
    }
	
    ioReturnValue = kIOReturnError;
	
    if (hidDeviceInterface == NULL) {
        fprintf(stderr, "Failed to create HID device interface.\n");
        return ioReturnValue;
    }
	
    ioReturnValue = (*hidDeviceInterface)->open(hidDeviceInterface, 0);
    if (ioReturnValue != kIOReturnSuccess) {
        fprintf(stderr, "Failed to open HID device interface.\n");
        goto out;
    }
	
out:
	if(ioReturnValue != kIOReturnSuccess)
		(void)(*hidDeviceInterface)->Release(hidDeviceInterface);
	
	return ioReturnValue;
}

int
manipulate_led(UInt32 whichLED, UInt32 value)
{
	setup_led();
	
    IOReturn               ioReturnValue = kIOReturnError;
    IOHIDElementCookie     theCookie = (IOHIDElementCookie)0;
    IOHIDEventStruct       theEvent;
	
	
    if (whichLED == kHIDUsage_LED_NumLock) {
        theCookie = numlock_cookie;
    } else if (whichLED == kHIDUsage_LED_CapsLock) {
        theCookie = capslock_cookie;
    }
	
    if (theCookie == 0) {
        fprintf(stderr, "Bad or missing LED cookie.\n");
        goto out;
    }
	
    ioReturnValue = (*hidDeviceInterface)->getElementValue(hidDeviceInterface,
														   theCookie, &theEvent);
    if (ioReturnValue != kIOReturnSuccess) {
        (void)(*hidDeviceInterface)->close(hidDeviceInterface);
        goto out;
    }
	
//    fprintf(stdout, "current: %s\n", (theEvent.value) ? "on" : "off");
    if (value != (UInt32)-1) {
		theEvent.value = value;
		ioReturnValue = (*hidDeviceInterface)->setElementValue(
															   hidDeviceInterface, theCookie,
															   &theEvent, 0, 0, 0, 0);
		if (ioReturnValue == kIOReturnSuccess) {
//			fprintf(stdout, "new: %s\n", (theEvent.value) ? "on" : "off");
		}
    }
	
out:
	return ioReturnValue;
}
