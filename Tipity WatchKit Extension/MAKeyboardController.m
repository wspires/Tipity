//
//  MAKeyboardController.m
//  Gym Log
//
//  Created by Wade Spires on 4/16/15.
//
//

#import "MAKeyboardController.h"

#import "MABill.h"

@interface MAKeyboardController()
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *valueLabel;
@property (strong, nonatomic) NSMutableString *value;

@property (weak, nonatomic) IBOutlet WKInterfaceButton *doneButton;

@property (weak, nonatomic) IBOutlet WKInterfaceButton *oneButton;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *twoButton;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *threeButton;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *fourButton;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *fiveButton;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *sixButton;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *sevenButton;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *eightButton;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *nineButton;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *zeroButton;

@property (weak, nonatomic) IBOutlet WKInterfaceButton *dotButton;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *deleteButton;

@property (weak, nonatomic) NSMutableDictionary *keyboardDict;
@property (strong, nonatomic) NSString *unit;
@end

@implementation MAKeyboardController
@synthesize valueLabel = _valueLabel;
@synthesize value = _value;
@synthesize doneButton = _doneButton;
@synthesize oneButton = _oneButton;
@synthesize twoButton = _twoButton;
@synthesize threeButton = _threeButton;
@synthesize fourButton = _fourButton;
@synthesize fiveButton = _fiveButton;
@synthesize sixButton = _sixButton;
@synthesize sevenButton = _sevenButton;
@synthesize eightButton = _eightButton;
@synthesize nineButton = _nineButton;
@synthesize zeroButton = _zeroButton;
@synthesize dotButton = _dotButton;
@synthesize deleteButton = _deleteButton;
@synthesize keyboardDict = _keyboardDict;
@synthesize unit = _unit;

+ (NSString *)keyboardValueKey
{
    return @"keyboardValue";
}
+ (NSString *)unitKey
{
    return @"unit";
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _value = [[NSMutableString alloc] init];
        LOG
    }
    return self;
}

- (void)dealloc
{
}

#pragma mark - Awake With Context

- (void)awakeWithContext:(id)context
{
    [super awakeWithContext:context];
    
    LOG
    [self loadContext:context];
}

- (void)loadContext:(id)context
{
    if ( ! context)
    {
        return;
    }
    
    NSMutableDictionary *dict = (NSMutableDictionary *)context;
    self.keyboardDict = dict;
    
    if (self.keyboardDict)
    {
        self.unit = [dict objectForKey:[MAKeyboardController unitKey]];
        
        NSString *value = [dict objectForKey:[MAKeyboardController keyboardValueKey]];
        if ( ! value)
        {
            value = [NSString string];
        }
        self.value = [NSMutableString stringWithString:value];
    }
}

#pragma mark - Will Activate

- (void)willActivate
{
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    
    LOG
    [self formatValueLabel];
}

- (void)didDeactivate
{
    [super didDeactivate];
}

#pragma mark - Buttons Tapped

- (IBAction)oneButtonTapped:(id)sender
{
    [self appendString:@"1"];
}
- (IBAction)twoButtonTapped:(id)sender
{
    [self appendString:@"2"];
}
- (IBAction)threeButtonTapped:(id)sender
{
    [self appendString:@"3"];
}
- (IBAction)fourButtonTapped:(id)sender
{
    [self appendString:@"4"];
}
- (IBAction)fiveButtonTapped:(id)sender
{
    [self appendString:@"5"];
}
- (IBAction)sixButtonTapped:(id)sender
{
    [self appendString:@"6"];
}
- (IBAction)sevenButtonTapped:(id)sender
{
    [self appendString:@"7"];
}
- (IBAction)eightButtonTapped:(id)sender
{
    [self appendString:@"8"];
}
- (IBAction)nineButtonTapped:(id)sender
{
    [self appendString:@"9"];
}
- (IBAction)zeroButtonTapped:(id)sender
{
    [self appendString:@"0"];
}
- (IBAction)dotButtonTapped:(id)sender
{
    [self appendString:@"."];
}

- (IBAction)deleteButtonTapped:(id)sender
{
    [self deleteLastCharacter];
}
- (IBAction)doneButtonTapped:(id)sender
{
    [self.keyboardDict setObject:self.value forKey:[MAKeyboardController keyboardValueKey]];
    [self dismissController];
}

- (void)appendString:(NSString *)string
{
    [self.value appendString:string];
    [self formatValueLabel];
}

- (void)deleteLastCharacter
{
    // Do not delete the currency symbol since it represents a blank field.
    if (self.value.length == 1)
    {
        NSNumberFormatter *formatter = [MABill priceFormatter];
        NSString *currencySymbol = [formatter currencySymbol];
        if ([self.value isEqualToString:currencySymbol])
        {
            return;
        }
    }

    NSRange range = NSMakeRange(self.value.length - 1, 1);
    [self.value replaceCharactersInRange:range withString:@""];
    [self formatValueLabel];
}

- (void)formatValueLabel
{
    NSString *text = self.value;
    if ( ! self.value || self.value.length == 0)
    {
        text = @"0";
    }
    if (self.unit)
    {
        text = SFmt(@"%@ %@", text, self.unit);
    }
    
    [self.valueLabel setText:@""];
    [self.valueLabel setText:text];
}

@end
