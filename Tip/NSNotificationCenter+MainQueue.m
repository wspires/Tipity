//
//  NSNotificationCenter+MainQueue.m
//  Gym Log
//
//  Created by Wade Spires on 7/25/16.
//
//

#import "NSNotificationCenter+MainQueue.h"

@implementation NSNotificationCenter (MainQueue)

-(void)postNotificationOnMainQueue:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self postNotification:notification];
    });
}

-(void)postNotificationNameOnMainQueue:(NSString *)aName object:(id)anObject
{
    [self postNotificationNameOnMainQueue:aName object:anObject userInfo:nil];
}

-(void)postNotificationNameOnMainQueue:(NSString *)aName object:(id)anObject userInfo:(NSDictionary *)aUserInfo
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self postNotificationName:aName object:anObject userInfo:aUserInfo];
    });
}

@end
