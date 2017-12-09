//
//  MARoundingSettingsViewController.m
//  Tip
//
//  Created by Wade Spires on 5/6/15.
//  Copyright (c) 2015 Minds Aspire LLC. All rights reserved.
//

#import "MARoundingSettingsViewController.h"

#import "MAAppearance.h"
#import "MABill.h"
#import "MADeviceUtil.h"
#import "MAFilePaths.h"
#import "MARounder.h"
#import "MASwitchCell.h"
#import "MATextFieldCell.h"
#import "MAUIUtil.h"
#import "MAUserUtil.h"
#import "MAUtil.h"

DECL_TABLE_IDX(NUM_SECTIONS, 3);

DECL_TABLE_IDX(ROUND_SECTION, 0);
DECL_TABLE_IDX(ROUND_NONE_ROW, 0);
DECL_TABLE_IDX(ROUND_TIP_ROW, 1);
DECL_TABLE_IDX(ROUND_TOTAL_ROW, 2);
DECL_TABLE_IDX(ROUND_SECTION_ROWS, 3);

DECL_TABLE_IDX(ROUNDING_OPTIONS_SECTION, 1);
DECL_TABLE_IDX(ROUND_UP_ROW, 0);
DECL_TABLE_IDX(ROUND_DOWN_ROW, 1);
DECL_TABLE_IDX(ROUND_NEAREST_ROW, 2);
DECL_TABLE_IDX(ROUNDING_OPTIONS_SECTION_ROWS, 3);

DECL_TABLE_IDX(EXAMPLES_SECTION, 2);

@interface MARoundingSettingsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *examples;

@end

@implementation MARoundingSettingsViewController
@synthesize tableView = _tableView;
@synthesize examples = _examples;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[self view] setBackgroundColor:[MAAppearance backgroundColor]];
    [MAUIUtil setAdjustableNavTitle:self.navigationItem.title withNavigationItem:self.navigationItem];
    
    [self registerNibs];
    
    // Make the table background clear, so that this view's background shows.
    [MAAppearance clearBackgroundForTableView:self.tableView];
    [MAAppearance setSeparatorStyleForTable:self.tableView];
    
    if (ABOVE_IOS7)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    NSMutableArray *examples = [[NSMutableArray alloc] init];
    [examples addObject:[NSNumber numberWithFloat:9.50]];
    [examples addObject:[NSNumber numberWithFloat:9.49]];
    self.examples = examples;
}

- (void)registerNibs
{
    [MASwitchCell registerNibWithTableView:self.tableView];
    [MATextFieldCell registerNibWithTableView:self.tableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [[self view] setBackgroundColor:[MAAppearance backgroundColor]];
    [MAUIUtil updateNavItem:self.navigationItem withTitle:self.title];
        
    // Not reloading the table each time it appears to make it snappier since it should not have changed between views changing.
    // BUT: We need to reload the app colors for the icons!
    [self.tableView reloadData];
    
    [super viewWillAppear:animated];
}

- (BOOL)isRoundingOn
{
    return [[MAUserUtil sharedInstance] roundOn];
}
- (BOOL)isRoundingModeTip
{
    return [[MAUserUtil sharedInstance] roundTip];
}
- (BOOL)isRoundingModeTotal
{
    return [[MAUserUtil sharedInstance] roundTotal];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if ([self isRoundingOn])
    {
        return NUM_SECTIONS;
    }
    return NUM_SECTIONS - 2; // Skip last "Options" and "Examples" section.
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == ROUND_SECTION)
    {
    }
    else if (section == ROUNDING_OPTIONS_SECTION)
    {
        return Localize(@"Direction");
    }
    else if (section == EXAMPLES_SECTION)
    {
        return Localize(@"Examples");
    }
    return @"";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == ROUND_SECTION)
    {
        return ROUND_SECTION_ROWS;
    }
    else if (section == ROUNDING_OPTIONS_SECTION)
    {
        return ROUNDING_OPTIONS_SECTION_ROWS;
    }
    else if (section == EXAMPLES_SECTION)
    {
        return self.examples.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == ROUND_SECTION)
    {
        return [self tableView:tableView selectRoundCellForRowAtIndexPath:indexPath];
    }
    else if (indexPath.section == ROUNDING_OPTIONS_SECTION)
    {
        return [self tableView:tableView selectRoundingModeCellForRowAtIndexPath:indexPath];
    }
    else if (indexPath.section == EXAMPLES_SECTION)
    {
        return [self tableView:tableView exampleCellForRowAtIndexPath:indexPath];
    }
    
    DLog(@"Error: Not returning a cell!");
    return nil;
}


