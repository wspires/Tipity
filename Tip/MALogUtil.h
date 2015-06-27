//
//  MALogUtil.h
//  Tip
//
//  Created by Wade Spires on 6/24/15.
//  Copyright © 2015 Minds Aspire LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

// Note: Always comment this out before a new release to disable logging.
//#define MA_DEBUG_MODE

#ifdef MA_DEBUG_MODE
#define DLog( s, ... ) NSLog( @"<%p %@:(%d, %s) %@> %@", self, [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, __FUNCTION__, [NSThread currentThread], [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
#define DLog( s, ... )
#endif

#define TLog( s, ... ) NSLog( @"<%p %@:(%d, %s) %@> %@", self, [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, __FUNCTION__, [NSThread currentThread], [NSString stringWithFormat:(s), ##__VA_ARGS__] )

#define LOG NSLog( @"%s (%d)", __FUNCTION__, __LINE__ );
#define LOG_BEGIN NSLog( @"%s (%d) - Begin", __FUNCTION__, __LINE__ );
#define LOG_END NSLog( @"%s (%d) - End", __FUNCTION__, __LINE__ );
#define LOG_I(i) NSLog( @"%s (%d) - %d", __FUNCTION__, __LINE__, (i) );
#define LOG_O(o) NSLog( @"%s (%d) - %@", __FUNCTION__, __LINE__, (o) );
#define LOG_S(s, ...) NSLog( @"%s (%d) - %@", __FUNCTION__, __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] );

@interface MALogUtil : NSObject

@end
