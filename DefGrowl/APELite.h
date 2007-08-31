/*
	File:		APELite.h

	Contains:	Application Enhancer Lite interfaces

	Copyright:	Copyright 2002-2003 Unsanity, LLC.
				All Rights Reserved.
 
*/
#ifndef _H_APELite
#define _H_APELite

#include <mach-o/loader.h>

#ifdef __cplusplus
extern "C" {
#endif


// Public and private mach-o symbol lookup.
extern void *APEFindSymbol(struct mach_header *image,const char *symbol);

// Mach-o function patching.
extern void *APEPatchCreate(const void *patchee,const void *address);
extern void *APEPatchGetAddress(void *patch);
extern void APEPatchSetAddress(void *patch,const void *address);


#ifdef __cplusplus
}
#endif

#endif /* _H_APELite */
