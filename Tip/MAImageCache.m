//
//  MAImageCache.m
//  Tip
//
//  Created by Wade Spires on 11/3/14.
//  Copyright (c) 2014 Minds Aspire LLC. All rights reserved.
//

#import "MAImageCache.h"

@implementation MAImageCache

+ (MAImageCache *)sharedInstance
{
    static dispatch_once_t once;
    static MAImageCache * sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

@end
