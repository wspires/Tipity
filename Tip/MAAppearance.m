//
//  MAAppearance.m
//  Gym Log
//
//  Created by Wade Spires on 9/10/13.
//
//

#import "MAAppearance.h"

#import "MAAppDelegate.h"
#import "MAColorUtil.h"
#import "UIColor+ExtraColors.h"
#import "MAFilePaths.h"
#import "MAImageCache.h"
#import "MAUtil.h"
#import "MAUserUtil.h"
#import "UIImage+Extensions.h"
#import "UIImage+Gradient.h"

#ifdef IS_GYM_LOG_APP
#import "MAExercise.h"
#endif

// TODO: Make thread-safe.
static NSArray *BackgroundColors = nil;
static NSArray *ForegroundColors = nil;
static UIColor *BackgroundColor = nil;
static UIColor *ForegroundColor = nil;

@implementation MAAppearance

+ (void)setAppearance
{
    [MAAppearance setTabAndNavBarColor];
    
    if (BELOW_IOS7)
    {
        return;
    }
    
    /*
     [[UISlider appearance] setThumbTintColor:[UIColor darkGrayColor]];
     [[UISlider appearance] setMinimumTrackTintColor:[UIColor lightGrayColor]];
     [[UISlider appearance] setMaximumTrackTintColor:[UIColor grayColor]];
     [[UIProgressView appearance] setProgressTintColor:[UIColor darkGrayColor]];
     [[UIProgressView appearance] setTrackTintColor:[UIColor lightGrayColor]];
     
     [[UISegmentedControl appearance] setTintColor:[UIColor blueColor]];
     
     [[UIStepper appearance] setTintColor:[UIColor blueColor]];
     
     [[UISwitch appearance] setTintColor:[UIColor blueColor]];
     */
    
    [MAAppearance setSeparatorColor];
    
    // TODO: Causes crashes on the iPad for some reason: think it's an iOS 7 bug.
    // Use setSeparatorStyleForTable instead.
    //[[UITableView appearance] setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    
    [[UITableViewCell appearance] setBackgroundColor:[UIColor clearColor]];
    
    // WARNING: Do not uncomment the next 2 lines! It causes crashes since called via the app delegate if the background color is an image and [UIColor colorWithPatternImage:] is called
    //  http://stackoverflow.com/questions/12593299/ios-6-mfmailcomposeviewcontroller-only-support-rgba-or-the-white-color-space-t
    //[[UIDatePicker appearance] setBackgroundColor:[MAAppearance backgroundColorForPicker]];
    //[[UIPickerView appearance] setBackgroundColor:[MAAppearance backgroundColorForPicker]];
    
    //[MAAppearance setTabBarAppearance];
    //[MAAppearance setNavBarAppearance];
}

