//
//  MASettingsViewController.m
//  Gym Log
//
//  Created by Wade Spires on 7/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MASettingsViewController.h"

#import "MAAccessoryView.h"
#import "MAAppearance.h"
#import "MAAppearanceSelectionViewController.h"
#import "MACreditsViewController.h"
#import "MAFilePaths.h"
#import "MAProductTableViewCell.h"
#import "MASwitchCell.h"
#import "MATipIAPHelper.h"
#import "MAUserUtil.h"
#import "MAUtil.h"

#import <MessageUI/MFMailComposeViewController.h>
#import <QuartzCore/QuartzCore.h>
#import <StoreKit/StoreKit.h>

DECL_TABLE_IDX(NUM_SECTIONS, 3);

DECL_TABLE_IDX(GEN_SECTION, 0);
DECL_TABLE_IDX(ENABLE_SPLIT_TIP_ROW, 0);
DECL_TABLE_IDX(APPEARANCE_ROW, 1);
DECL_TABLE_IDX(GEN_SECTION_ROWS, 2);

DECL_TABLE_IDX(APPS_SECTION, 1);

DECL_TABLE_IDX(INFO_SECTION, 2);
DECL_TABLE_IDX(TELL_FRIEND_ROW, 0);
DECL_TABLE_IDX(SUPPORT_ROW, 1);
DECL_TABLE_IDX(REVIEW_ROW, 2);
DECL_TABLE_IDX(CREDITS_ROW, 3);
DECL_TABLE_IDX(VERSION_ROW, 4);
DECL_TABLE_IDX(INFO_SECTION_ROWS, 5);

DECL_TABLE_IDX(DESC_SECTION, 98);
DECL_TABLE_IDX(NO_DESC_ROW, 0);
DECL_TABLE_IDX(USE_DESC_ROW, 1);
DECL_TABLE_IDX(DESC_SECTION_ROWS, 2);

DECL_TABLE_IDX(SIZE_SECTION, 99);
DECL_TABLE_IDX(NO_SIZE_ROW, 0);
DECL_TABLE_IDX(USE_SIZE_ROW, 1);
DECL_TABLE_IDX(SIZE_SECTION_ROWS, 2);

static NSString *MASwitchCellIdentifier = @"MASwitchCellIdentifier";
static NSString *MAProductTableViewCellIdentifier = @"MAProductTableViewCellIdentifier";

@interface MASettingsViewController ()
@property (strong, nonatomic) MAAppearanceSelectionViewController *customizeColorController;
@property (strong, nonatomic) MACreditsViewController *creditsController;
@property (strong, nonatomic) NSArray *appList;

- (void)handleReview;
- (void)openReviewURL;

- (void)sendFeedbackEmail;
@end

@implementation MASettingsViewController
@synthesize tableView = _tableView;
@synthesize customizeColorController = _customizeColorController;
@synthesize creditsController = _creditsController;
@synthesize appList = _appList;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = Localize(@"Settings");
        self.tabBarItem.image = [UIImage imageNamed:@"19-gear"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[self view] setBackgroundColor:[MAAppearance backgroundColor]];
    [MAUtil setAdjustableNavTitle:self.navigationItem.title withNavigationItem:self.navigationItem];

    [self registerNibs];
    
    // Make the table background clear, so that this view's background shows.
    [MAAppearance clearBackgroundForTableView:self.tableView];
    [MAAppearance setSeparatorStyleForTable:self.tableView];

    if (ABOVE_IOS7)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    self.appList = [self makeAppList];
}

