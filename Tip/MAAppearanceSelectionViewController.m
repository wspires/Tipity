//
//  MAAppearanceSelectionViewController.m
//  Gym Log
//
//  Created by Wade Spires on 10/7/13.
//
//

#import "MAAppearanceSelectionViewController.h"

#import "MAFilePaths.h"
#import "MAUserUtil.h"
#import "MAUtil.h"
#import "MAAppearance.h"
#import "MAAppDelegate.h"
#import "UIColor+ExtraColors.h"
#import "MAAppDelegate.h"
#import "MAColorSelectionViewController.h"
#import "MAUnitsSettingsCell.h"
#import "MAAccessoryView.h"
#import "UIImage+ImageWithColor.h"
#import "FDTakeController.h"
#import "UIImage+Extensions.h"
#import "MAUnitsSettingsCell.h"
#import "MAColorUtil.h"

#define DISABLE_TEST_BUTTON

DECL_TABLE_IDX(NUM_SECTIONS, 6);

#ifdef DISABLE_TEST_BUTTON
DECL_TABLE_IDX(OTHER_COLOR_SECTION, 0);
DECL_TABLE_IDX(TABLE_TEXT_FONT, 0);
DECL_TABLE_IDX(TABBAR_COLOR_ROW, 1);
DECL_TABLE_IDX(OTHER_COLOR_ROWS, 2);
#else
DECL_TABLE_IDX(OTHER_COLOR_SECTION, 0);
DECL_TABLE_IDX(TABLE_TEXT_FONT, 0);
DECL_TABLE_IDX(BUTTON_TEXT_COLOR, 1);
DECL_TABLE_IDX(TABBAR_COLOR_ROW, 2);
DECL_TABLE_IDX(OTHER_COLOR_ROWS, 3);
#endif

DECL_TABLE_IDX(BACKGROUND_SECTION, 1);

DECL_TABLE_IDX(BACKGROUND_COLOR_SECTION, 2);
DECL_TABLE_IDX(BACKGROUND_COLOR_USE_ROW, 0);
DECL_TABLE_IDX(BACKGROUND_COLOR_SELECT_ROW, 1);
DECL_TABLE_IDX(BACKGROUND_COLOR_ROWS, 2);

DECL_TABLE_IDX(BACKGROUND_IMAGE_SECTION, 3);
DECL_TABLE_IDX(BACKGROUND_IMAGE_USE_ROW, 0);
DECL_TABLE_IDX(BACKGROUND_IMAGE_SELECT_ROW, 1);
DECL_TABLE_IDX(BACKGROUND_IMAGE_ROWS, 2);

DECL_TABLE_IDX(FOREGROUND_SECTION, 4);

DECL_TABLE_IDX(FOREGROUND_COLOR_SECTION, 5);
DECL_TABLE_IDX(FOREGROUND_COLOR_USE_ROW, 0);
DECL_TABLE_IDX(FOREGROUND_COLOR_SELECT_ROW, 1);
DECL_TABLE_IDX(FOREGROUND_COLOR_ROWS, 2);

static NSString *MAUnitsCellIdentifier = @"MAUnitsCellIdentifier";

@interface MAAppearanceSelectionViewController () <FDTakeDelegate>
@property (strong, nonatomic) NSDictionary *settings;
@property (strong, nonatomic) NSArray *backgroundColors;
@property (strong, nonatomic) NSArray *foregroundColors;
@property (copy, nonatomic) NSString *selectedBackgroundColorId;
@property (copy, nonatomic) NSString *selectedForegroundColorId;
@property (strong, nonatomic) MAColorSelectionViewController *backgroundColorSelectionController;
@property (strong, nonatomic) MAColorSelectionViewController *foregroundColorSelectionController;
@property (strong, nonatomic) FDTakeController *takePhotoController;
@end

@implementation MAAppearanceSelectionViewController
@synthesize testBtn = _testBtn;
@synthesize tableView = _tableView;

