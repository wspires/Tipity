//
//  MAViewUtil.h
//  Gym Log
//
//  Created by Wade Spires on 6/23/14.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MAViewUtil : NSObject

+ (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
+ (void)willRotateView:(UIView *)view toInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;
+ (void)willRotateView:(UIView *)view toInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration extraOffset:(CGFloat)extraOffset;

+ (void)popNavControllers;

@end