+ (void)setTabBarAppearance
{
    UIImage *tabBackground = [[UIImage imageNamed:@"tab_bar_49"]
                              resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [[UITabBar appearance] setBackgroundImage:tabBackground];
    
    UIImage *tabSelected = [[UIImage imageNamed:@"tab_bar_selected"]
                            resizableImageWithCapInsets:UIEdgeInsetsMake(0, 3, 0, 3)];
    [[UITabBar appearance] setSelectionIndicatorImage:tabSelected];
    return;

    /*
    MAAppDelegate* myDelegate = (((MAAppDelegate*) [UIApplication sharedApplication].delegate));
    UITabBarController *tabBarController = (UITabBarController *)myDelegate.window.rootViewController;
    UITabBar *tabBar = tabBarController.tabBar;
    UITabBarItem *tabBarItem1 = [tabBar.items objectAtIndex:0];
    UITabBarItem *tabBarItem2 = [tabBar.items objectAtIndex:1];
    UITabBarItem *tabBarItem3 = [tabBar.items objectAtIndex:2];
    
    tabBarItem1.title = @"Routines";
    tabBarItem2.title = @"History";
    tabBarItem3.title = @"Settings";
    
    [tabBarItem1 setFinishedSelectedImage:[UIImage imageNamed:@"home_selected.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"home.png"]];
    [tabBarItem2 setFinishedSelectedImage:[UIImage imageNamed:@"maps_selected.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"maps.png"]];
    [tabBarItem3 setFinishedSelectedImage:[UIImage imageNamed:@"myplan_selected.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"myplan.png"]];
    
    // Change the tab bar background
    UIImage* tabBarBackground = [UIImage imageNamed:@"tabbar.png"];
    [[UITabBar appearance] setBackgroundImage:tabBarBackground];
    [[UITabBar appearance] setSelectionIndicatorImage:[UIImage imageNamed:@"tabbar_selected.png"]];
    
    // Change the title color of tab bar items
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                       [UIColor whiteColor], UITextAttributeTextColor,
                                                       nil] forState:UIControlStateNormal];
    UIColor *titleHighlightedColor = UIColorFromRGB(153, 192, 48);
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                       titleHighlightedColor, UITextAttributeTextColor,
                                                       nil] forState:UIControlStateHighlighted];
    
    [tabBar setNeedsDisplay];
    [tabBar setNeedsLayout];
     */
}

+ (void)setNavBarAppearance
{
//    MAAppDelegate* myDelegate = (((MAAppDelegate *) [UIApplication sharedApplication].delegate));
//    UITabBarController *tabBarController = (UITabBarController *)myDelegate.window.rootViewController;
//    tabBarController.navigationController.navigationBar.translucent = YES;
//    return;
    
    /*
     MAAppDelegate* myDelegate = (((MAAppDelegate*) [UIApplication sharedApplication].delegate));
     UITabBarController *tabBarController = (UITabBarController *)myDelegate.window.rootViewController;
     UIView *view = tabBarController.navigationController.navigationBar;
     [MAUtil addGradientToView:view];
     return;
     */
    
    /*
    UIImage *navBackgroundImage = [UIImage imageNamed:@"nav_bar_44"];
    [[UINavigationBar appearance] setBackgroundImage:navBackgroundImage forBarMetrics:UIBarMetricsDefault];
    navBackgroundImage = [UIImage imageNamed:@"nav_bar_32"];
    [[UINavigationBar appearance] setBackgroundImage:navBackgroundImage forBarMetrics:UIBarMetricsLandscapePhone];
    return;
    */
    
    /*
     UIImage *navBackgroundImage = [UIImage imageNamed:@"navbar_bg"];
     [[UINavigationBar appearance] setBackgroundImage:navBackgroundImage forBarMetrics:UIBarMetricsDefault];
     
     NSDictionary * attributes = [NSDictionary dictionaryWithObjectsAndKeys:
     UIColorFromRGB(245.0, 245.0, 245.0), UITextAttributeTextColor,
     UIColorFromRGBA(0.0, 0.0, 0.0, 0.8), UITextAttributeTextShadowColor,
     [NSValue valueWithUIOffset:UIOffsetMake(0, 1)],
     UITextAttributeTextShadowOffset,
     [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:21.0], UITextAttributeFont, nil];
     
     [[UINavigationBar appearance] setTitleTextAttributes:attributes];
     
     // Change the appearance of back button
     UIImage *backButtonImage = [[UIImage imageNamed:@"button_back"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 13, 0, 6)];
     [[UIBarButtonItem appearance] setBackButtonBackgroundImage:backButtonImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
     
     // Change the appearance of other navigation button
     UIImage *barButtonImage = [[UIImage imageNamed:@"button_normal"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 6, 0, 6)];
     [[UIBarButtonItem appearance] setBackgroundImage:barButtonImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
     
     [[UIBarButtonItem appearance] setTitleTextAttributes:attributes forState:UIControlStateNormal];
     
     MAAppDelegate* myDelegate = (((MAAppDelegate*) [UIApplication sharedApplication].delegate));
     UITabBarController *tabBarController = (UITabBarController *)myDelegate.window.rootViewController;
     [tabBarController.navigationController.view setNeedsDisplay];
     [tabBarController.navigationController.view setNeedsLayout];
     */
}

// Reload user-selected colors for background, foreground, etc.
+ (void)reloadAppearanceSettings
{
    // Reload lists in case we allow user to input their own custom color or image.
    BackgroundColors = nil;
    ForegroundColors = nil;
    
    // Reload colors.
    BackgroundColor = [MAAppearance loadBackgroundColor];
    ForegroundColor = [MAAppearance loadForegroundColor];
    
    [MAAppearance setTabAndNavBarColor];
    
#ifdef IS_GYM_LOG_APP
    // Reload the default exercise image with the new color tint.
    [MAExercise defaultExerciseImage:YES];
#endif
    
    [MAAppearance setSeparatorColor];

    // Clear the cache of gradient images.
    [[MAImageCache sharedInstance] removeAllObjects];
    
    // TODO: Would it make sense to set the window tint here?
}

+ (UIColor *)loadBackgroundColor
{
    // Lazy instantiation of color list.
    if (!BackgroundColors)
    {
        BackgroundColors = [MAFilePaths loadBackgroundColors];
    }
    
    BackgroundColor = [MAAppearance loadColorFromColors:BackgroundColors forKey:BackgroundColorId];
    return BackgroundColor;
}

+ (UIColor *)loadForegroundColor
{
    // Lazy instantiation of color list.
    if (!ForegroundColors)
    {
        ForegroundColors = [MAFilePaths loadForegroundColors];
    }
    
    ForegroundColor = [MAAppearance loadColorFromColors:ForegroundColors forKey:ForegroundColorId];
    return ForegroundColor;
}

// Search for user-selected color.
+ (UIColor *)loadColorFromColors:(NSArray *)colors forKey:(NSString *)colorSettingsKey
{
    UIColor *color = nil;
//    NSDictionary *settings = [MAUserUtil loadSettings];
    MAUserUtil *userUtil = [MAUserUtil sharedInstance];
    NSDictionary *settings = userUtil.settings;
//    NSDictionary *settings = [MAUserUtil sharedInstance].settings;
    NSString *currentColorId = [settings objectForKey:colorSettingsKey];
    
    // Check for custom color.
    if ([currentColorId isEqualToString:@"customBackgroundColor"]
        || [currentColorId isEqualToString:@"customForegroundColor"]
        )
    {
        NSUInteger hex = [[settings objectForKey:currentColorId] integerValue];
        return [UIColor colorWithHex:hex];
    }
    
    if ([currentColorId isEqualToString:@"customBackgroundImage"])
    {
        UIImage *image = [MAUserUtil customBackgroundImage];
        if (image)
        {
            return [UIColor colorWithPatternImage:image];
        }
        else
        {
            // Use default color if custom image is invalid.
            currentColorId = [MAUserUtil defaultBackgroundColorId];
        }
    }
    
    for (NSDictionary *colorInfo in colors)
    {
        NSString *colorId = [colorInfo objectForKey:@"id"];
        if ([colorId isEqualToString:currentColorId])
        {
            color = [colorInfo objectForKey:@"color"];
            break;
        }
    }
    
    if (!color)
    {
        // Default to the first color if could not find the current color ID in case the available color list changes later.
        assert(colors.count != 0);
        NSDictionary *colorInfo = [colors objectAtIndex:0];
        color = [colorInfo objectForKey:@"color"];
        
        // Update the settings with new color ID.
        NSString *colorId = [colorInfo objectForKey:@"id"];
        [MAUserUtil saveSetting:colorId forKey:colorSettingsKey]; // Not: returns new settings.
    }
    
    return color;
}

+ (UIColor *)backgroundColor
{
    if (!BackgroundColor)
    {
        BackgroundColor = [MAAppearance loadBackgroundColor];
    }
    return BackgroundColor;
}

+ (UIColor *)foregroundColor
{
    if (!ForegroundColor)
    {
        ForegroundColor = [MAAppearance loadForegroundColor];
    }
    return ForegroundColor;
}

+ (UIColor *)selectedColor
{
    // Determine the selected color. Default to a lighter color than the foreground color, but use a darker color if the color is already light so that the selected color is different.
    UIColor *color = [MAAppearance foregroundColor];
    UIColor *selectedColor = [color lighterColor];
    
    CGFloat red, green, blue, alpha;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];

    CGFloat selectedRed, selectedGreen, selectedBlue, selectedAlpha;
    [selectedColor getRed:&selectedRed green:&selectedGreen blue:&selectedBlue alpha:&selectedAlpha];
    if (red == selectedRed && green == selectedGreen && blue == selectedBlue)
    {
        selectedColor = [color darkerColor];
    }
    
    return selectedColor;
}

