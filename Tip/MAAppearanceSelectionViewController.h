//
//  MAAppearanceSelectionViewController.h
//  Gym Log
//
//  Created by Wade Spires on 10/7/13.
//
//

#import <UIKit/UIKit.h>
#import "MOGlassButton.h"

@interface MAAppearanceSelectionViewController : UIViewController
<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet MOGlassButton *testBtn;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
