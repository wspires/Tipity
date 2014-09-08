//
//  MASwitchCell.h
//  Gym Log
//
//  Created by Wade Spires on 3/18/13.
//
//

#import <UIKit/UIKit.h>

@interface MASwitchCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UISwitch *swtch;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *leadingSpaceConstraint;

- (void)setAppearanceInTable:(UITableView *)tableView;
@end
