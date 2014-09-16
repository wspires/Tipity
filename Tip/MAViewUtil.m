//
//  MAViewUtil.m
//  Gym Log
//
//  Created by Wade Spires on 6/23/14.
//
//

#import "MAViewUtil.h"

#import "MAAppDelegate.h"
#import "MAUtil.h"

@implementation MAViewUtil

+ (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation == UIInterfaceOrientationPortrait
    || interfaceOrientation == UIInterfaceOrientationLandscapeLeft
    || interfaceOrientation == UIInterfaceOrientationLandscapeRight;
    
    /*
     if ([MAUtil iPad])
     {
     return interfaceOrientation == UIInterfaceOrientationPortrait
     || interfaceOrientation == UIInterfaceOrientationLandscapeLeft
     || interfaceOrientation == UIInterfaceOrientationLandscapeRight;
     }
     else
     {
     return (interfaceOrientation == UIInterfaceOrientationPortrait);
     }
     */
}

+ (void)willRotateView:(UIView *)view toInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    CGFloat extraOffset = 0.0;
    [MAViewUtil willRotateView:view toInterfaceOrientation:toInterfaceOrientation duration:duration extraOffset:extraOffset];
}

+ (void)willRotateView:(UIView *)view toInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration extraOffset:(CGFloat)extraOffset
{
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
    {
        // First, apply identify transformation to simplify later calculations and also because we need the toolbar's frame and Apple's docs say you cannot use a view's frame if the transform property is not the identity matrix.
        view.transform = CGAffineTransformIdentity;
        
        // Calculate affine parameters.
        
        // Get the window's post-orientation change dimensions.
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        CGFloat rotatedWinWidth = window.frame.size.height;
        CGFloat rotatedWinHeight = window.frame.size.width;
        
        // Expand width to the window's height when in landscape mode, leaving the toolbar's height unchanged. The scaling is done along the Y axis since the window's origin will change such that the Y axis will still run along the longer direction of the device.
        CGFloat sx = 1.0;
        CGFloat sy = rotatedWinWidth / rotatedWinHeight;
        
        // Rotate 90 degrees in either direction depending on the orientation direction change.
        CGFloat angle = M_PI_2;
        if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft)
        {
            angle = -M_PI_2;
        }
        
        // Reposition the toolbar, assuming that view.layer.anchorPoint is (0, 0).
        // Note that the height of the view is used as the X offset as this corresponds to the X direction since the rotated window's origin will also rotate. Also, the position has to take into account the width scale factor.
        CGFloat xOffset = view.frame.size.height;
        CGFloat tx = -(rotatedWinWidth - xOffset - extraOffset) / sy;
        CGFloat ty = -view.frame.size.height - extraOffset;
        if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft)
        {
            tx = (-xOffset - extraOffset) / sy;
            ty = rotatedWinHeight - view.frame.size.height - extraOffset;
        }
        
        // Apply affine transformation.
        CGAffineTransform transform = CGAffineTransformMakeScale(sx, sy);
        transform = CGAffineTransformRotate(transform, angle);
        transform = CGAffineTransformTranslate(transform, tx, ty);
        [UIView animateWithDuration:duration
                         animations:^{
                             view.transform = transform;
                         }
                         completion:NULL
         ];
    }
    else if (toInterfaceOrientation == UIInterfaceOrientationPortrait)
    {
        [UIView animateWithDuration:duration
                         animations:^{
                             view.transform = CGAffineTransformIdentity;
                         }completion:NULL
         ];
    }
    else if (toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        DLog(@"Upside-down orientation not supported");
    }
}

+ (void)popNavControllers
{
    // If the user changes, then pop the routines tab back to the top since that tab may be drilled down in to the routine and exercises for a different user.
    MAAppDelegate* myDelegate = (((MAAppDelegate*) [UIApplication sharedApplication].delegate));
    [myDelegate.tipNavController popToRootViewControllerAnimated:NO];
}

@end
