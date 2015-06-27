//
//  MAStringUtil.m
//  Tip
//
//  Created by Wade Spires on 6/26/15.
//  Copyright © 2015 Minds Aspire LLC. All rights reserved.
//

#import "MAStringUtil.h"

#import "MADefines.h"
#import "MALogUtil.h"

@implementation MAStringUtil

+ (BOOL)isStringOn:(NSString *)string
{
    return string && [string isEqualToString:@"on"];
}

+ (NSString *)trimWhitespace:(NSString *)string
{
    if (!string)
    {
        return string;
    }
    
    NSMutableString *mutableString = [string mutableCopy];
    CFStringTrimWhitespace((CFMutableStringRef)mutableString);
    
    NSString *result = [mutableString copy];
    
    return result;
}

+ (double)parseDouble:(NSString *)s
{
    static dispatch_once_t once;
    static NSNumberFormatter *nf = nil;
    dispatch_once(&once, ^{
        nf = [[NSNumberFormatter alloc] init];
        [nf setNumberStyle:NSNumberFormatterDecimalStyle];
        [nf setLocale:[NSLocale autoupdatingCurrentLocale]];
    });
    
    static dispatch_once_t once2;
    static NSCharacterSet *trimCharSet = nil;
    dispatch_once(&once2, ^{
        NSString *decimalSep = [[NSLocale autoupdatingCurrentLocale] objectForKey:NSLocaleDecimalSeparator];
        NSMutableCharacterSet *digitDecimalCharSet = [NSMutableCharacterSet characterSetWithCharactersInString:decimalSep];
        [digitDecimalCharSet formUnionWithCharacterSet:[NSCharacterSet decimalDigitCharacterSet]];
        trimCharSet = [digitDecimalCharSet invertedSet];
    });
    
    s = [s stringByTrimmingCharactersInSet:trimCharSet];
    
    NSNumber *n = [nf numberFromString:s];
    double d = [n doubleValue];
    return d;
}

+ (NSString *)formatDouble:(double)d
{
    static dispatch_once_t once;
    static NSNumberFormatter *nf = nil;
    dispatch_once(&once, ^{
        nf = [[NSNumberFormatter alloc] init];
        [nf setNumberStyle:NSNumberFormatterDecimalStyle];
        [nf setPaddingCharacter:@" "];
        [nf setUsesGroupingSeparator:NO];
        [nf setLocale:[NSLocale autoupdatingCurrentLocale]];
        [nf setMaximumFractionDigits:2];
        [nf setRoundingMode:NSNumberFormatterRoundHalfUp];
    });
    
    // Prevent a signed 0. Sometimes we get a -0 as the result of some calculations, which looks weird to the user, so display as just 0.
    // Note: that '-0 == 0' is true.
    // http://en.wikipedia.org/wiki/Signed_zero
    if (d == 0)
    {
        d = fabs(d);
    }
    
    NSString *s = [nf stringFromNumber:[NSNumber numberWithDouble:d]];
    return s;
}

+ (NSString *)formatHeight:(double)d
{
    // Used to have separate logic for formatDouble and formatHeight, but now they do the same thing.
    return [MAStringUtil formatDouble:d];
}

+ (NSString *)formatCount:(NSUInteger)count
{
    static dispatch_once_t once;
    static NSNumberFormatter *nf = nil;
    dispatch_once(&once, ^{
        nf = [[NSNumberFormatter alloc] init];
        [nf setLocale:[NSLocale autoupdatingCurrentLocale]];
        
        NSString *decimalSep = [[NSLocale autoupdatingCurrentLocale] objectForKey:NSLocaleDecimalSeparator];
        [nf setDecimalSeparator:decimalSep];
        
        [nf setUsesGroupingSeparator:YES];
        NSString *groupSep = [[NSLocale autoupdatingCurrentLocale] objectForKey:NSLocaleGroupingSeparator];
        [nf setGroupingSeparator:groupSep];
        [nf setGroupingSize:3]; // TODO: Does grouping size change by locale?
    });
    NSString *s = [nf stringFromNumber:[NSNumber numberWithUnsignedInt:(unsigned int)count]];
    return s;
}

+ (NSArray *)localizeArray:(NSArray *)array reverseMap:(NSMutableDictionary *)reverseMap
{
    if (!array)
    {
        return nil;
    }
    
    NSMutableArray *localizedArray = [[NSMutableArray alloc] initWithCapacity:array.count];
    for (NSUInteger i = 0; i != array.count; ++i)
    {
        NSString *value = [array objectAtIndex:i];
        NSString *localized_value = Localize(value);
        [localizedArray setObject:localized_value atIndexedSubscript:i];
        if (reverseMap)
        {
            [reverseMap setObject:value forKey:localized_value];
        }
    }
    
    return localizedArray;
}

