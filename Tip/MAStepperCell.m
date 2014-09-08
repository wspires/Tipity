//
//  MAStepperCell.m
//  Gym Log
//
//  Created by Wade Spires on 3/18/13.
//
//

#import "MAStepperCell.h"

#import "MAAppearance.h"
#import "MAFilePaths.h"
#import "MAUtil.h"

@implementation MAStepperCell
@synthesize label;
@synthesize stepper;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
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
}

@end
