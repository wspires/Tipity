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
    
    self.textField.borderStyle = UITextBorderStyleNone;
    self.textField.backgroundColor = [UIColor clearColor];
    self.textField.textAlignment = NSTextAlignmentRight;
    self.textField.placeholder = nil;
    self.textField.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    
    self.textField.textColor = [MAAppearance detailLabelTextColor];
}

@end
