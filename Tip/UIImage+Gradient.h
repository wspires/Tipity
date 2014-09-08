//
//  UIImage+Gradient.h
//  Gym Log
//
//  Created by Wade Spires on 12/22/13.
//
//

#import <UIKit/UIKit.h>

@interface UIImage (Gradient)

+ (UIImage *)imageWithGradient:(UIImage *)img startColor:(UIColor *)startColor endColor:(UIColor *)endColor;
+ (UIImage *)imageWithGradient:(UIImage *)img startColor:(UIColor *)startColor endColor:(UIColor *)endColor startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint;

@end
