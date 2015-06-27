//
//  MAAccessoryView.m
//  Gym Log
//
//  Created by Wade Spires on 9/9/13.
//
//

#import "MAAccessoryView.h"

#import "MAAppearance.h"
#import "MADeviceUtil.h"
#import "MAUtil.h"

#define PADDING 4.f //give the canvas some padding so the ends and joints of the lines can be drawn with a mitered joint
#define ACCESSORY_WIDTH 13.f
#define ACCESSORY_HEIGHT 18.f

@implementation MAAccessoryView
@synthesize color = _color;
@synthesize move = _move;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.color = [MAAccessoryView chevronColor];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

+ (CGRect)frameWithWidth:(CGFloat)width height:(CGFloat)height
{
    return CGRectMake(width - ACCESSORY_WIDTH - PADDING,
                      (height / 2) - (ACCESSORY_HEIGHT / 2),
                      ACCESSORY_WIDTH, ACCESSORY_HEIGHT);
}

+ accessoryViewWithColor:(UIColor *)color cellWidth:(CGFloat)cellWidth cellHeight:(CGFloat)cellHeight
{
    MAAccessoryView *accessoryView = [[MAAccessoryView alloc] initWithFrame:
                                      CGRectMake(cellWidth - ACCESSORY_WIDTH - PADDING,
                                                 cellHeight/2 - ACCESSORY_HEIGHT/2,
                                                 ACCESSORY_WIDTH, ACCESSORY_HEIGHT)];
    accessoryView.color = color;
    return accessoryView;
}

+ accessoryViewWithColor:(UIColor *)color cell:(UITableViewCell *)cell
{
    MAAccessoryView *accessoryView = [MAAccessoryView accessoryViewWithColor:color cellWidth:cell.frame.size.width cellHeight:cell.frame.size.height];
    return accessoryView;
}

+ grayAccessoryViewForCell:(UITableViewCell *)cell
{
    MAAccessoryView *accessoryView = [MAAccessoryView accessoryViewWithColor:[MAAccessoryView chevronColor] cell:cell];
    return accessoryView;
}

+ grayMoveAccessoryViewForCell:(UITableViewCell *)cell
{
    MAAccessoryView *accessoryView = [MAAccessoryView accessoryViewWithColor:[MAAccessoryView chevronColor] cell:cell];
    accessoryView.move = YES;    
    return accessoryView;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    if (!self.move)
    {
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextSetStrokeColorWithColor(context, self.color.CGColor);
        CGContextSetLineWidth(context, 3.f);
        CGContextSetLineJoin(context, kCGLineJoinMiter);
        
        CGContextMoveToPoint(context, PADDING, PADDING);
        CGContextAddLineToPoint(context, self.frame.size.width - PADDING, self.frame.size.height / 2);
        CGContextAddLineToPoint(context, PADDING, self.frame.size.height - PADDING);
        
        CGContextStrokePath(context);
    }
    else
    {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetStrokeColorWithColor(context, self.color.CGColor);

        float lineWidth = .5f;
        CGContextSetLineWidth(context, lineWidth);

        float x = 0;
        float y = self.frame.size.height / 3;
        float width = self.frame.size.width;
        float yOffset = 10 * lineWidth;

        CGContextMoveToPoint(context, x, y);
        CGContextAddLineToPoint(context, width, y);
        CGContextStrokePath(context);

        CGContextMoveToPoint(context, x, y + yOffset);
        CGContextAddLineToPoint(context, width, y + yOffset);
        CGContextStrokePath(context);
        
        CGContextMoveToPoint(context, x, y + 2 * yOffset);
        CGContextAddLineToPoint(context, width, y + 2 * yOffset);
        CGContextStrokePath(context);
    }
}

+ (UIColor *)chevronColor
{
    if (BELOW_IOS7)
    {
        // Just use gray on iOS 6 and below so that the chevron looks okay in both the iOS 6 style plain and grouped tableview styles and with both light and dark backgrounds.
        return [UIColor grayColor];
    }
    
    return [MAAppearance separatorColor];
    //return [UIColor grayColor];
    //return [UIColor lightGrayColor];
}

@end
