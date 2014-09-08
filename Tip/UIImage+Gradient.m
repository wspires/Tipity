//
//  UIImage+Gradient.m
//  Gym Log
//
//  Created by Wade Spires on 12/22/13.
//
//

#import "UIImage+Gradient.h"

@implementation UIImage (Gradient)

+ (UIImage *)imageWithGradient:(UIImage *)img startColor:(UIColor *)startColor endColor:(UIColor *)endColor
{
    CGPoint startPoint = CGPointMake(0, 0);
    CGPoint endPoint = CGPointMake(0, img.size.height);
    return [UIImage imageWithGradient:img startColor:startColor endColor:endColor startPoint:startPoint endPoint:endPoint];
}

// Note that this seems to steadily cause increasing memory usage with each call, so should cache an image rather than calling this function each time for the same image--that would also save CPU cycles.
+ (UIImage *)imageWithGradient:(UIImage *)img startColor:(UIColor *)startColor endColor:(UIColor *)endColor startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint
{
    // http://stackoverflow.com/questions/8098130/how-can-i-tint-a-uiimage-with-gradient
    // From user 'remy'
    UIGraphicsBeginImageContextWithOptions(img.size, NO, img.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, img.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, img.size.width, img.size.height);
    //CGContextDrawImage(context, rect, img.CGImage);
    
    // Create gradient.
    NSArray *colors = [NSArray arrayWithObjects:(id)endColor.CGColor, (id)startColor.CGColor, nil];
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColors(space, (__bridge CFArrayRef)colors, NULL);
    
    // Apply gradient.
    CGContextClipToMask(context, rect, img.CGImage);
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    UIImage *gradientImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(space);
    
    return gradientImage;
}

@end