+ (UIColor *)highlightedColor
{
    UIColor *color = [MAAppearance selectedColor];
    return color;
}

+ (UIColor *)disabledColor
{
    return [UIColor dimGrayColor];
}

+ (void)setBackgroundColorForCell:(UITableViewCell *)cell
{
    if (BELOW_IOS7)
    {
        return;
    }
    
    cell.backgroundColor = [UIColor clearColor]; // Explicitly set to clear for iOS 7.
    return;
    
    
    /*
    //UIColor *gradColor1 = [UIColor grayColor];
    UIColor *gradColor1 = [UIColor snow3Color];
    UIColor *gradColor2 = [UIColor whiteColor];
    
    //UIView *view = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 100)]];
    UIView *view = cell;
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = view.bounds;
    gradient.startPoint = CGPointMake(.5, -2.5);
    gradient.endPoint = CGPointMake(.5, 1.5);
    gradient.colors = [NSArray arrayWithObjects:(id)[gradColor1 CGColor], (id)[gradColor2 CGColor], nil];
    [view.layer insertSublayer:gradient atIndex:0];
     */
}

+ (BOOL)shouldSetFontColorForTableStyle:(UITableViewStyle)tableStyle
{
    // TODO: For iOS 6, should always use black if cell is in a grouped table, but should use the set table text color if not in a grouped table.
    BOOL shouldSetFont = YES;
    if (BELOW_IOS7)
    {
        BOOL const isGrouped = tableStyle == UITableViewStylePlain;
        shouldSetFont = isGrouped;
    }
    return shouldSetFont;
}