- (void)registerNibs
{
    UINib *nib = nil;
    
    nib = [UINib nibWithNibName:@"MASwitchCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:MASwitchCellIdentifier];
    
    nib = [UINib nibWithNibName:@"MAProductTableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:MAProductTableViewCellIdentifier];
}

- (NSArray *)makeAppList
{
    NSMutableArray *appList = [[NSMutableArray alloc] init];

    NSMutableDictionary *appInfo = nil;
    NSString *baseUrl = @"http://itunes.apple.com/app/id";

    appInfo = [[NSMutableDictionary alloc] init];
    [appInfo setObject:Localize(@"Gym Log+") forKey:@"name"];
    [appInfo setObject:Localize(@"Workout and Fitness Log") forKey:@"description"];
    [appInfo setObject:[UIImage imageNamed:@"Gym Log+ - Icon.png"] forKey:@"image"];
    [appInfo setObject:SFmt(@"%@%@", baseUrl, @"871239624") forKey:@"link"];
    [appList addObject:appInfo];

    appInfo = [[NSMutableDictionary alloc] init];
    [appInfo setObject:Localize(@"Weight Log+") forKey:@"name"];
    [appInfo setObject:Localize(@"Body Weight Tracker") forKey:@"description"];
    [appInfo setObject:[UIImage imageNamed:@"Weight Log+ - Icon.png"] forKey:@"image"];
    [appInfo setObject:SFmt(@"%@%@", baseUrl, @"662452352") forKey:@"link"];
    [appList addObject:appInfo];

    appInfo = [[NSMutableDictionary alloc] init];
    [appInfo setObject:Localize(@"Paper Towel Picker") forKey:@"name"];
    [appInfo setObject:Localize(@"Compare Grocery Prices") forKey:@"description"];
    [appInfo setObject:[UIImage imageNamed:@"Unit Price - Icon.png"] forKey:@"image"];
    [appInfo setObject:SFmt(@"%@%@", baseUrl, @"914223424") forKey:@"link"];
    [appList addObject:appInfo];

    appInfo = [[NSMutableDictionary alloc] init];
    [appInfo setObject:Localize(@"Mat Calc") forKey:@"name"];
    [appInfo setObject:Localize(@"Matrix Math Calculator") forKey:@"description"];
    [appInfo setObject:[UIImage imageNamed:@"Mat Calc - Icon.png"] forKey:@"image"];
    [appInfo setObject:SFmt(@"%@%@", baseUrl, @"531168194") forKey:@"link"];
    [appList addObject:appInfo];

    return appList;
}

- (void)viewWillAppear:(BOOL)animated
{
    [[self view] setBackgroundColor:[MAAppearance backgroundColor]];
    [MAUtil updateNavItem:self.navigationItem withTitle:self.title];

    // Not reloading the table each time it appears to make it snappier since it should not have changed between views changing.
    // BUT: We need to reload the app colors for the icons!
    [self.tableView reloadData];
    
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)loadCustomizeColorController:(NSIndexPath *)indexPath
{
    if (self.customizeColorController == nil)
    {
        self.customizeColorController = [[MAAppearanceSelectionViewController alloc] initWithNibName:@"MAAppearanceSelectionViewController" bundle:nil];
    }
    
    self.customizeColorController.title = Localize(@"Color");
    [self.navigationController pushViewController:self.customizeColorController animated:YES];
}

- (void)handleApp:(NSIndexPath *)indexPath
{
    NSDictionary *appInfo = [self.appList objectAtIndex:indexPath.row];
    NSString *link = [appInfo objectForKey:@"link"];
    BOOL const openedURL = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:link]];
    if ( ! openedURL)
    {
        DLog(@"Failed to open URL '%@'", link);
    }

    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)handleReview
{
    [self openReviewURL];
    
    NSIndexPath *selection = [NSIndexPath indexPathForRow:REVIEW_ROW inSection:INFO_SECTION];
    [self.tableView deselectRowAtIndexPath:selection animated:YES];
}