+ (NSArray *)localizeArray:(NSArray *)array
{
    return [MAStringUtil localizeArray:array reverseMap:nil];
}

// Copy contents of an NSString instance into an NSData instance.
// The bytes stored in the NSData instance will be in UTF-16 format and null-terminated.
+ (NSData *)dataFromString:(NSString *)string
{
    // Allocate buffer with the number of bytes given by length of string and null terminator with 2 bytes per character for UTF-16.
    // Note: sizeof(unichar) == 2 != 1 == sizeof(u_char).
    size_t const length = (string.length + 1) * sizeof(unichar);
    u_char *bytes = (u_char *) malloc(length);
    if (bytes == NULL)
    {
        return nil;
    }
    
    // Convert string to bytes in UTF-16.
    NSUInteger usedLength = 0;
    NSRange range;
    range.location = 0;
    range.length = string.length;
    BOOL const didGetBytes = [string getBytes:bytes maxLength:length usedLength:&usedLength encoding:NSUnicodeStringEncoding options:NSStringEncodingConversionAllowLossy range:range remainingRange:NULL];
    if (!didGetBytes)
    {
        free(bytes);
        return nil;
    }
    assert(usedLength == (length - sizeof(unichar))); // Should have copied entire string without null terminator.
    
    // Null-terminate the buffer (2 null bytes for UTF-16).
    // This is not necessary for conversion back to NSString but is necessary for some functions like sqlite3_open16 that rely on a null terminator rather than a buffer count.
    bytes[usedLength] = '\0';
    bytes[usedLength + 1] = '\0';
    
    // Store bytes in NSData instance with data taking ownership of bytes to ensure free() is called automatically on deallocation.
    NSData *data = [NSData dataWithBytesNoCopy:bytes length:length];
    return data;
}

// Copy contents of an NSData instance into an NSString instance.
// The bytes in the NSData instance must be in UTF-16 format and null-terminated, such as is generated by dataFromString.
+ (NSString *)stringFromData:(NSData *)data
{
    // NSString does not expect a null terminator and expects number of characters, not number of bytes.
    NSUInteger const length = (data.length - 1) / sizeof(unichar);
    NSString *string = [NSString stringWithCharacters:data.bytes length:length];
    return string;
}

+ (NSString *)escapeCharsInString:(NSString *)string
{
    // Double quotes are escaped in CSV files by two double quote characters.
    string = [string stringByReplacingOccurrencesOfString:@"\"" withString:@"\"\""];
    return string;
}

+ (NSArray *)splitString:(NSString *)string delimiter:(unichar)delimiter escape:(unichar)escape
{
    NSMutableArray *strings = [[NSMutableArray alloc] init];
    NSMutableString *currentString = [[NSMutableString alloc] init];
    
    BOOL seenEscapedCharacter = NO;
    
    for (int i = 0; i != string.length; ++i)
    {
        unichar character = [string characterAtIndex:i];
        if (seenEscapedCharacter)
        {
            // Appends any character after the escape character, including the delimiter.
            [currentString appendFormat:@"%C", character];
            seenEscapedCharacter = NO;
        }
        else if (character == escape)
        {
            seenEscapedCharacter = YES;
        }
        else if (character == delimiter)
        {
            [strings addObject:currentString];
            currentString = [[NSMutableString alloc] init];
        }
        else
        {
            [currentString appendFormat:@"%C", character];
        }
    }
    [strings addObject:currentString];
    
    return [NSArray arrayWithArray:strings];
}

