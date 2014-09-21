//
//  MAServiceRatingSettingsViewController.m
//  Tip
//
//  Created by Wade Spires on 9/17/14.
//  Copyright (c) 2014 Minds Aspire LLC. All rights reserved.
//

#import "MAServiceRatingSettingsViewController.h"

#import "MAAppearance.h"
#import "MABill.h"
#import "MAFilePaths.h"
#import "MASwitchCell.h"
#import "MATextFieldCell.h"
#import "MATipIAPHelper.h"
#import "MAUserUtil.h"
#import "MAUtil.h"

DECL_TABLE_IDX(NUM_SECTIONS, 2);

DECL_TABLE_IDX(ENABLE_RATING_SECTION, 0);
DECL_TABLE_IDX(ENABLE_RATING_ROW, 0);
DECL_TABLE_IDX(ENABLE_RATING_SECTION_ROWS, 1);

DECL_TABLE_IDX(RATING_VALUES_SECTION, 1);
DECL_TABLE_IDX(RATING_FAIR_ROW, 0);
DECL_TABLE_IDX(RATING_GOOD_ROW, 1);
DECL_TABLE_IDX(RATING_GREAT_ROW, 2);
DECL_TABLE_IDX(RATING_VALUES_SECTION_ROWS, 3);

static NSString *MASwitchCellIdentifier = @"MASwitchCellIdentifier";
static NSString *MATextFieldCellIdentifier = @"MATextFieldCellIdentifier";

@interface MAServiceRatingSettingsViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
@property (strong, nonatomic) UITextField *activeTextField;
@property (strong, nonatomic) UIToolbar *keyboardAccessoryView;
@property (strong, nonatomic) UIBarButtonItem *doneBarButton;
@end

@implementation MAServiceRatingSettingsViewController
@synthesize activeTextField = _activeTextField;
@synthesize tableView = _tableView;
@synthesize keyboardAccessoryView = _keyboardAccessoryView;
@synthesize doneBarButton = _doneBarButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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
}

