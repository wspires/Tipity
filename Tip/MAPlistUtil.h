//
//  MAPlistUtil.h
//  Gym Log
//
//  Created by Wade Spires on 7/17/16.
//
//

#import <Foundation/Foundation.h>

// Utility class for determining if an object is a type that can be stored directly in a property list.
// https://developer.apple.com/library/prerelease/content/documentation/Cocoa/Conceptual/PropertyLists/Introduction/Introduction.html#//apple_ref/doc/uid/10000048-CJBGDEGD
@interface MAPlistUtil : NSObject

// Determine if the given object is a property-list object.
// If the object is a container, all contained objects are also checked.
+ (BOOL)isPlistObject:(id)object;

// Determine if the given object is a property-list object, excluding container types.
+ (BOOL)isBasicPlistObject:(id)object;

// Determine if the given container is a property-list object by checking all contained objects.
+ (BOOL)isPlistArray:(NSArray *)array;
+ (BOOL)isPlistDictionary:(NSDictionary *)dictionary;

// Encode all non-property-list objects to NSData and re-add them to the dictionary for the same key. This is done because only property list types (such as NSData) can be sent between the watch and the phone (custom objects cannot be sent directly).
+ (void)archiveDictionary:(NSMutableDictionary<NSString *, id> *)dictionary;
+ (void)archiveDictionary:(NSMutableDictionary<NSString *, id> *)dictionary compressData:(BOOL)compressData;

// Decode all non-property-list NSData to original objects and re-add them to the dictionary for the same key.
+ (NSDictionary<NSString *, id> *)unarchiveDictionary:(NSDictionary<NSString *, id> *)dictionary;
+ (void)unarchiveMutableDictionary:(NSMutableDictionary<NSString *, id> *)dictionary;
+ (void)unarchiveMutableDictionary:(NSMutableDictionary<NSString *, id> *)dictionary decompressData:(BOOL)decompressData;

@end
