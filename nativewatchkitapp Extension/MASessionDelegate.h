//
//  MASessionDelegate.h
//  Tip
//
//  Created by Wade Spires on 10/24/15.
//  Copyright © 2015 Minds Aspire LLC. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <WatchConnectivity/WatchConnectivity.h>
#import <Foundation/Foundation.h>

@interface MASessionDelegate : NSObject <WCSessionDelegate>

+ (MASessionDelegate *)sharedInstance;

- (instancetype)init;

- (BOOL)updateApplicationContextWithObject:(id<NSCoding>)object key:(NSString *)key;
- (BOOL)updateApplicationContextWithData:(NSData *)data key:(NSString *)key;

@end
