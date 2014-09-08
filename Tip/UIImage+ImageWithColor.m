//
//  UIImage+ImageWithColor.m
//  Gym Log
//
//  Created by Wade Spires on 10/20/13.
//
//

#import "UIImage+ImageWithColor.h"

@implementation UIImage (ImageWithColor)

+ (UIImage *)imageWithColor:(UIColor *)color
{
    // Thread-safe initialization of shared size variable.
    static CGSize size;
    static dispatch_once_t once = 0;
    dispatch_once(&once, ^{
        size.width = 1;
        size.height = 1;
    });
    
    return [UIImage imageWithColor:color size:size];
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size
{
    return [UIImage imageWithColor:color size:size opaque:NO];
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size opaque:(BOOL)opaque
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    
    // Note: do not use UIGraphicsBeginImageContext since the color's alpha channel will be ignored causing the color to always be opaque regardless of the given opaque parameter.
    UIGraphicsBeginImageContextWithOptions(rect.size, opaque, 0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

@end
