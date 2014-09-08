//
//  MAUpgradeAlertViewController.h
//  Gym Log
//
//  Created by Wade Spires on 6/16/14.
//
//

#import <UIKit/UIKit.h>

@interface MAUpgradeAlertViewController : UIViewController
<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
