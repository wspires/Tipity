//
//  MAFraudSettingsViewController.m
//  Tip
//
//  Created by Wade Spires on 12/7/17.
//  Copyright (c) 2017 Minds Aspire LLC. All rights reserved.
//

#import "MAFraudSettingsViewController.h"

#import "MAAppearance.h"
#import "MABill.h"
#import "MADeviceUtil.h"
#import "MAFilePaths.h"
#import "MAFraudDetector.h"
#import "MASwitchCell.h"
#import "MATextFieldCell.h"
#import "MATipIAPHelper.h"
#import "MAUIUtil.h"
#import "MAUserUtil.h"
#import "MAUtil.h"

DECL_TABLE_IDX(NUM_SECTIONS, 2);

DECL_TABLE_IDX(MODE_SECTION, 0);
DECL_TABLE_IDX(MODE_NONE_ROW, 0);
DECL_TABLE_IDX(MODE_CHECKSUM_ROW, 1);
DECL_TABLE_IDX(MODE_MIRROR_ROW, 2);
DECL_TABLE_IDX(MODE_PAIRS_ROW, 3);
DECL_TABLE_IDX(MODE_SECTION_ROWS, 4);

DECL_TABLE_IDX(EXAMPLES_SECTION, 1);

@interface MAFraudSettingsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *examples;

@end

@implementation MAFraudSettingsViewController
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
    [examples addObject:[NSNumber numberWithFloat:123.00]];
    [examples addObject:[NSNumber numberWithFloat:123.45]];
    [examples addObject:[NSNumber numberWithFloat:132.00]];