@synthesize settings = _settings;
@synthesize backgroundColors = _backgroundColors;
@synthesize foregroundColors = _foregroundColors;
@synthesize selectedBackgroundColorId = _selectedBackgroundColorId;
@synthesize selectedForegroundColorId = _selectedForegroundColorId;
@synthesize backgroundColorSelectionController = _backgroundColorSelectionController;
@synthesize foregroundColorSelectionController = _foregroundColorSelectionController;
@synthesize takePhotoController = _takePhotoController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[self view] setBackgroundColor:[MAAppearance backgroundColor]];
    [MAUtil setAdjustableNavTitle:self.navigationItem.title withNavigationItem:self.navigationItem];

    [self registerNibs];
    
    [MAAppearance clearBackgroundForTableView:self.tableView];
    
    self.backgroundColors = [self removeCustomColorsFromColorArray:[MAFilePaths loadBackgroundColors]];
    self.foregroundColors = [self removeCustomColorsFromColorArray:[MAFilePaths loadForegroundColors]];

    [self.testBtn setupAsLogButton];
    
    if (ABOVE_IOS7)
    {
        // Otherwise, tab bar covers last row of table view.
        //self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
#ifdef DISABLE_TEST_BUTTON
    // Hide button and add new constraint.
    self.testBtn.hidden = YES;
    [self.view removeConstraint:self.tableViewTopSpaceConstraint];
    NSLayoutConstraint *constraint = [NSLayoutConstraint
                                      constraintWithItem:self.view
                                      attribute:NSLayoutAttributeTop
                                      relatedBy:NSLayoutRelationEqual
                                      toItem:self.tableView
                                      attribute:NSLayoutAttributeTop
                                      multiplier:1
                                      constant:0];
    self.tableViewTopSpaceConstraint = constraint;
    [self.view addConstraint:constraint];
#endif
}

