//
//  MAStringUtil.h
//  Tip
//
//  Created by Wade Spires on 6/26/15.
//  Copyright © 2015 Minds Aspire LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MAStringUtil : NSObject

+ (BOOL)isStringOn:(NSString *)string;

+ (NSString *)trimWhitespace:(NSString *)string;

+ (double)parseDouble:(NSString *)s;
+ (NSString *)formatDouble:(double)d;
+ (NSString *)formatHeight:(double)d;
+ (NSString *)formatCount:(NSUInteger)count;

+ (NSArray *)localizeArray:(NSArray *)array reverseMap:(NSMutableDictionary *)reverseMap;
+ (NSArray *)localizeArray:(NSArray *)array;

+ (NSData *)dataFromString:(NSString *)string;
+ (NSString *)stringFromData:(NSData *)data;

+ (NSString *)escapeCharsInString:(NSString *)string;

+ (NSArray *)splitString:(NSString *)string delimiter:(unichar)delimiter escape:(unichar)escape;
+ (NSArray *)splitCSVString:(NSString *)string;

+ (NSArray *)sortStringArray:(NSArray *)array ascending:(BOOL)ascending;
+ (NSArray *)sortStringArray:(NSArray *)array;
+ (NSArray *)reverseSortStringArray:(NSArray *)array;

+ (BOOL)stringArray:(NSArray *)array1 isEqualToStringArray:(NSArray *)array2;

@end
