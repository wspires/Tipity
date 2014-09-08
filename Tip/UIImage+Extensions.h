//
//  UIImage+Extensions.h
//  Gym Log
//
//  Created by Wade Spires on 10/30/13.
//
//

#import <UIKit/UIKit.h>

@interface UIImage (Extensions)

-(UIImage *)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;

+ (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)size;
+ (UIImage *)rotateImage:(UIImage *)image toOrientation:(UIImageOrientation)orientation;

- (UIImage *)imageAtRect:(CGRect)rect;
- (UIImage *)imageByScalingProportionallyToMinimumSize:(CGSize)targetSize;
- (UIImage *)imageByScalingProportionallyToSize:(CGSize)targetSize;
- (UIImage *)imageByScalingToSize:(CGSize)targetSize;
- (UIImage *)imageRotatedByRadians:(CGFloat)radians;
- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees;

@end