- (void)registerNibs
{
    UINib *nib = nil;
    
    nib = [UINib nibWithNibName:@"MAUnitsSettingsCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:MAUnitsCellIdentifier];
}

- (NSArray *)removeCustomColorsFromColorArray:(NSArray *)colors
{
    NSMutableArray *builtinColors = [[NSMutableArray alloc] init];
    for (NSDictionary *colorInfo in colors)
    {
        NSString *isCustom = [colorInfo objectForKey:@"isCustom"];
        BOOL const shouldRemove = isCustom && [isCustom boolValue];
        if (shouldRemove)
        {
            continue;
        }

        [builtinColors addObject:colorInfo];
    }
    return builtinColors;
}

- (void)viewWillAppear:(BOOL)animated
{
    [[self view] setBackgroundColor:[MAAppearance backgroundColor]];
    [MAUtil updateNavItem:self.navigationItem withTitle:self.title];

    self.settings = [MAUserUtil loadSettings];
    self.selectedBackgroundColorId = [self.settings objectForKey:BackgroundColorId];
    self.selectedForegroundColorId = [self.settings objectForKey:ForegroundColorId];

    [self.testBtn reloadColors];
    [self.testBtn setTextColor];
    [self.tableView reloadData];
    
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return NUM_SECTIONS;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == BACKGROUND_SECTION)
    {
        return Localize(@"Background");
    }
    else if (section == FOREGROUND_SECTION)
    {
        return Localize(@"Foreground");
    }
    else if (section == OTHER_COLOR_SECTION)
    {
        return Localize(@"Text");
    }
    return @"";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == BACKGROUND_SECTION)
    {
        return self.backgroundColors.count;
    }
    else if (section == BACKGROUND_COLOR_SECTION)
    {
        return BACKGROUND_COLOR_ROWS;
    }
    else if (section == BACKGROUND_IMAGE_SECTION)
    {
        return BACKGROUND_IMAGE_ROWS;
    }
    else if (section == FOREGROUND_SECTION)
    {
        return self.foregroundColors.count;
    }
    else if (section == FOREGROUND_COLOR_SECTION)
    {
        return FOREGROUND_COLOR_ROWS;
    }
    else if (section == OTHER_COLOR_SECTION)
    {
        if (BELOW_IOS7)
        {
            // The tab bar cannot be changed on iOS 6 and below.
            return OTHER_COLOR_ROWS - 1;
        }

        return OTHER_COLOR_ROWS;
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    if (![view isKindOfClass:[UITableViewHeaderFooterView class]])
    {
        return;
    }
    UITableViewHeaderFooterView *headerView = (UITableViewHeaderFooterView *)view;
    headerView.textLabel.textColor = [MAAppearance headerLabelTextColor];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == BACKGROUND_COLOR_SECTION || indexPath.section == FOREGROUND_COLOR_SECTION)
    {
        if (indexPath.row == BACKGROUND_COLOR_USE_ROW || indexPath.row == FOREGROUND_COLOR_USE_ROW)
        {
            return [self tableView:tableView useColorCellForRowAtIndexPath:indexPath];
        }
        else if (indexPath.row == BACKGROUND_COLOR_SELECT_ROW || indexPath.row == FOREGROUND_COLOR_SELECT_ROW)
        {
            return [self tableView:tableView selectColorCellForRowAtIndexPath:indexPath];
        }
    }
    else if (indexPath.section == BACKGROUND_IMAGE_SECTION)
    {
        if (indexPath.row == BACKGROUND_IMAGE_USE_ROW)
        {
            return [self tableView:tableView useImageCellForRowAtIndexPath:indexPath];
        }
        else if (indexPath.row == BACKGROUND_IMAGE_SELECT_ROW)
        {
            return [self tableView:tableView selectImageCellForRowAtIndexPath:indexPath];
        }
    }
    else if (indexPath.section == OTHER_COLOR_SECTION)
    {
        if (indexPath.row == TABBAR_COLOR_ROW)
        {
            return [self tableView:tableView tabBarColorCellForRowAtIndexPath:indexPath];
        }
#ifndef DISABLE_TEST_BUTTON
        else if (indexPath.row == BUTTON_TEXT_COLOR)
        {
            return [self tableView:tableView buttonTextColorCellForRowAtIndexPath:indexPath];
        }
#endif
        else if (indexPath.row == TABLE_TEXT_FONT)
        {
            return [self tableView:tableView tableTextFontCellForRowAtIndexPath:indexPath];
        }
    }
    
    static NSString *CellIdentifier = @"MAAppearanceSelectionCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    [MAAppearance setAppearanceForCell:cell tableStyle:tableView.style];
    
    NSArray *colors = self.backgroundColors;
    NSString *selectedColorId = self.selectedBackgroundColorId;
    if (indexPath.section == FOREGROUND_SECTION)
    {
        colors = self.foregroundColors;
        selectedColorId = self.selectedForegroundColorId;
    }
    NSDictionary *colorInfo = [colors objectAtIndex:indexPath.row];
    NSString *colorId = [colorInfo objectForKey:@"id"];
    NSString *colorName = [colorInfo objectForKey:@"visibleName"];
    UIColor *color = [colorInfo objectForKey:@"color"];
    
    cell.textLabel.text = colorName;

    UIImage *image = [UIImage imageNamed:[MAFilePaths blankImageFilename]];
    image = [MAAppearance tintImage:image tintColor:color];
    NSInteger tag = [MAUtil toTag:indexPath];
    [MAUtil setImage:image forCell:cell withTag:tag];
    
    if ([colorId isEqualToString:selectedColorId])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView useColorCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MAColorSelectionCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    [MAAppearance setAppearanceForCell:cell tableStyle:tableView.style];
    [MAAppearance setFontForCell:cell tableStyle:tableView.style];

    cell.textLabel.text = @"Use Custom Color";
    
    NSString *currentColorId = nil;
    NSString *customColorSettingName = nil;
    if (indexPath.section == BACKGROUND_COLOR_SECTION)
    {
        currentColorId = [self.settings objectForKey:BackgroundColorId];
        customColorSettingName = @"customBackgroundColor";
    }
    else if (indexPath.section == FOREGROUND_COLOR_SECTION)
    {
        currentColorId = [self.settings objectForKey:ForegroundColorId];
        customColorSettingName = @"customForegroundColor";
    }
    // Check for custom color.
    if ([currentColorId isEqualToString:customColorSettingName])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    // Add image with the custom color.
    NSUInteger hex = [[self.settings objectForKey:customColorSettingName] integerValue];
    UIColor *color = [UIColor colorWithHex:hex];
    UIImage *image = [UIImage imageWithColor:color];
    NSInteger tag = [MAUtil toTag:indexPath];
    [MAUtil setImage:image forCell:cell withTag:tag];

    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView selectColorCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MASelectColorCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    [MAAppearance setAppearanceForCell:cell tableStyle:tableView.style];
    
    cell.textLabel.text = @"Select Custom Color";
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.accessoryView = [MAAccessoryView grayAccessoryViewForCell:cell];

    // Put in a clear image/placeholder so that the text lines up with the "Use Color" row above it.
    UIColor *color = [UIColor clearColor];
    UIImage *image = [UIImage imageWithColor:color];
    NSInteger tag = [MAUtil toTag:indexPath];
    [MAUtil setImage:image forCell:cell withTag:tag];

    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView useImageCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MAImageSelectionCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    [MAAppearance setAppearanceForCell:cell tableStyle:tableView.style];
    
    cell.textLabel.text = @"Use Custom Photo";
    
    NSString *currentColorId = nil;
    NSString *customColorSettingName = nil;
    if (indexPath.section == BACKGROUND_IMAGE_SECTION)
    {
        currentColorId = [self.settings objectForKey:BackgroundColorId];
        customColorSettingName = @"customBackgroundImage";
    }
    
    // Check for custom image.
    if ([currentColorId isEqualToString:customColorSettingName])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    // Put in a clear image/placeholder so that the text lines up with the other rows.
    UIColor *color = [UIColor clearColor];
    UIImage *image = [MAUserUtil customBackgroundImage];
    if (!image)
    {
        image = [UIImage imageWithColor:color];
    }
    NSInteger tag = [MAUtil toTag:indexPath];
    [MAUtil setImage:image forCell:cell withTag:tag];

    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView selectImageCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MASelectImageCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    [MAAppearance setAppearanceForCell:cell tableStyle:tableView.style];
    
    cell.textLabel.text = @"Select Custom Photo";
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.accessoryView = [MAAccessoryView grayAccessoryViewForCell:cell];
    
    // Put in a clear image/placeholder so that the text lines up with the other rows.
    UIColor *color = [UIColor clearColor];
    UIImage *image = [UIImage imageWithColor:color];
    NSInteger tag = [MAUtil toTag:indexPath];
    [MAUtil setImage:image forCell:cell withTag:tag];
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView tabBarColorCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MAUnitsSettingsCell *cell = (MAUnitsSettingsCell *)[tableView dequeueReusableCellWithIdentifier:MAUnitsCellIdentifier];
    if (cell == nil)
    {
        cell = [[MAUnitsSettingsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MAUnitsCellIdentifier];
    }
    //[MAAppearance setAppearanceForCell:cell tableStyle:tableView.style];
    //[MAAppearance setFontForCellLabel:cell.label];
    [cell setAppearanceInTable:tableView];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [cell.segCtrl setTitle:Localize(@"Light") forSegmentAtIndex:0];
    [cell.segCtrl setTitle:Localize(@"Dark") forSegmentAtIndex:1];
    
    NSString *color = [self.settings objectForKey:TabBarColor];
    if ([color isEqualToString:@"light"])
    {
        cell.segCtrl.selectedSegmentIndex = 0;
    }
    else // ([color isEqualToString:@"dark"])
    {
        cell.segCtrl.selectedSegmentIndex = 1;
    }
    [cell.segCtrl addTarget:nil action:NULL forControlEvents:UIControlEventValueChanged];
    [cell.segCtrl addTarget:self action:@selector(tabBarColorChanged:) forControlEvents:UIControlEventValueChanged];
    
    //cell.label.text = Localize(@"Top and Bottom Bar Color");
    //cell.label.text = Localize(@"Bar Color");
    //cell.label.text = Localize(@"Tab Bar Color");
    //cell.label.text = Localize(@"Tab Bar");
    cell.label.text = Localize(@"Border");

    cell.label.adjustsFontSizeToFitWidth = YES;
    [cell resizeSegCtrl];
    
    cell.label.backgroundColor = [UIColor clearColor];
    
    return cell;
}

