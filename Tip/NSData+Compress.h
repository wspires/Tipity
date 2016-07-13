//
//  NSData+Compress.h
//  Gym Log
//
//  Created by Wade Spires on 7/26/16.
//
//

#import <Foundation/Foundation.h>

//http://stackoverflow.com/questions/230984/compression-api-on-the-iphone/234099#234099

@interface NSData (Compress)

// ZLIB
- (NSData *) zlibInflate;
- (NSData *) zlibDeflate;

// GZIP
- (NSData *) gzipInflate;
- (NSData *) gzipDeflate;

// CRC32
- (unsigned int)crc32;

@end