- (void)openReviewURL
{
    // App store URLs may differ by iOS version.
    // http://stackoverflow.com/questions/18905686/itunes-review-url-and-ios-7-ask-user-to-rate-our-app-appstore-show-a-blank-pag
    static NSString * templateReviewURL = @"itms-apps://itunes.apple.com/app/id";

    NSString *reviewURL = [NSString stringWithFormat:@"%@%@", templateReviewURL, APP_ID];
    DLog(@"Opening app review URL '%@'", reviewURL);
    BOOL const openedURL = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:reviewURL]];
    if (!openedURL)
    {
        DLog(@"Failed to open URL");
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return NUM_SECTIONS;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == SIZE_SECTION)
    {
//        return Localize(@"Item Format");
        return Localize(@"Size Per Unit");
    }
    else if (section == DESC_SECTION)
    {
        return Localize(@"Price Per Unit");
    }
    else if (section == GEN_SECTION)
    {
        return Localize(@"General");
    }
    else if (section == APPS_SECTION)
    {
        return Localize(@"More Apps");
    }
    else if (section == INFO_SECTION)
    {
        return Localize(@"Information");
    }
    return @"";
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (section == SIZE_SECTION)
    {
//        return Localize(@"Enable size to enter size per unit, such as sheets per roll.");
//        return Localize(@"Disable or enable entering size per unit, such as sheets per roll.");
//        return Localize(@"Hide or enable entering size per unit, such as sheets per roll.");
        return Localize(@"Hide or show size per unit, such as sheets per roll.");
    }
    else if (section == DESC_SECTION)
    {
        return Localize(@"Hide or show price per unit.");
    }
    return @"";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == SIZE_SECTION)
    {
        return SIZE_SECTION_ROWS;
    }
    else if (section == DESC_SECTION)
    {
        return DESC_SECTION_ROWS;
    }
    else if (section == GEN_SECTION)
    {
        return GEN_SECTION_ROWS;
    }
    else if (section == APPS_SECTION)
    {
        return self.appList.count;
    }
    else if (section == INFO_SECTION)
    {
        return INFO_SECTION_ROWS;
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    if ( ! [view isKindOfClass:[UITableViewHeaderFooterView class]])
    {
        return;
    }
    UITableViewHeaderFooterView *headerView = (UITableViewHeaderFooterView *)view;
    headerView.textLabel.textColor = [MAAppearance headerLabelTextColor];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == SIZE_SECTION)
    {
        return [self tableView:tableView setSizeCellForRowAtIndexPath:indexPath];
    }
    else if (indexPath.section == DESC_SECTION)
    {
        return [self tableView:tableView setDescriptionCellForRowAtIndexPath:indexPath];
    }
    else if (indexPath.section == GEN_SECTION)
    {
        if (indexPath.row == APPEARANCE_ROW)
        {
            return [self tableView:tableView appearanceCellForRowAtIndexPath:indexPath];
        }
        else if (indexPath.row == ENABLE_SPLIT_TIP_ROW)
        {
            return [self tableView:tableView splitTipCellForRowAtIndexPath:indexPath];
        }
    }
    else if (indexPath.section == APPS_SECTION)
    {
        return [self tableView:tableView appsCellForRowAtIndexPath:indexPath];
    }
    else if (indexPath.section == INFO_SECTION)
    {
        static NSString * const CellIdentifier = @"Information";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        [MAAppearance setAppearanceForCell:cell tableStyle:tableView.style];

        // Reset fields.
        cell.textLabel.text = @"";
        cell.detailTextLabel.text = @"";
        cell.imageView.image = nil;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        if (indexPath.row == SUPPORT_ROW)
        {
            cell.textLabel.text = Localize(@"Send Feedback");
        }
        else if (indexPath.row == TELL_FRIEND_ROW)
        {
            cell.textLabel.text = Localize(@"Tell a Friend");
        }
        else if (indexPath.row == REVIEW_ROW)
        {
            //cell.textLabel.text = SFmt(Localize(@"Love %@? Rate us!"), APP_NAME);
            cell.textLabel.text = Localize(@"Write a Review");
            cell.textLabel.adjustsFontSizeToFitWidth = YES;
        }
        else if (indexPath.row == CREDITS_ROW)
        {
            cell.textLabel.text = Localize(@"Credits");
        }
        else if (indexPath.row == VERSION_ROW)
        {
            NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
            cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", Localize(@"Version"), version];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }

        if (indexPath.row != VERSION_ROW)
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.accessoryView = [MAAccessoryView grayAccessoryViewForCell:cell];
        }
        return cell;
    }

    DLog(@"Error: Not returning a cell!");
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView setSizeCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MAProductTableViewCell *cell = (MAProductTableViewCell *)[tableView dequeueReusableCellWithIdentifier:MAProductTableViewCellIdentifier];
    if (cell == nil)
    {
        cell = [[MAProductTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MAProductTableViewCellIdentifier];
    }
    [MAAppearance setAppearanceForCell:cell tableStyle:tableView.style];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    cell.userInteractionEnabled = NO;
    cell.hideIconView = YES;
    cell.hideDescription = YES;
    [cell configureWithProduct:nil];

    BOOL enableSizeField = [[MAUserUtil sharedInstance] enableSizeField];
    
    if (indexPath.row == NO_SIZE_ROW)
    {
        cell.hideSizeField = YES;
        
        if ( ! enableSizeField)
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    else if (indexPath.row == USE_SIZE_ROW)
    {
        cell.hideSizeField = NO;
        
        if (enableSizeField)
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView setDescriptionCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MAProductTableViewCell *cell = (MAProductTableViewCell *)[tableView dequeueReusableCellWithIdentifier:MAProductTableViewCellIdentifier];
    if (cell == nil)
    {
        cell = [[MAProductTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MAProductTableViewCellIdentifier];
    }
    [MAAppearance setAppearanceForCell:cell tableStyle:tableView.style];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.userInteractionEnabled = NO;
    cell.hideIconView = YES;
    
    MAProduct *product = [[MAProduct alloc] init];
    [cell configureWithProduct:product];

    BOOL enableSizeField = [[MAUserUtil sharedInstance] enableSizeField];
    BOOL const hideSizeField = ! enableSizeField;
    cell.hideSizeField = hideSizeField;

    BOOL enableDesc = [[MAUserUtil sharedInstance] enableDescription];
    
    if (indexPath.row == NO_DESC_ROW)
    {
        cell.hideDescription = YES;
        
        if ( ! enableDesc)
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    else if (indexPath.row == USE_SIZE_ROW)
    {
        cell.hideDescription = NO;
        
        if (enableDesc)
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView appearanceCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * const CellIdentifier = @"MAAppearanceSelectionSettingsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    [MAAppearance setAppearanceForCell:cell tableStyle:tableView.style];
    
    cell.textLabel.text = Localize(@"Color");
    
    if (Customize_Color_Iap)
    {
        [MATipIAPHelper disableLabelIfNotPurchased:cell.textLabel];
    }

    UIImage *image = [MAFilePaths applyEffectsToImagePath:[MAFilePaths appearanceImageFilename]];
    cell.imageView.image = image;
//    UIImage *image = [MAFilePaths appearanceImage];
//    NSInteger tag = [MAUtil toTag:indexPath];
//    [MAUtil setImage:image forCell:cell withTag:tag];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.accessoryView = [MAAccessoryView grayAccessoryViewForCell:cell];
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView splitTipCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MASwitchCell *cell = (MASwitchCell *)[tableView dequeueReusableCellWithIdentifier:MASwitchCellIdentifier];
    if (cell == nil)
    {
        cell = [[MASwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MASwitchCellIdentifier];
    }
    //[MAAppearance setAppearanceForCell:cell tableStyle:tableView.style];
    [cell setAppearanceInTable:tableView];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.label.backgroundColor = [UIColor clearColor];
    NSString *text = Localize(@"Split Tip");
    [cell.label setText:text];
    //[MAAppearance setFontForCellLabel:cell.label];
    [MAAppearance setFontForCell:cell tableStyle:tableView.style];
    
    [MATipIAPHelper disableLabelIfNotPurchased:cell.label];
    
    cell.label.adjustsFontSizeToFitWidth = YES;
    
    BOOL enable = [[MAUserUtil sharedInstance] enableSplit];
    cell.swtch.on = enable;
    
    [cell.swtch removeTarget:nil action:NULL forControlEvents:UIControlEventValueChanged];
    [cell.swtch addTarget:self action:@selector(splitSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    
    [MAAppearance setColorForSwitch:cell.swtch];
    
//    UIImage *image = [MAFilePaths applyEffectsToImagePath:@"1079-fork-path.png"];
    UIImage *image = [MAFilePaths applyEffectsToImagePath:@"895-user-group.png"];
    cell.imageView.image = image;
    cell.leadingSpaceConstraint.constant = 58; // cell.imageView.frame.size.width;

    return cell;
}

- (IBAction)splitSwitchChanged:(id)sender
{
    UISwitch *swtch = (UISwitch *)sender;
    
    if ([MATipIAPHelper checkAndAlertForIAP])
    {
        swtch.on = NO;
        return;
    }
    
    [[MAUserUtil sharedInstance] setEnableSplit:swtch.isOn];
}

- (UITableViewCell *)tableView:(UITableView *)tableView appsCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * const CellIdentifier = @"MAAppsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    [MAAppearance setAppearanceForCell:cell tableStyle:tableView.style];
    
    NSDictionary *appInfo = [self.appList objectAtIndex:indexPath.row];
    NSString *name = [appInfo objectForKey:@"name"];
    NSString *description = [appInfo objectForKey:@"description"];
    UIImage *image = [appInfo objectForKey:@"image"];

    cell.textLabel.text = name;
    cell.detailTextLabel.text = description;

    cell.imageView.image = image;
    cell.imageView.layer.cornerRadius = 9.0;
    cell.imageView.layer.masksToBounds = YES;

    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.accessoryView = [MAAccessoryView grayAccessoryViewForCell:cell];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == DESC_SECTION)
    {
        MAProductTableViewCell *cell = (MAProductTableViewCell *)[self tableView:self.tableView setDescriptionCellForRowAtIndexPath:indexPath];
        return cell.rowHeight;
    }
    
    CGFloat rowHeight = [MAUtil rowHeightForTableView:tableView];
    return rowHeight;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == SIZE_SECTION)
    {
        if (Size_Per_Unit_Iap && [MATipIAPHelper checkAndAlertForIAP])
        {
            return;
        }
        [self selectSetSizeRow:indexPath];
    }
    else if (indexPath.section == DESC_SECTION)
    {
        if (Price_Per_Unit_Iap && [MATipIAPHelper checkAndAlertForIAP])
        {
            return;
        }
        [self selectSetDescRow:indexPath];
    }
    else if (indexPath.section == GEN_SECTION)
    {
        if (indexPath.row == APPEARANCE_ROW)
        {
            if (Customize_Color_Iap && [MATipIAPHelper checkAndAlertForIAP])
            {
                return;
            }
            [self loadCustomizeColorController:indexPath];
        }
    }
    else if (indexPath.section == APPS_SECTION)
    {
        [self handleApp:indexPath];
    }
    else if (indexPath.section == INFO_SECTION)
    {
        if (indexPath.row == REVIEW_ROW)
        {
            [self handleReview];
        }
        else if (indexPath.row == SUPPORT_ROW)
        {
            [self sendFeedbackEmail];
        }
        else if (indexPath.row == TELL_FRIEND_ROW)
        {
            [self tellAFriend];
        }
        else if (indexPath.row == CREDITS_ROW)
        {
            [self loadCreditsController];
        }
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)selectSetSizeRow:(NSIndexPath *)indexPath
{
    BOOL enableSizeField = [[MAUserUtil sharedInstance] enableSizeField];
    
    // Check if setting did not actually change.
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == NO_SIZE_ROW)
    {
        if ( ! enableSizeField)
        {
            return;
        }
    }
    else if (indexPath.row == USE_SIZE_ROW)
    {
        if (enableSizeField)
        {
            return;
        }
    }
    
    // Toggle and save new setting.
    [[MAUserUtil sharedInstance] setEnableSizeField: ! enableSizeField];
    [self.tableView reloadData];
}


- (void)selectSetDescRow:(NSIndexPath *)indexPath
{
    BOOL enableDesc = [[MAUserUtil sharedInstance] enableDescription];
    
    // Check if setting did not actually change.
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == NO_DESC_ROW)
    {
        if ( ! enableDesc)
        {
            return;
        }
    }
    else if (indexPath.row == USE_DESC_ROW)
    {
        if (enableDesc)
        {
            return;
        }
    }
    
    // Toggle and save new setting.
    [[MAUserUtil sharedInstance] setEnableDescription: ! enableDesc];
    [self.tableView reloadData];
}

#pragma mark - Email

- (void)sendFeedbackEmail
{
    MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    
    NSString *appName = APP_NAME; //[[[NSBundle mainBundle] localizedInfoDictionary] objectForKey:@"CFBundleDisplayName"];

    NSString *toAddr = @"<support@gymlogplus.com>";
    NSArray *recipients = [NSArray arrayWithObjects:toAddr, nil];
    [controller setToRecipients:recipients];

    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    NSString *deviceModel = [UIDevice currentDevice].model;
    NSString *systemVersion = [UIDevice currentDevice].systemVersion;

    NSString *subject = [NSString stringWithFormat:@"%@ %@ %@ (%@ %@)", appName, version,
                         Localize(@"Feedback"), deviceModel, systemVersion];
    [controller setSubject:subject];
    
    NSString *body = @"";
    [controller setMessageBody:body isHTML:NO];
        
    if (controller)
    {
        [self presentViewController:controller animated:YES completion:NULL];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    if (result == MFMailComposeResultSent)
    {
        DLog(@"Email message sent!");
    }
    if (error)
    {
        DLog(@"Error sending email: %@", error);
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)tellAFriend
{
    MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    
    NSString *appName = APP_NAME; //[[[NSBundle mainBundle] localizedInfoDictionary] objectForKey:@"CFBundleDisplayName"];
    
    NSArray *recipients = [NSArray arrayWithObjects:nil];
    [controller setToRecipients:recipients];
    
    NSString *subject = [NSString stringWithFormat:@"Have you tried %@?", appName];
    [controller setSubject:subject];
    
    NSString *urlString = [self appURL];
    //NSString *body = Localize(@"Download today from the App Store.");
    NSString *body = SFmt(Localize(@"I've been using %@ and think you'll like it, too. Check it out on the App Store!"), appName);
    body = SFmt(@"%@\n%@", body, urlString);
    [controller setMessageBody:body isHTML:NO];
    
    if (controller)
    {
        [self presentViewController:controller animated:YES completion:NULL];
    }
}

- (NSString *)appURL
{
    NSString *urlString = [NSString stringWithFormat:@"http://itunes.apple.com/app/id%@", APP_ID];
    return urlString;
}

- (void)loadCreditsController
{
    if (self.creditsController == nil)
    {
        self.creditsController = [[MACreditsViewController alloc]
                                    initWithNibName:@"MACreditsViewController"
                                    bundle:nil];
    }
    
    self.creditsController.title = Localize(@"Credits");
    [self.navigationController pushViewController:self.creditsController animated:YES];
}

@end