// Split a single row that is in CSV format. Uses commas as delimiters. Commas can be escaped, that is, used literally, by surrounding them in double quotes, ". Use 2 double quotes to yield a single double quotes character inside of a double-quoted string. For example, the line
// A,"I said, ""Hello, world.""",B,"",C
// will produce an array with the following strings
// A
// I said, "Hello, world."
// B
//
// C
// Note that column 4 (between the columns with strings "B" and "C") is empty as "" is interpreted as a quoted string containing no character, not an escape for a single ".
// https://en.wikipedia.org/wiki/Comma-separated_values#Basic_rules_and_examples
+ (NSArray *)splitCSVString:(NSString *)string
{
    //DLog(@"Input string: '%@'", string);
    //DLog(@"Input string count: %d", string.length);
    
    // Comma is delimiter.
    unichar const comma = 0x002C;
    
    // Double quotes block off a section of text including a section of text. Two double-quotes are used for a single double-quotes character.
    unichar const quotes = 0x0022;
    
    // Check for and skip byte order mark if it is the first character. The character must match the bytes that the CSV export method byteOrderMark returns. Handle both little-endian and big-endian encodings.
    // https://en.wikipedia.org/wiki/Byte_order_mark
    unichar const byteOrderMarkLE = 0xFEFF;
    unichar const byteOrderMarkBE = 0xFFFE;
    
    NSMutableArray *strings = [[NSMutableArray alloc] init];
    NSMutableString *currentString = [[NSMutableString alloc] init];
    
    BOOL searchingForQuotesStart = YES;
    BOOL areInsideQuotedString = NO;
    BOOL wasQuotesCharacterPrevious = NO;
    
    for (int i = 0; i != string.length; ++i)
    {
        //DLog(@"Current string: '%@'", currentString);
        //DLog(@"Current string count: %d", currentString.length);
        
        unichar character = [string characterAtIndex:i];
        //DLog(@"Current char: '%C'", character);
        
        if (i == 0 && (character == byteOrderMarkLE || character == byteOrderMarkBE))
        {
            DLog(@"Ignoring BOM");
            continue;
        }
        else if (character == quotes)
        {
            // Start of quoted column, for example:  ,"
            if (searchingForQuotesStart)
            {
                areInsideQuotedString = YES;
                searchingForQuotesStart = NO;
                // Note: do not set 'wasQuotesCharacterPrevious = YES' because this quotes cannot be escaped to yield a literal quotes, for example:  ,"", should yield an empty column, not ".
            }
            else if (wasQuotesCharacterPrevious)
            {
                // 2 x quotes so append a single quotes character, for example:  ,"hi""yo"
                [currentString appendFormat:@"%C", character];
                wasQuotesCharacterPrevious = NO;
            }
            else
            {
                // Mark that a single quotes character has been seen so that a second quotes character can be detected as above.
                // Note: if inside_quotes == NO and no second quotes character is seen, then this single quotes character will be silently ignored.
                wasQuotesCharacterPrevious = YES;
            }
        }
        else if (character == comma)
        {
            // Either was not not inside of quotes to begin with or the previous character was a quotes, so now are outside of quotes.
            if (!areInsideQuotedString || wasQuotesCharacterPrevious)
            {
                // Start new string.
                [strings addObject:currentString];
                currentString = [[NSMutableString alloc] init];
                areInsideQuotedString = NO;
                searchingForQuotesStart = YES;
            }
            else // (insideQuotes && !wasQuotesCharacterPrevious)
            {
                // Append delimiter since inside of quotes.
                [currentString appendFormat:@"%C", character];
            }
            wasQuotesCharacterPrevious = NO;
        }
        else // Regular character: neither quotes nor comma.
        {
            if (wasQuotesCharacterPrevious)
            {
                // Marks end of quoted substring in column:  ,a"b,c"d,
                // where the column will contain ab,cd
                areInsideQuotedString = NO;
                wasQuotesCharacterPrevious = NO;
                searchingForQuotesStart = YES;
            }
            
            // Append regular character.
            [currentString appendFormat:@"%C", character];
        }
    }
    [strings addObject:currentString];
    
    return strings;
}

+ (NSArray *)sortStringArray:(NSArray *)array ascending:(BOOL)ascending
{
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:nil ascending:ascending selector:@selector(localizedCompare:)];
    return [array sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
}
+ (NSArray *)sortStringArray:(NSArray *)array
{
    return [MAStringUtil sortStringArray:array ascending:YES];
}
+ (NSArray *)reverseSortStringArray:(NSArray *)array
{
    return [MAStringUtil sortStringArray:array ascending:NO];
}

+ (BOOL)stringArray:(NSArray *)array1 isEqualToStringArray:(NSArray *)array2
{
    if (array1 == array2)
    {
        return YES;
    }
    
    if (array1.count != array2.count)
    {
        return NO;
    }
    
    for (NSUInteger i = 0; i != array1.count; ++i)
    {
        NSString *value1 = [array1 objectAtIndex:i];
        NSString *value2 = [array2 objectAtIndex:i];
        if (![value1 isEqualToString:value2])
        {
            return NO;
        }
    }
    
    return YES;
}

@end