+ (CGFloat)cellFontSize
{
    if (ABOVE_IOS7)
    {
        return 17;
    }
    else
    {
        return 17;
    }
}

+ (void)setFontForCell:(UITableViewCell *)cell tableStyle:(UITableViewStyle)tableStyle
{
    BOOL const shouldSetFont = [MAAppearance shouldSetFontColorForTableStyle:tableStyle];
    if (shouldSetFont)
    {
        [MAAppearance setFontForCell:cell];
    }
}

+ (void)setFontForCell:(UITableViewCell *)cell
{
    [MAAppearance setFontForCellLabel:cell.textLabel];
    //[MAAppearance setFontForCellLabel:cell.detailTextLabel];
    [MAAppearance setFontForCellDetailLabel:cell.detailTextLabel];
}

+ (void)setFontForCellLabel:(UILabel *)label tableStyle:(UITableViewStyle)tableStyle
{
    BOOL const shouldSetFont = [MAAppearance shouldSetFontColorForTableStyle:tableStyle];
    if (shouldSetFont)
    {
        label.textColor = [MAAppearance tableTextFontColor];
        if (ABOVE_IOS7)
        {
            // Dynamic type in iOS 7.
            label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        }
        else
        {
            label.font = [label.font fontWithSize:[MAAppearance cellFontSize]];
        }
    }
    
    if (BELOW_IOS7)
    {
        // Make label match style and position for iOS 6.
        [label setFont:[UIFont boldSystemFontOfSize:[MAAppearance cellFontSize]]];
        CGRect frame = label.frame;
        frame.origin.x = 10;
        label.frame = frame;
    }
}

+ (void)setFontForCellLabel:(UILabel *)label
{
    label.textColor = [MAAppearance tableTextFontColor];

    if (ABOVE_IOS7)
    {
        // Dynamic type in iOS 7.
        label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    }
    else
    {
        label.font = [label.font fontWithSize:[MAAppearance cellFontSize]];
    }

    if (BELOW_IOS7)
    {
        // Make label match style and position for iOS 6.
        [label setFont:[UIFont boldSystemFontOfSize:[MAAppearance cellFontSize]]];
        CGRect frame = label.frame;
        frame.origin.x = 10;
        label.frame = frame;
    }
}

+ (void)setFontForCellDetailLabel:(UILabel *)label
{
    label.textColor = [MAAppearance detailLabelTextColor];
    
    if (ABOVE_IOS7)
    {
        // Dynamic type in iOS 7.
        label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    }
}

+ (void)setAppearanceForCell:(UITableViewCell *)cell tableStyle:(UITableViewStyle)tableStyle
{
    [MAAppearance setBackgroundColorForCell:cell];
    [MAAppearance setFontForCell:cell tableStyle:tableStyle];
}

+ (void)setAppearanceForCell:(UITableViewCell *)cell
{
    [MAAppearance setBackgroundColorForCell:cell];
    [MAAppearance setFontForCell:cell];
}

