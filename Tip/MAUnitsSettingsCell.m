//
//  MAUnitsSettingsCell.m
//  Gym Log
//
//  Created by Wade Spires on 3/18/13.
//
//

#import "MAUnitsSettingsCell.h"

#import "MAUtil.h"
#import "MAAppearance.h"
#import "MAFilePaths.h"

@implementation MAUnitsSettingsCell
@synthesize label;
@synthesize segCtrl;

// TODO: Never called so init must be done
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self resizeSegCtrl];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)resizeSegCtrl
{
    CGRect frame = self.segCtrl.frame;
    frame.size.height = 30; // 44 is regular size.
    frame.origin.y = (self.frame.size.height / 2) - (frame.size.height / 2) + 1;
    [self.segCtrl setFrame:frame];
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
