//
//  MAUnitsSettingsCell.h
//  Gym Log
//
//  Created by Wade Spires on 3/18/13.
//
//

#import <UIKit/UIKit.h>

@interface MAUnitsSettingsCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segCtrl;

- (void)resizeSegCtrl;
- (void)setAppearanceInTable:(UITableView *)tableView;
@end
