//
//  MATextFieldCell.h
//  Weight Log
//
//  Created by Wade Spires on 1/28/14.
//  Copyright (c) 2014 Wade Spires. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MATextFieldCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *trailingSpaceConstraint;

- (void)setAppearanceInTable:(UITableView *)tableView;

@end
