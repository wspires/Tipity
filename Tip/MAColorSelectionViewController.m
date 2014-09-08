//
//  MAColorSelectionViewController.m
//  Gym Log
//
//  Created by Wade Spires on 10/24/13.
//
//

#import "MAColorSelectionViewController.h"

#import "MAAppearance.h"
#import "MAAppDelegate.h"
#import "MAColorUtil.h"
#import "MAFilePaths.h"
#import "MAUserUtil.h"
#import "MAUtil.h"

#import "UIColor+ExtraColors.h"

@interface MAColorSelectionViewController ()
@property (strong, nonatomic) NSDictionary *settings;
@property (strong, nonatomic) NSArray *backgroundColors;
@property (strong, nonatomic) NSArray *foregroundColors;
@property (copy, nonatomic) NSString *selectedBackgroundColorId;
@property (copy, nonatomic) NSString *selectedForegroundColorId;
@property (assign, nonatomic) NSUInteger currentHexColor;
@end

@implementation MAColorSelectionViewController
@synthesize settingsKey = _settingsKey;
@synthesize testBtn = _testBtn;
@synthesize redSlider = _redSlider;
@synthesize greenSlider = _greenSlider;
@synthesize blueSlider = _blueSlider;
@synthesize redLabel = _redLabel;
@synthesize greenLabel = _greenLabel;
@synthesize blueLabel = _blueLabel;
@synthesize noteLabel = _noteLabel;

@synthesize settings = _settings;
@synthesize backgroundColors = _backgroundColors;
@synthesize foregroundColors = _foregroundColors;
@synthesize selectedBackgroundColorId = _selectedBackgroundColorId;
@synthesize selectedForegroundColorId = _selectedForegroundColorId;
@synthesize currentHexColor = _currentHexColor;

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

    [self.testBtn setupAsLogButton];

    // Sliders call sliderValueChanged continuously as they are slid not just when they stop sliding.
    self.redSlider.continuous = YES;
    self.greenSlider.continuous = YES;
    self.blueSlider.continuous = YES;

    // Set sliders' background colors to their representative color.
    self.redSlider.backgroundColor = [UIColor redColor];
    self.greenSlider.backgroundColor = [UIColor greenColor];
    self.blueSlider.backgroundColor = [UIColor blueColor];
    
    // Round corners of sliders.
    CGFloat const cornerRadius = 4.0f;
    self.redSlider.layer.cornerRadius = cornerRadius;
    self.greenSlider.layer.cornerRadius = cornerRadius;
    self.blueSlider.layer.cornerRadius = cornerRadius;
    
    // Hide the labels since the sliders' backgrounds show the color that each slider represents.
    self.redLabel.hidden = YES;
    self.greenLabel.hidden = YES;
    self.blueLabel.hidden = YES;
    
    // Initialize slider values with the current color setting.
    self.settings = [MAUserUtil loadSettings];
    NSUInteger hexColor = [[self.settings objectForKey:self.settingsKey] integerValue];
    UIColor *color = [UIColor colorWithHex:hexColor];
    CGFloat red, green, blue, alpha;
    BOOL wasConverted = [color getRed:&red green:&green blue:&blue alpha:&alpha];
    if (wasConverted)
    {
        self.redSlider.value = red * 255;
        self.greenSlider.value = green * 255;
        self.blueSlider.value = blue * 255;
    }
    [self logSliderValues];
}

- (void)logSliderValues
{
#ifdef MA_DEBUG_MODE
    NSUInteger hexColor = [self hexFromRed:round(self.redSlider.value) green:round(self.greenSlider.value) blue:round(self.blueSlider.value)];
#endif
    DLog(@"Slider values (rgb): %@ %@ %@ (0x%x)", [MAUtil formatDouble:self.redSlider.value], [MAUtil formatDouble:self.greenSlider.value], [MAUtil formatDouble:self.blueSlider.value], hexColor);
}

- (void)viewWillAppear:(BOOL)animated
{
    [MAUtil updateNavItem:self.navigationItem withTitle:self.title];

    self.settings = [MAUserUtil loadSettings];
    
    NSUInteger hexColor = [[self.settings objectForKey:self.settingsKey] integerValue];
    [self saveAndDisplayNewColorHex:hexColor];

    [[self view] setBackgroundColor:[MAAppearance backgroundColor]];
    [self.testBtn reloadColors];

    [self configureLabels];

    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)configureLabels
{
    self.redLabel.textColor = [MAAppearance tableTextFontColor];
    self.greenLabel.textColor = [MAAppearance tableTextFontColor];
    self.blueLabel.textColor = [MAAppearance tableTextFontColor];
    self.noteLabel.textColor = [MAAppearance tableTextFontColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sliderValueChanged:(id)sender
{
    NSUInteger red = round(self.redSlider.value);
    NSUInteger green = round(self.greenSlider.value);
    NSUInteger blue = round(self.blueSlider.value);
    NSUInteger hexColor = [self hexFromRed:red green:green blue:blue];

    if (hexColor == self.currentHexColor)
    {
        return;
    }
    [self logSliderValues];
    
    [self saveAndDisplayNewColorHex:hexColor];
}

- (NSUInteger)hexFromRed:(NSUInteger)red green:(NSUInteger)green blue:(NSUInteger)blue
{
    return ((red & 0xff) << 16) + ((green & 0xff) << 8) + (blue & 0xff);
}

- (void)saveAndDisplayNewColorHex:(NSUInteger)hex
{
    [self saveNewColorHex:hex];
    
    UIColor *color = [UIColor colorWithHex:hex];
    [self displayNewColor:color];
}

- (void)saveNewColorHex:(NSUInteger)hex
{
    _currentHexColor = hex;
    
    NSString *colorStr = SFmt(@"%d", (int)hex);
    self.settings = [MAUserUtil saveSetting:colorStr forKey:self.settingsKey];

    BOOL shouldAutoChangeTextColor = YES;
    NSString *textColorKey = nil;
    
    if ([self.settingsKey isEqualToString:@"customBackgroundColor"])
    {
        self.settings = [MAUserUtil saveSetting:@"customBackgroundColor" forKey:BackgroundColorId];
        textColorKey = TableTextColor;
    }
    else if ([self.settingsKey isEqualToString:@"customForegroundColor"])
    {
        self.settings = [MAUserUtil saveSetting:@"customForegroundColor" forKey:ForegroundColorId];
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
            [self configureLabels];
        }
    }

    [MAAppearance reloadAppearanceSettings];
}

- (void)displayNewColor:(UIColor *)color
{
    if ([self.settingsKey isEqualToString:@"customBackgroundColor"])
    {
        self.view.backgroundColor = color;
    }
    else if ([self.settingsKey isEqualToString:@"customForegroundColor"])
    {
        [self.testBtn reloadColors];
        if (ABOVE_IOS7)
        {
            MAAppDelegate *appDelegate = (MAAppDelegate *)[[UIApplication sharedApplication] delegate];
            appDelegate.window.tintColor = color;
            [appDelegate.window setNeedsDisplay];
            
            [MAUtil setAdjustableNavTitle:self.navigationItem.title withNavigationItem:self.navigationItem];
        }
    }
}

@end