- (IBAction)tabBarColorChanged:(id)sender
{
    // Get setting from component.
    UISegmentedControl *segmentCtrl = (UISegmentedControl *)sender;
    NSInteger selectedIdx = [segmentCtrl selectedSegmentIndex];
    NSString *color = @"";
    if (selectedIdx == 0)
    {
        color = @"light";
    }
    else // (selectedIdx == 1)
    {
        color = @"dark";
    }
    
    // Save new setting.
    self.settings = [MAUserUtil saveSetting:color forKey:TabBarColor];

    // Update current UI with new setting.
    [MAAppearance setTabAndNavBarColor];
}

- (UITableViewCell *)tableView:(UITableView *)tableView tableTextFontCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MAUnitsSettingsCell *cell = (MAUnitsSettingsCell *)[tableView dequeueReusableCellWithIdentifier:MAUnitsCellIdentifier];
    if (cell == nil)
    {
        cell = [[MAUnitsSettingsCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:MAUnitsCellIdentifier];
    }
    //[MAAppearance setAppearanceForCell:cell tableStyle:tableView.style];
    //[MAAppearance setFontForCellLabel:cell.label];
    [cell setAppearanceInTable:tableView];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [cell.segCtrl setTitle:Localize(@"Light") forSegmentAtIndex:0];
    [cell.segCtrl setTitle:Localize(@"Dark") forSegmentAtIndex:1];
    
    NSString *color = [self.settings objectForKey:TableTextColor];
    if ([color isEqualToString:WhiteColorString])
    {
        cell.segCtrl.selectedSegmentIndex = 0;
    }
    else // ([color isEqualToString:BlackColorString])
    {
        cell.segCtrl.selectedSegmentIndex = 1;
    }
    [cell.segCtrl addTarget:nil action:NULL forControlEvents:UIControlEventValueChanged];
    [cell.segCtrl addTarget:self action:@selector(tableTextColorChanged:) forControlEvents:UIControlEventValueChanged];
    
    cell.label.text = Localize(@"Row");
    
    cell.label.adjustsFontSizeToFitWidth = YES;
    [cell resizeSegCtrl];
    
    cell.label.backgroundColor = [UIColor clearColor];
    
    [MAAppearance setFontForCell:cell tableStyle:tableView.style];
    
    return cell;
}

