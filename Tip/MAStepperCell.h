//
//  MAStepperCell.h
//  Gym Log
//
//  Created by Wade Spires on 3/18/13.
//
//

#import <UIKit/UIKit.h>

@interface MAStepperCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIStepper *stepper;

- (void)setAppearanceInTable:(UITableView *)tableView;
@end
