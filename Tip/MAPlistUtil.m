//
//  MAPlistUtil.m
//  Gym Log
//
//  Created by Wade Spires on 7/17/16.
//
//

#import "MAPlistUtil.h"

#import "NSData+Compress.h"

// Whether to compress/decompress NSData objects when archiving/unarchiving dictionaries.
static BOOL const DefaultCompressData = YES;

@implementation MAPlistUtil

// https://developer.apple.com/library/prerelease/content/documentation/Cocoa/Conceptual/PropertyLists/AboutPropertyLists/AboutPropertyLists.html#//apple_ref/doc/uid/10000048i-CH3-SW2
+ (BOOL)isPlistObject:(id)object
{
    if ([object isKindOfClass:[NSArray class]])
    {
        return [MAPlistUtil isPlistArray:(NSArray *)object];
    }
    else if ([object isKindOfClass:[NSDictionary class]])
    {
        return [MAPlistUtil isPlistDictionary:(NSDictionary *)object];
    }

    return [MAPlistUtil isBasicPlistObject:object];
}

+ (BOOL)isBasicPlistObject:(id)object
{
    return [object isKindOfClass:[NSString class]]
    || [object isKindOfClass:[NSData class]]
    || [object isKindOfClass:[NSDate class]]
    || [object isKindOfClass:[NSNumber class]]
    ;
}

+ (BOOL)isPlistArray:(NSArray *)array
{
    // Per Apple, if a property-list object is a container (that is, an array or dictionary), all objects contained within it must also be property-list objects.
    for (id object in array)
    {
        if ( ! [MAPlistUtil isPlistObject:object])
        {
            return NO;
        }
    }
    return YES;
}

+ (BOOL)isPlistDictionary:(NSDictionary *)dictionary
{
    for (id key in dictionary)
    {
        // Per Apple, if the keys are not string objects, the collections are not property-list objects.
        if ( ! [key isKindOfClass:[NSString class]])
        {
            return NO;
        }

        id value = [dictionary objectForKey:key];
        if ( ! [MAPlistUtil isPlistObject:value])
        {
            return NO;
        }
    }
    return YES;
}

+ (void)archiveDictionary:(NSMutableDictionary<NSString *, id> *)dictionary
{
    [MAPlistUtil archiveDictionary:dictionary compressData:DefaultCompressData];
}
+ (void)archiveDictionary:(NSMutableDictionary<NSString *, id> *)dictionary compressData:(BOOL)compressData
{
    NSArray *keys = [dictionary allKeys];
    for (NSString *key in keys)
    {
        // Do not encode an object that is already a plist, unless we are compressing NSData and this object is an NSData.
        id object = [dictionary objectForKey:key];
        if ([MAPlistUtil isPlistObject:object])
        {
            if ( ! compressData || ! [object isKindOfClass:[NSData class]])
            {
                continue;
            }
        }
        
        NSData *encodedData = [NSKeyedArchiver archivedDataWithRootObject:object];
        if (compressData)
        {
            encodedData = [encodedData gzipDeflate];
        }
        [dictionary setObject:encodedData forKey:key];
    }
}

+ (NSDictionary<NSString *, id> *)unarchiveDictionary:(NSDictionary<NSString *, id> *)dictionary
{
    // Copy into a mutable dictionary, which gets modified and returned.
    NSMutableDictionary<NSString *, id> *mutableDictionary = [NSMutableDictionary dictionaryWithDictionary:dictionary];
    [MAPlistUtil unarchiveMutableDictionary:mutableDictionary];
    return mutableDictionary;
}

+ (void)unarchiveMutableDictionary:(NSMutableDictionary<NSString *, id> *)dictionary
{
    [MAPlistUtil unarchiveMutableDictionary:dictionary decompressData:DefaultCompressData];
}
+ (void)unarchiveMutableDictionary:(NSMutableDictionary<NSString *, id> *)dictionary decompressData:(BOOL)decompressData
{
    NSArray *keys = [dictionary allKeys];
    for (NSString *key in keys)
    {
        id object = [dictionary objectForKey:key];
        if ( ! [object isKindOfClass:[NSData class]])
        {
            continue;
        }
        
        NSData *data = (NSData *)object;
        if (decompressData)
        {
            data = [data gzipInflate];
        }
        id decodedData = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        [dictionary setObject:decodedData forKey:key];
    }
}

@end