- (void)registerNibs
{
    UINib *nib = nil;
    
    nib = [UINib nibWithNibName:@"MASwitchCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:MASwitchCellIdentifier];
    
    nib = [UINib nibWithNibName:@"MATextFieldCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:MATextFieldCellIdentifier];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    [self configureInputAccessoryView];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return NUM_SECTIONS;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == ENABLE_RATING_SECTION)
    {
//        return Localize(@"General");
    }
    else if (section == RATING_VALUES_SECTION)
    {
        return Localize(@"Gratuity");
    }
    return @"";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == ENABLE_RATING_SECTION)
    {
        return ENABLE_RATING_SECTION_ROWS;
    }
    else if (section == RATING_VALUES_SECTION)
    {
        return RATING_VALUES_SECTION_ROWS;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == ENABLE_RATING_SECTION)
    {
        if (indexPath.row == ENABLE_RATING_ROW)
        {
            return [self tableView:tableView enableRatingCellForRowAtIndexPath:indexPath];
        }
    }
    else if (indexPath.section == RATING_VALUES_SECTION)
    {
        return [self tableView:tableView ratingValuesCellForRowAtIndexPath:indexPath];
    }
    
    DLog(@"Error: Not returning a cell!");
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView enableRatingCellForRowAtIndexPath:(NSIndexPath *)indexPath
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
    NSString *text = Localize(@"Service Rating");
    [cell.label setText:text];
    [MAAppearance setFontForCell:cell tableStyle:tableView.style];
    
    cell.label.adjustsFontSizeToFitWidth = YES;
    
    BOOL enable = [[MAUserUtil sharedInstance] enableServiceRating];
    cell.swtch.on = enable;
    
    [cell.swtch removeTarget:nil action:NULL forControlEvents:UIControlEventValueChanged];
    [cell.swtch addTarget:self action:@selector(enableServiceRatingChanged:) forControlEvents:UIControlEventValueChanged];
    
    [MAAppearance setColorForSwitch:cell.swtch];
    
    UIImage *image = nil;
    if (enable)
    {
        image = [MAFilePaths filledStarImage];
    }
    else
    {
        image = [MAFilePaths emptyStarImage];
    }
    cell.imageView.image = image;
    cell.leadingSpaceConstraint.constant = 58; // TODO: Figure out the image width programmatically (imageView frame does not work).
    
    return cell;
}

- (IBAction)enableServiceRatingChanged:(id)sender
{
    UISwitch *swtch = (UISwitch *)sender;
    
    if (Service_Rating_Iap && [MATipIAPHelper checkAndAlertForIAP])
    {
        swtch.on = NO;
        return;
    }
    
    [[MAUserUtil sharedInstance] setEnableServiceRating:swtch.isOn];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:ENABLE_RATING_ROW inSection:ENABLE_RATING_SECTION];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (UITableViewCell *)tableView:(UITableView *)tableView ratingValuesCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MATextFieldCell *cell = (MATextFieldCell *)[tableView dequeueReusableCellWithIdentifier:MATextFieldCellIdentifier];
    if (cell == nil)
    {
        cell = [[MATextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MATextFieldCellIdentifier];
    }
    [cell setAppearanceInTable:tableView];
    
    cell.textField.keyboardType = UIKeyboardTypeDecimalPad;
    cell.textField.delegate = self;
    
    NSString *labelText = @"";
    NSString *textFieldText = @"";
    UIImage *image = [MAFilePaths filledStarImage];
    if (indexPath.row == RATING_FAIR_ROW)
    {
        labelText = Localize(@"Fair");
        NSNumber *number = [[MAUserUtil sharedInstance] serviceRatingFair];
        textFieldText = [MABill formatTipPercent:number];
//        image = [MAFilePaths tipPercentImage];
    }
    else if (indexPath.row == RATING_GOOD_ROW)
    {
        labelText = Localize(@"Good");
        NSNumber *number = [[MAUserUtil sharedInstance] serviceRatingGood];
        textFieldText = [MABill formatTipPercent:number];
    }
    else if (indexPath.row == RATING_GREAT_ROW)
    {
        labelText = Localize(@"Great");
        NSNumber *number = [[MAUserUtil sharedInstance] serviceRatingGreat];
        textFieldText = [MABill formatTipPercent:number];
    }
    cell.textLabel.text = labelText;
    cell.textField.text = textFieldText;
    cell.imageView.image = image;
    
    cell.textField.tag = indexPath.row;
    
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
    
    if (indexPath.section == ENABLE_RATING_SECTION)
    {
        return;
    }
    
    UITextField *textField = [self textFieldForIndexPath:indexPath];
    if (textField)
    {
        [textField becomeFirstResponder];
        return;
    }
}

- (UITextField *)textFieldForIndexPath:(NSIndexPath *)indexPath
{
    if ( ! indexPath)
    {
        return nil;
    }
    
    MATextFieldCell *cell = (MATextFieldCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    if (cell)
    {
        return cell.textField;
    }
    
    return nil;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

#pragma mark - Text field

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    textField.placeholder = textField.text;
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.activeTextField = textField;
    [textField setInputAccessoryView:self.keyboardAccessoryView];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.text.length == 0)
    {
        [self.tableView reloadData];
        return;
    }
    
    [self saveRatingFromTextField:textField];
    [textField resignFirstResponder];
    [self.tableView reloadData];
}

- (void)saveRatingFromTextField:(UITextField *)textField
{
    // Save new value.
    if (textField.tag == RATING_FAIR_ROW)
    {
        [[MAUserUtil sharedInstance] saveSetting:textField.text forKey:ServiceRatingFair];
    }
    else if (textField.tag == RATING_GOOD_ROW)
    {
        [[MAUserUtil sharedInstance] saveSetting:textField.text forKey:ServiceRatingGood];
    }
    else if (textField.tag == RATING_GREAT_ROW)
    {
        [[MAUserUtil sharedInstance] saveSetting:textField.text forKey:ServiceRatingGreat];
    }
    
    // Ensure that the rating values are in order (at least that they don't jump around).
    NSNumber *serviceRating1 = [[MAUserUtil sharedInstance] serviceRatingFair];
    NSNumber *serviceRating2 = [[MAUserUtil sharedInstance] serviceRatingGood];
    if (serviceRating1.doubleValue > serviceRating2.doubleValue)
    {
        [[MAUserUtil sharedInstance] saveSetting:SFmt(@"%@", serviceRating1) forKey:ServiceRatingGood];
    }
    
    serviceRating1 = [[MAUserUtil sharedInstance] serviceRatingGood];
    serviceRating2 = [[MAUserUtil sharedInstance] serviceRatingGreat];
    if (serviceRating1.doubleValue > serviceRating2.doubleValue)
    {
        [[MAUserUtil sharedInstance] saveSetting:SFmt(@"%@", serviceRating1) forKey:ServiceRatingGreat];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    // if (textField == self.someTextField)
    {
        BOOL const shouldChangeChars = [MAUtil numTextField:textField shouldChangeCharactersInRange:range replacementString:string];
        return shouldChangeChars;
    }
    
    return YES;
}

#pragma mark - Scroll view delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)sender
{
    [self dismissKeyboard];
}

#pragma mark - Input accessory view

- (UIToolbar *)makeInputAccessoryView
{
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    toolbar.frame = CGRectMake(0, 0, self.view.frame.size.width, 44);
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    [items addObject:flexibleItem];

    self.doneBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneBarButtonTapped)];
    [items addObject:self.doneBarButton];
    
    [toolbar setItems:items animated:NO];
    
    return toolbar;
}

- (void)configureInputAccessoryView
{
    self.keyboardAccessoryView = [self makeInputAccessoryView];
}

- (void)updateInputAccessoryView
{
    // Button text defaults to blue, so set to black to match the regular keyboard button title colors.
    UIColor *barButtonColor = [UIColor blackColor];
    self.doneBarButton.tintColor = barButtonColor;
}

- (IBAction)doneBarButtonTapped
{
    [self dismissKeyboard];
}

- (IBAction)dismissKeyboard
{
    if (self.activeTextField && [self.activeTextField isFirstResponder])
    {
        [self.activeTextField resignFirstResponder];
        self.activeTextField = nil;
    }
}

@end
