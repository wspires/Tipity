//
//  MATextFieldCell.m
//  Weight Log
//
//  Created by Wade Spires on 1/28/14.
//  Copyright (c) 2014 Wade Spires. All rights reserved.
//

#import "MATextFieldCell.h"

#import "MAAppearance.h"
#import "MAUtil.h"

@interface MATextFieldCell ()
@end

@implementation MATextFieldCell
@synthesize textField = _textField;
@synthesize label = _label;

@synthesize trailingSpaceConstraint = _trailingSpaceConstraint;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setAppearanceInTable:(UITableView *)tableView;
{
    [MAAppearance setAppearanceForCell:self tableStyle:tableView.style];

    // Required on iOS 6 because the text label bg color is white and will cover the text view otherwise.
    self.textLabel.backgroundColor = [UIColor clearColor];
    
    self.label.backgroundColor = [UIColor clearColor];

    self.textField.borderStyle = UITextBorderStyleNone;
    self.textField.backgroundColor = [UIColor clearColor];
    self.textField.textAlignment = NSTextAlignmentRight;
    self.textField.placeholder = nil;
    self.textField.font = self.label.font;
    
    // Adjust trailing space to line up with the row showing the current weight. Values based on visual inspection.
    if (BELOW_IOS7)
    {
        self.trailingSpaceConstraint.constant = 7;
    }
    else
    {
        self.trailingSpaceConstraint.constant = 13;
    }
    
    if (BELOW_IOS7)
    {
        // Need the iOS 6 detail text color in order for the text field and label to match the other cells. However, self.detailTextLabel.textColor seems to be nil for some reason, so hard-code the color to the value based on here:
        // http://stackoverflow.com/questions/5435739/what-color-is-the-text-in-the-detail-view-of-a-uitableviewcellstylevalue1
        UIColor *detailedTextColor = [UIColor colorWithRed:0.22 green:0.33 blue:0.53 alpha:1.0];
        BOOL const isGrouped = (tableView.style == UITableViewStyleGrouped);
        if (isGrouped)
        {
            self.textField.textColor = detailedTextColor;
            self.label.textColor = detailedTextColor;
        }
        else
        {
            self.textField.textColor = [MAAppearance detailLabelTextColor];
            self.label.textColor = [MAAppearance detailLabelTextColor];            
        }
    }
    else
    {
        self.textField.textColor = [MAAppearance detailLabelTextColor];
        self.label.textColor = [MAAppearance detailLabelTextColor];
    }
}

@end
