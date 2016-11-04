//
//  MADeviceUtil.m
//  Tip
//
//  Created by Wade Spires on 6/26/15.
//  Copyright © 2015 Minds Aspire LLC. All rights reserved.
//

#import "MADeviceUtil.h"

#import <UIKit/UIKit.h>

NSUInteger DeviceSystemMajorVersion(void)
{
    static NSUInteger _deviceSystemMajorVersion = -1;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _deviceSystemMajorVersion = [[NSProcessInfo processInfo] operatingSystemVersion].majorVersion;
    });
    return _deviceSystemMajorVersion;
}

@implementation MADeviceUtil

+ (BOOL)iPad
{
#ifdef IS_EXTENSION
    return NO;
#else
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
#endif // IS_EXTENSION
}

@end
