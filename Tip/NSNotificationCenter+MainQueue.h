//
//  NSNotificationCenter+MainQueue.h
//  Gym Log
//
//  Created by Wade Spires on 7/25/16.
//
//

#import <Foundation/Foundation.h>

@interface NSNotificationCenter (MainQueue)

-(void)postNotificationOnMainQueue:(NSNotification *)notification;
-(void)postNotificationNameOnMainQueue:(NSString *)aName object:(id)anObject;
-(void)postNotificationNameOnMainQueue:(NSString *)aName object:(id)anObject userInfo:(NSDictionary *)aUserInfo;

@end