- (UITableViewCell *)tableView:(UITableView *)tableView selectRoundCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * const cellIdentifier = @"selectRoundCellForRowAtIndexPath";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[MASwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    UIImage *image = nil;
    NSString *text = nil;
    NSString *settingValue = nil;
    if (indexPath.row == ROUND_NONE_ROW)
    {
        image = [MAFilePaths roundNoneImage];
        text = Localize(@"Off");
        settingValue = RoundItemNone;
    }
    else if (indexPath.row == ROUND_TIP_ROW)
    {
        image = [MAFilePaths tipAmountImage];
        text = Localize(@"Round Tip Amount");
        settingValue = RoundItemTip;
    }
    else if (indexPath.row == ROUND_TOTAL_ROW)
    {
        image = [MAFilePaths totalImage];
        text = Localize(@"Round Grand Total");
        settingValue = RoundItemTotal;
    }
    
    cell.imageView.image = image;
    cell.textLabel.text = text;
    
    NSString *currentValue = [[MAUserUtil sharedInstance] objectForKey:RoundItem];
    BOOL isCurrentSetting = [currentValue isEqualToString:settingValue];
    if (isCurrentSetting)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView selectRoundingModeCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * const cellIdentifier = @"selectRoundingModeCellForRowAtIndexPath";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[MASwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }

    UIImage *image = nil;
    NSString *text = nil;
    NSString *settingValue = nil;
    if (indexPath.row == ROUND_UP_ROW)
    {
        image = [MAFilePaths roundUpImage];
        settingValue = RoundingModeUp;
    }
    else if (indexPath.row == ROUND_DOWN_ROW)
    {
        image = [MAFilePaths roundDownImage];
        settingValue = RoundingModeDown;
    }
    else if (indexPath.row == ROUND_NEAREST_ROW)
    {
        image = [MAFilePaths roundNearestImage];
        settingValue = RoundingModeNear;
    }
    text = [MARounder printableNameForMode:settingValue];

    cell.imageView.image = image;
    cell.textLabel.text = text;

    NSString *currentSetting = [[MAUserUtil sharedInstance] objectForKey:RoundingMode];
    BOOL isCurrentSetting = [currentSetting isEqualToString:settingValue];
    if (isCurrentSetting)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView exampleCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * const cellIdentifier = @"exampleCellForRowAtIndexPath";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[MASwitchCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSString *labelText = nil;
    UIImage *image = nil;
    if ([self isRoundingModeTip])
    {
        labelText = Localize(@"Tip Amount");
        image = [MAFilePaths tipAmountImage];
    }
    else if ([self isRoundingModeTotal])
    {
        labelText = Localize(@"Grand Total");
        image = [MAFilePaths totalImage];
    }
    cell.textLabel.text = labelText;
    cell.imageView.image = image;

    NSNumber *originalNumber = [self.examples objectAtIndex:indexPath.row];
    
    NSString *currentSetting = [[MAUserUtil sharedInstance] objectForKey:RoundingMode];
    MARounder *rounder = [[MARounder alloc] initWithMode:currentSetting];
    NSNumber *roundedNumber = [rounder roundNumber:originalNumber];
    
    NSString *formattedOriginalNumber = [MABill formatPrice:originalNumber];
    NSString *formattedRoundedNumber = [MABill formatPrice:roundedNumber];
    
    // https://en.wikipedia.org/wiki/Arrow_(symbol)
    NSString *direction = @"→";
//    NSString *direction = @"↱";
    
    NSString *text = SFmt(@"%@ %@ %@", formattedOriginalNumber, direction, formattedRoundedNumber);
    cell.detailTextLabel.text = text;

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.tableView.editing)
    {
        return;
    }
    
    if (indexPath.section == EXAMPLES_SECTION)
    {
        return;
    }

    BOOL deleteSections = NO;
    BOOL addSections = NO;

    NSString *settingKey = nil;
    NSString *settingValue = nil;
    if (indexPath.section == ROUND_SECTION)
    {
        settingKey = RoundItem;
        if (indexPath.row == ROUND_NONE_ROW)
        {
            settingValue = RoundItemNone;
            if ([self isRoundingOn])
            {
                deleteSections = YES;
            }
        }
        else if (indexPath.row == ROUND_TIP_ROW)
        {
            settingValue = RoundItemTip;
            if ( ! [self isRoundingOn])
            {
                addSections = YES;
            }
        }
        else if (indexPath.row == ROUND_TOTAL_ROW)
        {
            settingValue = RoundItemTotal;
            if ( ! [self isRoundingOn])
            {
                addSections = YES;
            }
        }
    }
    else if (indexPath.section == ROUNDING_OPTIONS_SECTION)
    {
        settingKey = RoundingMode;
        if (indexPath.row == ROUND_UP_ROW)
        {
            settingValue = RoundingModeUp;
        }
        else if (indexPath.row == ROUND_DOWN_ROW)
        {
            settingValue = RoundingModeDown;
        }
        else if (indexPath.row == ROUND_NEAREST_ROW)
        {
            settingValue = RoundingModeNear;
        }
    }
    [[MAUserUtil sharedInstance] saveSetting:settingValue forKey:settingKey];
    
    NSRange range = NSMakeRange(0, [self numberOfSectionsInTableView:self.tableView]);
    NSIndexSet *sections = [NSIndexSet indexSetWithIndexesInRange:range];
    [self.tableView beginUpdates];
    if (addSections || deleteSections)
    {
        NSMutableIndexSet *sectionsToReload = [[NSMutableIndexSet alloc] init];
        [sectionsToReload addIndex:ROUND_SECTION];

        NSMutableIndexSet *sectionsToEdit = [[NSMutableIndexSet alloc] init];
        [sectionsToEdit addIndex:ROUNDING_OPTIONS_SECTION];
        [sectionsToEdit addIndex:EXAMPLES_SECTION];
        if (addSections)
        {
            [self.tableView insertSections:sectionsToEdit withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        else if (deleteSections)
        {
            [self.tableView deleteSections:sectionsToEdit withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        [self.tableView reloadSections:sectionsToReload withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else
    {
        [self.tableView reloadSections:sections withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    [self.tableView endUpdates];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

static CGFloat const Footer_Height = 50.;
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == ROUND_SECTION)
    {
        CGRect footerRect = CGRectMake(50, 0, tableView.frame.size.width, Footer_Height);
        UITextView *tableFooter = [[UITextView alloc] initWithFrame:footerRect];
        tableFooter.editable = NO;
        tableFooter.scrollEnabled = NO;
        
        tableFooter.textColor = [MAAppearance tableTextFontColor];
        tableFooter.backgroundColor = [tableView backgroundColor];
        
        NSString *text = nil;
        if ([self isRoundingModeTip])
        {
            text = Localize(@"Rounds the tip amount to a whole dollar amount after entering the check total or selecting a service rating.");
        }
        else if ([self isRoundingModeTotal])
        {
            text = Localize(@"Rounds the grand total to a whole dollar amount after entering the check total or selecting a service rating.");
        }
        else
        {
            text = Localize(@"Turns off automatic rounding.");
        }

        tableFooter.text = text;
        
        // Note: must override heightForFooterInSection in order for this to have an effect.
        //tableView.tableFooterView = tableFooter;
        return tableFooter;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == ROUND_SECTION)
    {
        return Footer_Height;
    }
    return 0;
}

@end
