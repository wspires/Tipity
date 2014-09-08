//
//  MAColorUtil.h
//  Gym Log
//
//  Created by Wade Spires on 9/4/13.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define UIColorFromRGB(r, g, b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]
#define UIColorFromRGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

// Macros MIN3 and MAX3 calculate the mininum and maximum value, respectively, among a set of 3 values.
#ifndef MIN
    #define MIN(a, b) \
        (a) < (b) ? (a) : (b)
#endif

#define MIN3(a, b, c) \
    MIN(MIN((a), (b)), (c))

#ifndef MAX
    #define MAX(a, b) \
        (a) > (b) ? (a) : (b)
#endif

#define MAX3(a, b, c) \
    MAX(MAX((a), (b)), (c))

void RGBtoHSV( float r, float g, float b, float *h, float *s, float *v );
void HSVtoRGB( float *r, float *g, float *b, float h, float s, float v );

@interface MAColorUtil : NSObject

+ (BOOL)isDarkColor:(UIColor *)color;
+ (BOOL)isLightColor:(UIColor *)color;
+ (BOOL)autoChangeTextColor:(UIColor *)backgroundColor forKey:(NSString *)key;

@end