//    [examples addObject:[NSNumber numberWithFloat:124.00]];
//    [examples addObject:[NSNumber numberWithFloat:12.34]];
//    [examples addObject:[NSNumber numberWithFloat:1.23]];
//    [examples addObject:[NSNumber numberWithFloat:9.50]];
//    [examples addObject:[NSNumber numberWithFloat:12.34]];
//    [examples addObject:[NSNumber numberWithFloat:123.45]];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([self isOn])
    {
        return NUM_SECTIONS;
    }
    return NUM_SECTIONS - 1; // Skip last "Examples" section.
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == MODE_SECTION)
    {
    }
    else if (section == EXAMPLES_SECTION)
    {
        return Localize(@"Examples");
    }
    return @"";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == MODE_SECTION)
    {
        return MODE_SECTION_ROWS;
    }
    else if (section == EXAMPLES_SECTION)
    {
        return self.examples.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == MODE_SECTION)
    {
        return [self tableView:tableView selectModeCellForRowAtIndexPath:indexPath];
    }
    else if (indexPath.section == EXAMPLES_SECTION)
    {
        return [self tableView:tableView exampleCellForRowAtIndexPath:indexPath];
    }

    DLog(@"Error: Not returning a cell!");
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView selectModeCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * const cellIdentifier = @"selectModeCellForRowAtIndexPath";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[MASwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }

    UIImage *image = nil;
    NSString *text = nil;
    NSString *settingValue = nil;
    if (indexPath.row == MODE_NONE_ROW)
    {
        image = [MAFilePaths fraudNoneImage];
        settingValue = FraudModeNone;
    }
    else if (indexPath.row == MODE_CHECKSUM_ROW)
    {
        image = [MAFilePaths fraudChecksumImage];
        settingValue = FraudModeChecksum;
    }
    else if (indexPath.row == MODE_MIRROR_ROW)
    {
        image = [MAFilePaths fraudMirrorImage];
        settingValue = FraudModeMirror;
    }
    else if (indexPath.row == MODE_PAIRS_ROW)
    {
        image = [MAFilePaths fraudPairsImage];
        settingValue = FraudModePairs;
    }
    text = [MAFraudDetector printableNameForMode:settingValue];

    cell.imageView.image = image;
    cell.textLabel.text = text;

    NSString *currentSetting = [[MAUserUtil sharedInstance] objectForKey:FraudMode];
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

    NSString *labelText = Localize(@"Grand Total");
    UIImage *image = [MAFilePaths totalImage];
    cell.textLabel.text = labelText;
    cell.imageView.image = image;

    NSNumber *originalNumber = [self.examples objectAtIndex:indexPath.row];

    NSString *currentSetting = [[MAUserUtil sharedInstance] objectForKey:FraudMode];
    MAFraudDetector *detector = [[MAFraudDetector alloc] initWithMode:currentSetting];
    NSNumber *adjustedNumber = [detector adjustNumber:originalNumber];

    NSString *formattedOriginalNumber = [MABill formatPrice:originalNumber];
    NSString *formattedAdjustedNumber = [MABill formatPrice:adjustedNumber];
    LOG_S(@"formattedOriginalNumber = %@, formattedAdjustedNumber = %@, adjustedNumber = %@", formattedOriginalNumber, formattedAdjustedNumber, adjustedNumber);

    // https://en.wikipedia.org/wiki/Arrow_(symbol)
    NSString *direction = @"→";
    //    NSString *direction = @"↱";

    NSString *text = SFmt(@"%@ %@ %@", formattedOriginalNumber, direction, formattedAdjustedNumber);
    LOG_S(@"text = %@", text);

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
    if (indexPath.section == MODE_SECTION)
    {
        settingKey = FraudMode;
        if (indexPath.row == MODE_NONE_ROW)
        {
            settingValue = FraudModeNone;
            deleteSections = [self isOn];
        }
        else if (indexPath.row == MODE_CHECKSUM_ROW)
        {
            settingValue = FraudModeChecksum;
            addSections = [self isOff];
        }
        else if (indexPath.row == MODE_MIRROR_ROW)
        {
            settingValue = FraudModeMirror;
            addSections = [self isOff];
        }
        else if (indexPath.row == MODE_PAIRS_ROW)
        {
            settingValue = FraudModePairs;
            addSections = [self isOff];
        }
    }
    [[MAUserUtil sharedInstance] saveSetting:settingValue forKey:settingKey];

    // Note: consider turning off rounding setting. Currently, apply fraud detection after rounding, which seems to be consistent.

    NSRange range = NSMakeRange(0, [self numberOfSectionsInTableView:self.tableView]);
    NSIndexSet *sections = [NSIndexSet indexSetWithIndexesInRange:range];
    [self.tableView beginUpdates];
    if (addSections || deleteSections)
    {
        NSMutableIndexSet *sectionsToReload = [[NSMutableIndexSet alloc] init];
        [sectionsToReload addIndex:MODE_SECTION];

        NSMutableIndexSet *sectionsToEdit = [[NSMutableIndexSet alloc] init];
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

- (BOOL)isOff
{
    return [[MAUserUtil sharedInstance] fraudDetectionOff];
}
- (BOOL)isOn
{
    return [[MAUserUtil sharedInstance] fraudDetectionOn];
}
- (BOOL)isChecksum
{
    return [[MAUserUtil sharedInstance] fraudDetectionChecksum];
}
- (BOOL)isMirror
{
    return [[MAUserUtil sharedInstance] fraudDetectionMirror];
}
- (BOOL)isPairs
{
    return [[MAUserUtil sharedInstance] fraudDetectionPairs];
}

static CGFloat const Short_Footer_Height = 44.;
static CGFloat const Tall_Footer_Height = 2 * Short_Footer_Height;
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    CGFloat height = Short_Footer_Height;

    NSString *text = nil;

    if (section == MODE_SECTION)
    {
        if ([self isOff])
        {
            height = Tall_Footer_Height;
            text = Localize(@"Select a fraud detection method to verify that restaurant charges on your credit statement also follow the method.");
//            text = Localize(@"Verify restaurant charges on your credit statement by adjusting the grand total with a fraud detection method. The dollars and cents on your statement should follow the method that you select.");
//            text = Localize(@"Select a fraud detection method to adjust the grand total to verify restaurant charges on credit statement.");
        }
        else if ([self isChecksum])
        {
            text = Localize(@"Adjusts cents in the grand total by adding the digits in the dollars.");
        }
        else if ([self isMirror])
        {
            text = Localize(@"Adjusts cents in the grand total by mirroring the dollars.");
        }
        else if ([self isPairs])
        {
            text = Localize(@"Adjusts cents in the grand total by repeating the dollars.");
        }
        else
        {
            text = Localize(@"Turns off fraud detection.");
        }
    }
    else if (section == EXAMPLES_SECTION)
    {
        if ([self isChecksum])
        {
            // Additional help for checksum, assuming examples are $123.
            text = Localize(@"Calculates cents as 1 + 2 + 3 = 6.");
        }
    }

    if ( ! text)
    {
        return nil;
    }

    CGRect footerRect = CGRectMake(50, 0, tableView.frame.size.width, height);
    UITextView *tableFooter = [[UITextView alloc] initWithFrame:footerRect];
    tableFooter.editable = NO;
    tableFooter.scrollEnabled = NO;

    tableFooter.textColor = [MAAppearance tableTextFontColor];
    tableFooter.backgroundColor = [tableView backgroundColor];

    tableFooter.text = text;

    // Note: must override heightForFooterInSection in order for this to have an effect.
    //tableView.tableFooterView = tableFooter;
    return tableFooter;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == MODE_SECTION)
    {
        if ([self isOff])
        {
            return Tall_Footer_Height;
        }
        return Short_Footer_Height;
    }
    if (section == EXAMPLES_SECTION)
    {
        return Short_Footer_Height;
    }
    return 0;
}

@end

