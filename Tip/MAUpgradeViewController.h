//
//  MAUpgradeViewController.h
//  Gym Log
//
//  Created by Wade Spires on 4/23/14.
//
//

#import <UIKit/UIKit.h>

@interface MAUpgradeViewController : UIViewController
<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