- (IBAction)tableTextColorChanged:(id)sender
{
    // Get setting from component.
    UISegmentedControl *segmentCtrl = (UISegmentedControl *)sender;
    NSInteger selectedIdx = [segmentCtrl selectedSegmentIndex];
    NSString *color = @"";
    if (selectedIdx == 0)
    {
        color = WhiteColorString;
    }
    else // (selectedIdx == 1)
    {
        color = BlackColorString;
    }

    // Save new setting.
    self.settings = [MAUserUtil saveSetting:color forKey:TableTextColor];
    
    // Update current UI with new setting.
    [MAAppearance setSeparatorColor];
    [self.tableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView buttonTextColorCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MAUnitsSettingsCell *cell = (MAUnitsSettingsCell *)[tableView dequeueReusableCellWithIdentifier:MAUnitsCellIdentifier];
    if (cell == nil)
    {
        cell = [[MAUnitsSettingsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MAUnitsCellIdentifier];
    }
    //[MAAppearance setFontForCell:cell tableStyle:tableView.style];
    //[MAAppearance setFontForCellLabel:cell.label];
    [cell setAppearanceInTable:tableView];

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [cell.segCtrl setTitle:Localize(@"Light") forSegmentAtIndex:0];
    [cell.segCtrl setTitle:Localize(@"Dark") forSegmentAtIndex:1];

    NSString *color = [self.settings objectForKey:ButtonTextColor];
    if ([color isEqualToString:WhiteColorString])
    {
        cell.segCtrl.selectedSegmentIndex = 0;
    }
    else // ([color isEqualToString:BlackColorString])
    {
        cell.segCtrl.selectedSegmentIndex = 1;
    }
    [cell.segCtrl addTarget:nil action:NULL forControlEvents:UIControlEventValueChanged];
    [cell.segCtrl addTarget:self action:@selector(buttonTextColorChanged:) forControlEvents:UIControlEventValueChanged];
    
    cell.label.text = Localize(@"Button");
    
    cell.label.adjustsFontSizeToFitWidth = YES;
    [cell resizeSegCtrl];
    
    cell.label.backgroundColor = [UIColor clearColor];
    
    return cell;
}

- (IBAction)buttonTextColorChanged:(id)sender
{
    // Get setting from component.
    UISegmentedControl *segmentCtrl = (UISegmentedControl *)sender;
    NSInteger selectedIdx = [segmentCtrl selectedSegmentIndex];
    NSString *color = @"";
    if (selectedIdx == 0)
    {
        color = WhiteColorString;
    }
    else // (selectedIdx == 1)
    {
        color = BlackColorString;
    }
    
    // Save new setting.
    self.settings = [MAUserUtil saveSetting:color forKey:ButtonTextColor];

    // Update current UI with new setting.
    [self.testBtn setTextColor];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == BACKGROUND_COLOR_SECTION || indexPath.section == FOREGROUND_COLOR_SECTION)
    {
        if (indexPath.row == BACKGROUND_COLOR_USE_ROW || indexPath.row == FOREGROUND_COLOR_USE_ROW)
        {
            [self useCustomColor:indexPath];
        }
        else if (indexPath.row == BACKGROUND_COLOR_SELECT_ROW || indexPath.row == FOREGROUND_COLOR_SELECT_ROW)
        {
            [self loadColorSelectionController:indexPath];
        }
        return;
    }
    else if (indexPath.section == BACKGROUND_IMAGE_SECTION)
    {
        if (indexPath.row == BACKGROUND_IMAGE_USE_ROW)
        {
            [self useCustomImage:indexPath];
        }
        else if (indexPath.row == BACKGROUND_IMAGE_SELECT_ROW)
        {
            [self loadImageSelectionController:indexPath];
        }
        return;
    }
    else if (indexPath.section == OTHER_COLOR_SECTION)
    {
        if (indexPath.row == TABLE_TEXT_FONT)
        {
            [self loadTableFontPicker:indexPath];
        }
        return;
    }

    NSArray *colors = self.backgroundColors;
    NSString *settingsKey = BackgroundColorId;
    if (indexPath.section == FOREGROUND_SECTION)
    {
        colors = self.foregroundColors;
        settingsKey = ForegroundColorId;
    }

    NSDictionary *colorInfo = [colors objectAtIndex:indexPath.row];
    NSString *colorId = [colorInfo objectForKey:@"id"];
    UIColor *color = [colorInfo objectForKey:@"color"];
    
    // Save new color ID.
    self.settings = [MAUserUtil saveSetting:colorId forKey:settingsKey];
    [MAAppearance reloadAppearanceSettings];

    BOOL shouldAutoChangeTextColor = YES;
    NSString *textColorKey = nil;

    if (indexPath.section == BACKGROUND_SECTION)
    {
        // Change background.
        self.selectedBackgroundColorId = colorId;
        [[self view] setBackgroundColor:color];
        
        textColorKey = TableTextColor;
    }
    else if (indexPath.section == FOREGROUND_SECTION)
    {
        // Change foreground.
        self.selectedForegroundColorId = colorId;
        [self.testBtn reloadColors];
        if (ABOVE_IOS7)
        {
            MAAppDelegate *appDelegate = (MAAppDelegate *)[[UIApplication sharedApplication] delegate];
            appDelegate.window.tintColor = color;
            [appDelegate.window setNeedsDisplay];
            
            [MAUtil setAdjustableNavTitle:self.navigationItem.title withNavigationItem:self.navigationItem];
        }
        
        textColorKey = ButtonTextColor;
        
        // Turning off auto-color change because it usually looks better with white text.
        shouldAutoChangeTextColor = NO;
    }
    
    if (shouldAutoChangeTextColor)
    {
        BOOL const changedTextColor = [MAColorUtil autoChangeTextColor:color forKey:textColorKey];
        if (changedTextColor)
        {
            self.settings = [MAUserUtil loadSettings];
        }
    }

    [self.tableView reloadData];
}

- (void)useCustomColor:(NSIndexPath *)indexPath
{
    NSString *currentColorId = nil;
    NSString *customColorSettingName = nil;
    if (indexPath.section == BACKGROUND_COLOR_SECTION)
    {
        currentColorId = BackgroundColorId;
        customColorSettingName = @"customBackgroundColor";
    }
    else if (indexPath.section == FOREGROUND_COLOR_SECTION)
    {
        currentColorId = ForegroundColorId;
        customColorSettingName = @"customForegroundColor";
    }

    self.settings = [MAUserUtil saveSetting:customColorSettingName forKey:currentColorId];
    [MAAppearance reloadAppearanceSettings];

    NSString *hexStr = [self.settings objectForKey:customColorSettingName];
    NSUInteger hex = [hexStr integerValue];
    UIColor *color = [UIColor colorWithHex:hex];

    BOOL shouldAutoChangeTextColor = YES;
    NSString *textColorKey = nil;

    if (indexPath.section == BACKGROUND_COLOR_SECTION)
    {
        // Change background.
        self.selectedBackgroundColorId = customColorSettingName;
        [[self view] setBackgroundColor:color];
        
        textColorKey = TableTextColor;
    }
    else if (indexPath.section == FOREGROUND_COLOR_SECTION)
    {
        // Change foreground.
        self.selectedForegroundColorId = customColorSettingName;
        [self.testBtn reloadColors];
        if (ABOVE_IOS7)
        {
            MAAppDelegate *appDelegate = (MAAppDelegate *)[[UIApplication sharedApplication] delegate];
            appDelegate.window.tintColor = color;
            [appDelegate.window setNeedsDisplay];
            
            [MAUtil setAdjustableNavTitle:self.navigationItem.title withNavigationItem:self.navigationItem];
        }
        
        textColorKey = ButtonTextColor;
        
        // Turning off auto-color change because it usually looks better with white text.
        shouldAutoChangeTextColor = NO;
    }
    
    if (shouldAutoChangeTextColor)
    {
        UIColor *color = [UIColor colorWithHex:hex];
        BOOL const changedTextColor = [MAColorUtil autoChangeTextColor:color forKey:textColorKey];
        if (changedTextColor)
        {
            self.settings = [MAUserUtil loadSettings];
        }
    }
    
    [self.tableView reloadData];
}

- (void)loadColorSelectionController:(NSIndexPath *)indexPath
{
    MAColorSelectionViewController *controller = nil;
    NSString *settingsKey = nil;
    if (indexPath.section == BACKGROUND_COLOR_SECTION)
    {
        if (self.backgroundColorSelectionController == nil)
        {
            self.backgroundColorSelectionController = [[MAColorSelectionViewController alloc] initWithNibName:@"MAColorSelectionViewController" bundle:nil];
        }
        controller = self.backgroundColorSelectionController;
        
        settingsKey = @"customBackgroundColor";
    }
    else if (indexPath.section == FOREGROUND_COLOR_SECTION)
    {
        if (self.foregroundColorSelectionController == nil)
        {
            self.foregroundColorSelectionController = [[MAColorSelectionViewController alloc] initWithNibName:@"MAColorSelectionViewController" bundle:nil];
        }
        controller = self.foregroundColorSelectionController;
        
        settingsKey = @"customForegroundColor";
    }

    controller.settingsKey = settingsKey;
    controller.title = Localize(@"Select Color");

    [self.navigationController pushViewController:controller animated:YES];
}

- (void)useCustomImage:(NSIndexPath *)indexPath
{
    UIImage *image = [MAUserUtil customBackgroundImage];
    if (!image)
    {
        // Load image if one does not yet exist.
        [self loadImageSelectionController:indexPath];
        return;
    }
    
    NSString *currentColorId = nil;
    NSString *customColorSettingName = nil;
    if (indexPath.section == BACKGROUND_IMAGE_SECTION)
    {
        currentColorId = BackgroundColorId;
        customColorSettingName = @"customBackgroundImage";
    }
    /*
    else if (indexPath.section == FOREGROUND_IMAGE_SECTION)
    {
        currentColorId = ForegroundColorId;
        customColorSettingName = @"customForegroundImage";
    }
     */
    
    self.settings = [MAUserUtil saveSetting:customColorSettingName forKey:currentColorId];
    [MAAppearance reloadAppearanceSettings];

    UIColor *color = [MAAppearance backgroundColor];
    
    if (indexPath.section == BACKGROUND_IMAGE_SECTION)
    {
        // Change background.
        self.selectedBackgroundColorId = customColorSettingName;
        [[self view] setBackgroundColor:color];
    }
    /*
    else if (indexPath.section == FOREGROUND_IMAGE_SECTION)
    {
        // Change foreground.
        self.selectedForegroundColorId = customColorSettingName;
        [self.testBtn reloadColors];
        if (ABOVE_IOS7)
        {
            MAAppDelegate *appDelegate = (MAAppDelegate *)[[UIApplication sharedApplication] delegate];
            appDelegate.window.tintColor = color;
            [appDelegate.window setNeedsDisplay];
        }
    }
     */
    
    [self.tableView reloadData];
}

- (void)loadImageSelectionController:(NSIndexPath *)indexPath
{
    if (self.takePhotoController == nil)
    {
        self.takePhotoController = [[FDTakeController alloc] init];
        self.takePhotoController.delegate = self;
    }
    [self.takePhotoController takePhotoOrChooseFromLibrary];
}

- (void)loadTableFontPicker:(NSIndexPath *)indexPath
{
    // TODO: Set KWFontPicker values to current settings.
    // TODO: Show KWFontPicker.
    //self.tableFontPicker = [MAAppearance tableFontPicker];
}

#pragma mark - FDTakeDelegate

- (void)takeController:(FDTakeController *)controller gotPhoto:(UIImage *)image withInfo:(NSDictionary *)info
{
    //NSLog(@"Image loaded: info=%@", info);
    
    if (image.size.width > image.size.height)
    {
        // TODO Need to rotate if image has wrong orientation? How to determine the new orientation, though?
        //image = [UIImage rotateImage:image toOrientation:UIImageOrientationRight];

    }
    // Resize image to match the screen size.
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    image = [image imageByScalingProportionallyToMinimumSize:screenRect.size];

    [MAUserUtil saveImage:image];
    
    // Automatically use new image as the background.
    NSString *currentColorId = nil;
    NSString *customColorSettingName = nil;
    //if (indexPath.section == BACKGROUND_IMAGE_SECTION)
    {
        currentColorId = BackgroundColorId;
        customColorSettingName = @"customBackgroundImage";
    }

    self.settings = [MAUserUtil saveSetting:customColorSettingName forKey:currentColorId];
    [MAAppearance reloadAppearanceSettings];
    
    UIColor *color = [MAAppearance backgroundColor];
    
    //if (indexPath.section == BACKGROUND_IMAGE_SECTION)
    {
        // Change background.
        self.selectedBackgroundColorId = customColorSettingName;
        [[self view] setBackgroundColor:color];
    }
}

@end
