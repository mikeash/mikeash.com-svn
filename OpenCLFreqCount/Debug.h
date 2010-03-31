/*
 *  TDDebug.h
 *
 *  Created by Christopher Liscio on 1/25/08.
 *  Copyright 2008 SuperMegaUltraGroovy. All rights reserved.
 *
 */

#define _FILE_ID [@__FILE__ lastPathComponent]

#define ERROR( msg, ... ) NSLog( @"(ERROR) %@ : %@", _FILE_ID, [NSString stringWithFormat:msg, ##__VA_ARGS__] )

#ifdef SMUG_DEBUG
#define DEBUG( msg, ... ) NSLog( @"(DEBUG) %@ : %@", _FILE_ID, [NSString stringWithFormat:msg, ##__VA_ARGS__] )
#else
#define DEBUG( msg, ... )
#endif