+ (void)setSeparatorStyleForTable:(UITableView *)tableView
{
    if (BELOW_IOS7)
    {
        return;
    }
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    //tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

+ (UIColor *)backgroundColorForPicker
{
    // Default to a white color in case the background is an image or dark so that the date picker's contents are visible and look good.
    UIColor *color = [UIColor whiteColor];
    NSDictionary *settings = [MAUserUtil loadSettings];
    NSString *backgroundColorId = [settings objectForKey:BackgroundColorId];
    if (![backgroundColorId isEqualToString:@"customBackgroundImage"])
    {
        UIColor *backgroundColor = [MAAppearance backgroundColor];
        if ([MAColorUtil isLightColor:backgroundColor])
        {
            color = backgroundColor;
        }
    }
    
    color = [color colorWithAlphaComponent:.95];
    return color;
}

+ (void)setBackgroundColorForDatePicker:(UIDatePicker *)datePicker
{
    if (ABOVE_IOS7)
    {
        // Cannot just set the backgroundColor property because a date picker is composed of multiple subviews.
        // http://stackoverflow.com/questions/3469149/uidate-picker-background-color?lq=1
        //self.datePicker.backgroundColor = [MAAppearance backgroundColorForPicker];
        
        UIView *view = [[datePicker subviews] objectAtIndex:0];
        [view setBackgroundColor:[MAAppearance backgroundColorForPicker]];
        
        // hide the first and the last subviews
        //[[[view subviews] objectAtIndex:0] setHidden:YES];
        [[[view subviews] lastObject] setHidden:YES];
        
    }
}

+ (void)setBackgroundColorForPicker:(UIPickerView *)picker
{
    if (ABOVE_IOS7)
    {
        picker.backgroundColor = [MAAppearance backgroundColorForPicker];
    }
}

+ (void)setBackgroundColorForToolbar:(UIToolbar *)toolbar
{
    if (ABOVE_IOS7)
    {
        NSDictionary *settings = [MAUserUtil loadSettings];
        NSString *color = [settings objectForKey:TabBarColor];
        if ([color isEqualToString:@"dark"])
        {
            toolbar.backgroundColor = [UIColor blackColor];
            toolbar.translucent = NO;
            toolbar.barTintColor = [UIColor blackColor];
        }
        else // ([color isEqualToString:@"light"])
        {
            toolbar.backgroundColor = [UIColor whiteColor];
            toolbar.translucent = NO;
            toolbar.barTintColor = [UIColor whiteColor];
        }
    }
}

+ (void)clearBackgroundForTableView:(UITableView *)tableView
{
    // Make the table background clear, so that this view's background shows.
    tableView.backgroundColor = [UIColor clearColor];
    if ([tableView respondsToSelector:@selector(setBackgroundView:)])
    {
        [tableView setBackgroundView:nil];
    }
}

static CGFloat const SectionHeaderHeight = 25.;

+ (UILabel *)tableView:(UITableView *)tableView
viewForHeaderInSection:(NSInteger)section
   withBackgroundColor:(UIColor *)backgroundColor
{
    CGRect frame = CGRectMake(0, 0, tableView.bounds.size.width, SectionHeaderHeight);
    UILabel *headerView = [[UILabel alloc] initWithFrame:frame];
    
    headerView.adjustsFontSizeToFitWidth = YES;
    
    [headerView setBackgroundColor:[MAAppearance foregroundColor]];
    
    if (ABOVE_IOS7)
    {
        headerView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    }
    else
    {
        headerView.font = [UIFont boldSystemFontOfSize:18.0];        
    }
    headerView.textColor = [MAAppearance buttonTextColor];
    
    if (ABOVE_IOS7)
    {
        return headerView;
    }
    
    // Apply gradient.
    CGRect bounds = headerView.bounds;
	CAGradientLayer *gradient = [[CAGradientLayer alloc] init];
	gradient.frame = CGRectMake(bounds.origin.x
                                , bounds.origin.y
                                , bounds.size.width
                                , bounds.size.height / 2
                                );
	gradient.colors = [NSArray arrayWithObjects:
                       (id)[UIColorFromRGBA(255, 255, 255, 0.45) CGColor]
                       , (id)[UIColorFromRGBA(255, 235, 255, 0.1) CGColor]
                       , nil];
	[headerView.layer insertSublayer:gradient atIndex:0];
    
    //headerView.layer.borderColor = [UIColor blackColor].CGColor;
    //headerView.layer.borderWidth = 1.0;
    
    return headerView;
}

+ (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return SectionHeaderHeight;
}

+ (void)setColorForSwitch:(UISwitch *)switchControl
{
    switchControl.onTintColor = [MAAppearance foregroundColor];
}

+ (void)setStyleForUnitLabel:(UILabel *)label
{
    label.font = [UIFont systemFontOfSize:[UIFont labelFontSize]];
}

+ (void)setTextViewAppearance:(UITextView *)view
{
    if (BELOW_IOS7)
    {
        // Make the view clear with a rounded rectangle bordering it.
        //view.backgroundColor = [UIColor clearColor];
        view.backgroundColor = [UIColor whiteColor];
        view.layer.borderWidth = 1.0f;
        view.layer.borderColor = [[MAAppearance separatorColor] CGColor];
        view.layer.cornerRadius = 8.0f;
    }
    else
    {
        view.layer.cornerRadius = 4.0f;
        view.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        //[view setTextColor:[UIColor colorWithWhite:0.5f alpha:1.0f]];
    }
}

+ (void)setTableViewAppearance:(UITableView *)view
{
    // Make the view clear with a rounded rectangle bordering it.
    //view.backgroundColor = [UIColor clearColor];
    view.backgroundColor = [UIColor whiteColor];
    view.layer.borderWidth = 1.0f;
    view.layer.borderColor = [[MAAppearance separatorColor] CGColor];
    view.layer.cornerRadius = 8;
}

+ (UIColor *)placeholderTextColor
{
    //return [UIColor grayColor];
    //return [UIColor grayColor];
    return [UIColor lightGrayColor];
}

+ (void)setTableViewHeaderAppearanceForLabel:(UILabel *)label
{
    label.backgroundColor = [UIColor clearColor];
    if (ABOVE_IOS7)
    {
        //[[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]];
        //[[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setTextColor:[UIColor colorWithWhite:0.5f alpha:1.0f]];
        
        //label.font = [UIFont systemFontOfSize:[UIFont labelFontSize]];
        
        // TODO: Headers in iOS 7 are capitalized and capitalizedStringWithLocale doesn't seem to work.
        label.text = [label.text capitalizedStringWithLocale:[NSLocale autoupdatingCurrentLocale]];
        
        label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        //[label setTextColor:[UIColor colorWithWhite:0.5f alpha:1.0f]];
        label.textColor = [MAAppearance separatorColor];
    }
    else
    {
        label.font = [UIFont boldSystemFontOfSize:[MAAppearance cellFontSize]];
        label.textColor = [MAAppearance separatorColor];
    }
}

+ (UIColor *)searchBarColor
{
    if (ABOVE_IOS7)
    {
        NSDictionary *settings = [MAUserUtil loadSettings];
        NSString *color = [settings objectForKey:TabBarColor];
        if ([color isEqualToString:@"dark"])
        {
            return [UIColor colorWithHex:0x2e2e28];
        }
        else // ([color isEqualToString:@"light"])
        {
            //return [UIColor colorWithHex:0xf8f8ff];
            return [UIColor whiteColor];
        }
    }
    else
    {
        return [UIColor blackColor];
    }
}

// Tint image with color, ignoring luminosity but preserving alpha channel.
// http://stackoverflow.com/questions/3514066/how-to-tint-a-transparent-png-image-in-iphone
+ (UIImage *)tintImage:(UIImage *)image tintColor:(UIColor *)tintColor
{
    UIGraphicsBeginImageContext(image.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, 0, image.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    
    // Draw tint color.
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    [tintColor setFill];
    CGContextFillRect(context, rect);
    
    // Mask by alpha values of original image.
    CGContextSetBlendMode(context, kCGBlendModeDestinationIn);
    CGContextDrawImage(context, rect, image.CGImage);
    
    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return tintedImage;
}

+ (UIImage *)tintImage:(UIImage *)image
{
    return [MAAppearance tintImage:image tintColor:[MAAppearance foregroundColor]];
}

+ (UIImage *)tintedImageNamed:(NSString *)name
{
    UIImage *image = [UIImage imageNamed:name];
    return [MAAppearance tintImage:image];
}

+ (UIColor *)correctColor:(UIColor *)color
{
    // Adjust colors because they look different on the simulator versus an actual device.
    // http://stackoverflow.com/questions/10039641/ios-color-on-xcode-simulator-is-different-from-the-color-on-device
    CGFloat red, green, blue, alpha;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    red += 12. / 255.;
    green += 19. / 255.;
    blue += 16. / 255.;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

+ (UIImage *)imageWithForegroundGradient:(UIImage *)image
{
    UIColor *startColor = [UIColor whiteColor];
    //UIColor *startColor = [MAAppearance foregroundColor]; // TODO: Trying to match app icon with 2 color stops for the gradient.
    //startColor = [startColor lighterColor];
    UIColor *endColor = [MAAppearance foregroundColor];
    
    // Starting and ending the gradient outside the bounds of the image so that it's not so dark on on the bottom and white on the top.
    CGPoint startPoint = CGPointMake(0, -image.size.height / 2);
    CGFloat const coef = 5; // Larger values make the color richer (saturated); lower values make it lighter (unsaturated).
    CGPoint endPoint = CGPointMake(0, coef * image.size.height);
    //CGPoint startPoint = CGPointMake(0, 0);
    //CGPoint endPoint = CGPointMake(0, img.size.height);
    
    return [UIImage imageWithGradient:image startColor:startColor endColor:endColor startPoint:startPoint endPoint:endPoint];
}

+ (void)setTabAndNavBarColor
{
#ifndef IS_EXTENSION
    MAAppDelegate* myDelegate = (((MAAppDelegate *) [UIApplication sharedApplication].delegate));
    UITabBarController *tabBarController = (UITabBarController *)myDelegate.window.rootViewController;
    
    UIBarStyle barStyle = UIBarStyleBlackOpaque;
    NSDictionary *settings = [MAUserUtil loadSettings];
    NSString *color = [settings objectForKey:TabBarColor];
    if ([color isEqualToString:@"dark"])
    {
        barStyle = UIBarStyleBlack;
    }
    else // ([color isEqualToString:@"light"])
    {
        barStyle = UIBarStyleDefault;
    }
    
    // Never use a translucent tab bar. Note that on iOS 6 I had this as YES for some reason, though later testing with iOS 7 showed it to be the wrong setting.
    BOOL const translucent = NO;
    
    [myDelegate setBarStyle:barStyle translucent:translucent];
    
    if (ABOVE_IOS7)
    {
        tabBarController.tabBar.barStyle = barStyle;
        tabBarController.tabBar.translucent = NO;
    }
#endif // IS_EXTENSION
}

+ (UIColor *)buttonTextColor
{
    NSDictionary *settings = [MAUserUtil loadSettings];
    NSString *hexString = [settings objectForKey:ButtonTextColor];
    UIColor *color = [UIColor colorWithHexString:hexString];
    return color;
}

+ (NSString *)tableTextFontName
{
    NSDictionary *settings = [MAUserUtil loadSettings];
    NSString *name = [settings objectForKey:TableTextFont];
    return name;
}
+ (CGFloat)tableTextFontSize
{
    NSDictionary *settings = [MAUserUtil loadSettings];
    NSString *sizeString = [settings objectForKey:TableTextSize];
    CGFloat size = [sizeString floatValue];
    return size;
}
+ (UIColor *)tableTextFontColor
{
    NSDictionary *settings = [MAUserUtil loadSettings];
    NSString *color = [settings objectForKey:TableTextColor];
    if ([color isEqualToString:BlackColorString])
    {
        return [UIColor darkTextColor];
    }
    else // ([color isEqualToString:WhiteColorString])
    {
        return [UIColor lightTextColor];
    }
    
    /*
     NSDictionary *settings = [MAUserUtil loadSettings];
     NSString *hexString = [settings objectForKey:TableTextColor];
     UIColor *color = [UIColor colorWithHexString:hexString];
     return color;
     */
}
+ (UIFont *)tableTextFont
{
    NSDictionary *settings = [MAUserUtil loadSettings];
    NSString *name = [settings objectForKey:TableTextFont];
    NSString *sizeString = [settings objectForKey:TableTextSize];
    CGFloat size = [sizeString floatValue];
    UIFont *font = [UIFont fontWithName:name size:size];
    return font;
}

+ (void)setSeparatorColor
{
    if (ABOVE_IOS7)
    {
        [[UITableView appearance] setSeparatorColor:[MAAppearance separatorColor]];
    }
}

+ (UIColor *)separatorColor
{
    NSDictionary *settings = [MAUserUtil loadSettings];
    NSString *colorString = [settings objectForKey:TableTextColor];
    UIColor *color = nil;
    if ([colorString isEqualToString:BlackColorString])
    {
        // TODO: would be good to use darkTextColor, but it's too dark I think, and lighterColor only works if the color is natively in the HSB/HSV color space model already, not if it's in RGB.
        //color = [UIColor darkTextColor];
        //color = [color lighterColor];
        //color = [color colorAdjustedWithBrightnessFactor:1. / 2.0];
        color = [UIColor grayColor];
    }
    else // ([colorString isEqualToString:WhiteColorString])
    {
        color = [UIColor lightTextColor];
        //color = [UIColor grayColor];
    }
    return color;
}

+ (UIColor *)headerLabelTextColor
{
    return [MAAppearance separatorColor];
}

+ (UIColor *)detailLabelTextColor
{
    return [MAAppearance headerLabelTextColor];
}

+ (UIActivityIndicatorViewStyle)tableViewActivityIndicatorStyle
{
    // Use a different style and color because a cell row's selected row color differs by iOS version.
    if (ABOVE_IOS7)
    {
        return UIActivityIndicatorViewStyleGray;
    }
    else
    {
        return UIActivityIndicatorViewStyleWhite;
    }
}

+ (UIActivityIndicatorViewStyle)activityIndicatorStyle
{
    // Always returning gray because highlighted cells are light in both iOS 6 and 7.
    return UIActivityIndicatorViewStyleGray;
}

+ (CGFloat)heightForRowInTableView:(UITableView *)tableView withAttributedTextInView:(UIView *)view
{
    // A lot of trial and error, but this worked the best from user3055587 and Quang Hà.
    // http://stackoverflow.com/questions/18897896/replacement-for-deprecated-sizewithfont-in-ios-7
    // http://stackoverflow.com/questions/19398674/sizewithfont-method-is-deprecated-boundingrectwithsize-is-returning-wrong-value
    CGFloat width = tableView.frame.size.width - 15 - 30 - 15;  // tableView width - left border width - accessory indicator - right border width
    
    CGSize maximumLabelSize = CGSizeMake(width, CGFLOAT_MAX);
    CGSize expectedSize = [view sizeThatFits:maximumLabelSize];
    
    CGFloat height = expectedSize.height;
        
    // Add spacing above and below the the text in the cell. The value comes from visual inspection of a "normal" UITableViewCell.
    static CGFloat const topAndBottomPadding = 2 * 11;
    height += topAndBottomPadding;
    
    return height;
}

// Calculate the height to display the given text style, such as UIFontTextStyleHeadline, when using Dynamic Type in a label or table row.
+ (CGFloat)heightForTextStyle:(NSString *)textStyle
{
    return [MAAppearance heightForTextStyle:textStyle padding:NO];
}

+ (CGFloat)heightForTextStyle:(NSString *)textStyle padding:(BOOL)padding
{
    CGSize size = [MAAppearance sizeForTextStyle:textStyle];
    CGFloat height = size.height;
    if (padding)
    {
        // Add padding around the text.
        height *= 1.7;
    }
    return height;
}

+ (CGSize)sizeForTextStyle:(NSString *)textStyle
{
    UILabel *label = [MAAppearance labelForTextStyle:textStyle];
    return label.frame.size;
}

+ (UILabel *)labelForTextStyle:(NSString *)textStyle
{
    // http://www.raywenderlich.com/50151/text-kit-tutorial
    static dispatch_once_t once;
    static UILabel *label;
    dispatch_once(&once, ^{
        // Initialize to the largest frame size possible.
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, FLT_MAX, FLT_MAX)];
        label.text = @"A";
    });
    
    if (ABOVE_IOS7)
    {
        label.font = [UIFont preferredFontForTextStyle:textStyle];        
    }
    else
    {
        // Text style is not available on iOS 6 and below.
        label.font = [label.font fontWithSize:[MAAppearance cellFontSize]];
    }
    
    [label sizeToFit]; // Force frame to fit tightly around text.
    return label;
}

+ (CGFloat)heightForString:(NSString *)string textStyle:(NSString *)textStyle tableView:(UITableView *)tableView
{
    // Get the width of a cell in the table.
    CGFloat cellWidth = tableView.frame.size.width;
    if (BELOW_IOS7)
    {
        if (tableView.style == UITableViewStyleGrouped)
        {
            // In iOS 6 and below, account for the margin on each side in the grouped table view.
            // TODO: It would be preferable to obtain the margin amount from the table or a cell directly, but I'm not sure how and it's only for the older iOS 6 at this point. Note that cellForRowAtIndexPath calls heightForRow, so we cannot simply obtain the actual cell row that way to get the width unfortunately.
            static CGFloat const groupedTableViewMargin = 20.; // TODO: HARDCODE SIZE (From visual inspection.)
            cellWidth -= groupedTableViewMargin;
        }
    }

    CGFloat defaultHeight = [MAUtil rowHeightForTableView:tableView];
    
    return [MAAppearance heightForString:string textStyle:textStyle frameWidth:cellWidth defaultHeight:defaultHeight];
}

+ (CGFloat)heightForString:(NSString *)string textStyle:(NSString *)textStyle frameWidth:(CGFloat)frameWidth defaultHeight:(CGFloat)defaultHeight
{
    NSUInteger const numberOfLines = [MAAppearance numberOfLinesForString:string textStyle:textStyle frameWidth:frameWidth defaultHeight:defaultHeight];
    CGFloat heightForString = [MAAppearance heightForLines:numberOfLines textStyle:textStyle defaultHeight:defaultHeight];
    return heightForString;
}

+ (CGFloat)numberOfLinesForString:(NSString *)string textStyle:(NSString *)textStyle frameWidth:(CGFloat)frameWidth defaultHeight:(CGFloat)defaultHeight
{
    UILabel *label = [MAAppearance labelForTextStyle:textStyle];
    
    // Min: 10.000000 x 17.000000 (17.000000, 14.000000, 14.000000)
    // Max: 13.000000 x 24.000000 (17.000000, 20.000000, 14.000000)
    //CGSize const size = [MAAppearance sizeForTextStyle:textStyle];
    //NSLog(@"Text Size: %f x %f (%f, %f, %f)", size.width, size.height, [UIFont labelFontSize], label.font.pointSize, [UIFont systemFontSize]);
    
    // Using the point size because this was the only size that resulted in the correct text on, say, the exercise list when one of the exercises was struck-through and with all Dynamic Type settings. Otherwise, the struck-through exercise would appear blank.
    CGFloat fontSize = label.font.pointSize;
    
    // Estimate the number of lines that the string will take to display.
    NSUInteger const widthPerLine = frameWidth / fontSize;
    NSUInteger const numberOfLines = (string.length / widthPerLine) + 1;
    return numberOfLines;
}

+ (CGFloat)heightForLines:(NSUInteger)numberOfLines textStyle:(NSString *)textStyle defaultHeight:(CGFloat)defaultHeight
{
    UILabel *label = [MAAppearance labelForTextStyle:textStyle];
    CGFloat const heightPerTextLine = label.font.pointSize;
    
    CGFloat heightForString = defaultHeight;
    if (numberOfLines != 1)
    {
        CGFloat const heightForExtraLines = (numberOfLines - 1) * heightPerTextLine;
        heightForString += heightForExtraLines;
    }
    
    //NSLog(@"%@: %d => %f (%f per line)", string, numberOfExtraLines, heightForString, heightPerTextLine);
    
    return heightForString;
}

@end
