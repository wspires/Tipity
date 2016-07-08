//
//  MASwitchCell.m
//  Gym Log
//
//  Created by Wade Spires on 3/18/13.
//
//

#import "MASwitchCell.h"

#import "MAAppearance.h"
#import "MADeviceUtil.h"
#import "MAFilePaths.h"

@implementation MASwitchCell
@synthesize label;
@synthesize swtch;
@synthesize leadingSpaceConstraint = _leadingSpaceConstraint;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        if (BELOW_IOS7)
        {
            _leadingSpaceConstraint.constant = 10;
            [self.superview layoutIfNeeded];
        }
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        if (BELOW_IOS7)
        {
            _leadingSpaceConstraint.constant = 10;
            [self.superview layoutIfNeeded];
        }
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setAppearanceInTable:(UITableView *)tableView;
{
    [MAAppearance setAppearanceForCell:self tableStyle:tableView.style];
    [MAAppearance setFontForCellLabel:self.label tableStyle:tableView.style];

    if (ABOVE_IOS7)
    {
        // Dynamic type in iOS 7.
        self.label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    }
    else
    {
        self.label.font = [self.label.font fontWithSize:[MAAppearance cellFontSize]];
    }
    
    [self configureConstraints];
}

- (void)configureConstraints
{
    double constant = 16.;
    if (IS_IPHONE_6P)
    {
        constant = 20.;
    }
    self.leadingSpaceConstraint.constant = constant;
    [self.superview layoutIfNeeded];
}

+ (NSString *)cellIdentifier
{
    return @"MASwitchCellIdentifier";
}

+ (NSString *)nibName
{
    return @"MASwitchCell";
}

+ (void)registerNibWithTableView:(UITableView *)tableView
{
    UINib *nib = [UINib nibWithNibName:[MASwitchCell nibName] bundle:nil];
    [tableView registerNib:nib forCellReuseIdentifier:[MASwitchCell cellIdentifier]];
}

- (void)setImage:(UIImage *)image
{
    self.imageView.image = image;
    double constant = 57.;
    if (IS_IPHONE_6P)
    {
        constant = 63.;
    }
    self.leadingSpaceConstraint.constant = constant; // Space in front of text to make remove for the image.
}

@end
