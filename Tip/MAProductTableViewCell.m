//
//  MAPricePickerCellTableViewCell.m
//  Gym Log
//
//  Created by Wade Spires on 8/25/14.
//
//

#import "MAProductTableViewCell.h"

#import "MAUtil.h"

static CGFloat const TrailingSidePadding = 8.;

@interface MAProductTableViewCell () <UITextFieldDelegate>
@property (strong, nonatomic) UIBarButtonItem *backBarButton;
@property (strong, nonatomic) UIBarButtonItem *forwardBarButton;
@property (strong, nonatomic) UIBarButtonItem *doneBarButton;
@property (strong, nonatomic) UIBarButtonItem *update1BarButton;
@property (strong, nonatomic) UIBarButtonItem *update2BarButton;

@property (weak, nonatomic) IBOutlet UIView *iconView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *priceLeadingSpaceConstraint;

// Constraints for hiding or showing the size field.
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *quantityTrailingSpaceConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *priceEqualsQuantityWidthConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *priceEqualsSizeWidthConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *quantityEqualsSizeWidthConstraint;
@end

@implementation MAProductTableViewCell
@synthesize product = _product;
@synthesize delegate = _delegate;
@synthesize priceField = _priceField;
@synthesize quantityField = _quantityField;
@synthesize sizeField = _sizeField;
@synthesize separatorLabel = _separatorLabel;
@synthesize quantitySizeSeparatorLabel = _quantitySizeSeparatorLabel;
@synthesize keyboardAccessoryView = _keyboardAccessoryView;
@synthesize hideIconView = _hideIconView;
@synthesize hideSizeField = _hideSizeField;
@synthesize userInteractionEnabled = _userInteractionEnabled;
@synthesize rowHeight = _rowHeight;
@synthesize pricePerUnitFractionDigits = _pricePerUnitFractionDigits;

@synthesize backBarButton = _backBarButton;
@synthesize forwardBarButton = _forwardBarButton;
@synthesize doneBarButton = _doneBarButton;
@synthesize update1BarButton = _update1BarButton;
@synthesize update2BarButton = _update2BarButton;

@synthesize iconView = _iconView;
@synthesize priceLeadingSpaceConstraint = _priceLeadingSpaceConstraint;

@synthesize quantityTrailingSpaceConstraint = _quantityTrailingSpaceConstraint;
@synthesize priceEqualsQuantityWidthConstraint = _priceEqualsQuantityWidthConstraint;
@synthesize priceEqualsSizeWidthConstraint = _priceEqualsSizeWidthConstraint;
@synthesize quantityEqualsSizeWidthConstraint = _quantityEqualsSizeWidthConstraint;

- (void)awakeFromNib
{
    // Initialization code
    _hideIconView = NO;
    _hideSizeField = NO;
    _userInteractionEnabled = YES;
    _hideDescription = YES;
    _descriptionLabel.hidden = _hideDescription;
    _rowHeight = 44.;
    _pricePerUnitFractionDigits = [MAProduct unitPriceFormatter].maximumFractionDigits;
    [self configureInputAccessoryView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setHideDescription:(BOOL)hideDescription
{
    if (hideDescription == _hideDescription)
    {
        return;
    }
    _hideDescription = hideDescription;
    
    self.descriptionLabel.hidden = _hideDescription;
    if (_hideDescription)
    {
        _rowHeight = 44.;
    }
    else
    {
        _rowHeight = 73.;
    }
    
    [self setNeedsDisplay];
}

- (void)setPricePerUnitFractionDigits:(NSUInteger)pricePerUnitFractionDigits
{
    if (pricePerUnitFractionDigits == _pricePerUnitFractionDigits)
    {
        return;
    }
    _pricePerUnitFractionDigits = pricePerUnitFractionDigits;
    
    NSNumberFormatter *formatter = [MAProduct unitPriceFormatter];
    [formatter setMaximumFractionDigits:_pricePerUnitFractionDigits];
    
    if (self.product)
    {
        NSString *formattedUnitPrice = [self.product formattedUnitPrice];
        NSString *description = SFmt(@"%@ / Unit", formattedUnitPrice);
        self.descriptionLabel.text = description;
    }
}

- (void)configureWithProduct:(MAProduct *)product
{
    self.product = product;
    if ( ! product)
    {
        self.priceField.text = @"";
        self.priceField.placeholder = Localize(@"Price");
        
        self.quantityField.text = @"";
        self.quantityField.placeholder = Localize(@"Count");
        
        self.sizeField.text = @"";
        self.sizeField.placeholder = Localize(@"Size");
        return;
    }
    
    self.priceField.text = [product formattedPrice];
    self.priceField.placeholder = self.priceField.text;
    
    self.quantityField.text = [product formattedQuantity];
    self.quantityField.placeholder = self.quantityField.text;

    self.sizeField.text = [product formattedSize];
    self.sizeField.placeholder = self.sizeField.text;
    
    NSString *formattedUnitPrice = [product formattedUnitPrice];
    NSString *description = SFmt(@"%@ / Unit", formattedUnitPrice);
    self.descriptionLabel.text = description;
}

- (void)setHideIconView:(BOOL)hideIconView
{
    // Check if already hiding view or showing it, so nothing to do.
    if (hideIconView == _hideIconView)
    {
        return;
    }
    _hideIconView = hideIconView;
    
    [self hideIconView:_hideIconView];
}

- (void)setHideSizeField:(BOOL)hideSizeField
{
    // Check if already hiding view or showing it, so nothing to do.
    if (hideSizeField == _hideSizeField)
    {
        return;
    }
    _hideSizeField = hideSizeField;
    
    [self hideSizeField:_hideSizeField];
}

- (void)setUserInteractionEnabled:(BOOL)userInteractionEnabled
{
    if (userInteractionEnabled == _userInteractionEnabled)
    {
        return;
    }
    _userInteractionEnabled = userInteractionEnabled;
    
    self.priceField.userInteractionEnabled = _userInteractionEnabled;
    self.quantityField.userInteractionEnabled = _userInteractionEnabled;
    self.sizeField.userInteractionEnabled = _userInteractionEnabled;
}

- (void)hideIconView:(BOOL)hideIconView
{
    if (_hideIconView)
    {
        [self updateConstraintsToHideIcon];
    }
    else // ! _hideIconView
    {
        [self updateConstraintsToShowIcon];
    }
    
    self.iconView.hidden = hideIconView;
    [self hideImageView:hideIconView];
}

- (void)updateConstraintsToHideIcon
{
    // Remove constraints setup in IB that are in self.contentView not self.
    [self.contentView removeConstraint:self.priceLeadingSpaceConstraint];
    
    NSLayoutConstraint *constraint = nil;
    
    // Note: add constraints to self not self.contentView.
    constraint = [NSLayoutConstraint
                  constraintWithItem:self.priceField
                  attribute:NSLayoutAttributeLeading
                  relatedBy:NSLayoutRelationEqual
                  toItem:self.contentView
                  attribute:NSLayoutAttributeLeading
                  multiplier:1.0
                  constant:TrailingSidePadding];
    self.priceLeadingSpaceConstraint = constraint;
    [self.contentView addConstraint:constraint];
}

- (void)updateConstraintsToShowIcon
{
    // Remove constraints setup in IB that are in self.contentView not self.
    [self.contentView removeConstraint:self.priceLeadingSpaceConstraint];
    
    NSLayoutConstraint *constraint = nil;
    
    // Note: add constraints to self not self.contentView.
    constraint = [NSLayoutConstraint
                  constraintWithItem:self.priceField
                  attribute:NSLayoutAttributeLeading
                  relatedBy:NSLayoutRelationEqual
                  toItem:self.iconView
                  attribute:NSLayoutAttributeTrailing
                  multiplier:1.0
                  constant:0];
    self.priceLeadingSpaceConstraint = constraint;
    [self.contentView addConstraint:constraint];
}

- (void)hideSizeField:(BOOL)hideSizeField
{
    if (_hideSizeField)
    {
        [self updateConstraintsToHideSize];
    }
    else // ! _hideSizeField
    {
        [self updateConstraintsToShowSize];
    }
    
    self.sizeField.hidden = _hideSizeField;
    self.quantitySizeSeparatorLabel.hidden = _hideSizeField;
}

- (void)updateConstraintsToHideSize
{
    // Remove constraints setup in IB that are in self.contentView not self.
    [self.contentView removeConstraint:self.quantityTrailingSpaceConstraint];
    [self.contentView removeConstraint:self.priceEqualsQuantityWidthConstraint];
    [self.contentView removeConstraint:self.priceEqualsSizeWidthConstraint];
    [self.contentView removeConstraint:self.quantityEqualsSizeWidthConstraint];

    NSLayoutConstraint *constraint = nil;
    
    // Note: add constraints to self not self.contentView.
    constraint = [NSLayoutConstraint
                  constraintWithItem:self.contentView
                  attribute:NSLayoutAttributeTrailing
                  relatedBy:NSLayoutRelationEqual
                  toItem:self.quantityField
                  attribute:NSLayoutAttributeTrailing
                  multiplier:1.0
                  constant:TrailingSidePadding];
    self.quantityTrailingSpaceConstraint = constraint;
    [self.contentView addConstraint:constraint];
    
    constraint = [NSLayoutConstraint
                  constraintWithItem:self.priceField
                  attribute:NSLayoutAttributeWidth
                  relatedBy:NSLayoutRelationEqual
                  toItem:self.quantityField
                  attribute:NSLayoutAttributeWidth
                  multiplier:1.0 / 1.0 // Equal sizes.
                  constant:0];
    self.priceEqualsQuantityWidthConstraint = constraint;
    [self.contentView addConstraint:constraint];
}

- (void)updateConstraintsToShowSize
{
    // Remove constraints setup in IB that are in self.contentView not self.
    [self.contentView removeConstraint:self.quantityTrailingSpaceConstraint];
    [self.contentView removeConstraint:self.priceEqualsQuantityWidthConstraint];
    [self.contentView removeConstraint:self.priceEqualsSizeWidthConstraint];
    [self.contentView removeConstraint:self.quantityEqualsSizeWidthConstraint];
    
    NSLayoutConstraint *constraint = nil;
    
    // Note: add constraints to self not self.contentView.
    constraint = [NSLayoutConstraint
                  constraintWithItem:self.quantitySizeSeparatorLabel
                  attribute:NSLayoutAttributeTrailing
                  relatedBy:NSLayoutRelationEqual
                  toItem:self.quantityField
                  attribute:NSLayoutAttributeTrailing
                  multiplier:1.0
                  constant:2.5 * TrailingSidePadding]; // 2.5 factor is based on inspection.
    self.quantityTrailingSpaceConstraint = constraint;
    [self.contentView addConstraint:constraint];
    
    constraint = [NSLayoutConstraint
                  constraintWithItem:self.priceField
                  attribute:NSLayoutAttributeWidth
                  relatedBy:NSLayoutRelationEqual
                  toItem:self.quantityField
                  attribute:NSLayoutAttributeWidth
                  multiplier:2.0 / 1.0 // Price is 2x the other field's size.
                  constant:0];
    self.priceEqualsQuantityWidthConstraint = constraint;
    [self.contentView addConstraint:constraint];
    
    constraint = [NSLayoutConstraint
                  constraintWithItem:self.priceField
                  attribute:NSLayoutAttributeWidth
                  relatedBy:NSLayoutRelationEqual
                  toItem:self.sizeField
                  attribute:NSLayoutAttributeWidth
                  multiplier:2.0 / 1.0 // Price is 2x the other field's size.
                  constant:0];
    self.priceEqualsSizeWidthConstraint = constraint;
    [self.contentView addConstraint:constraint];
    
    constraint = [NSLayoutConstraint
                  constraintWithItem:self.quantityField
                  attribute:NSLayoutAttributeWidth
                  relatedBy:NSLayoutRelationEqual
                  toItem:self.sizeField
                  attribute:NSLayoutAttributeWidth
                  multiplier:1.0 / 1.0 // Equal sizes.
                  constant:0];
    self.quantityEqualsSizeWidthConstraint = constraint;
    [self.contentView addConstraint:constraint];
}

- (void)willTransitionToState:(UITableViewCellStateMask)state
{
    [super willTransitionToState:state];
    
    // Hide the cell's image (which may be a subview, not simply self.imageView in case
    // [MAUtil setImage:forCell:withTag:] was called) when in edit mode and show it again when leave edit mode.
    BOOL hidden = NO;
    if ((state & UITableViewCellStateShowingEditControlMask) == UITableViewCellStateShowingEditControlMask)
    {
        hidden = YES;
    }
    else
    {
        hidden = NO;
    }
    
    [self hideImageView:hidden];
}

- (void)hideImageView:(BOOL)hide
{
    for (UIView *subview in self.contentView.subviews)
    {
        if ([subview isKindOfClass:[UIImageView class]])
        {
            subview.hidden = hide;
        }
    }
}

#pragma mark - Text field

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return self.userInteractionEnabled;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (self.delegate)
    {
        [self.delegate didBeginEditingCell:self];
    }

    [self checkAndSetEnabledBarButtons];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self dismissKeyboard:textField];
    [self updateProductWithTextField:textField];
    [self configureWithProduct:self.product];

    // Do not call didEndEditingCell here. Call it only when the Done button is pressed.
    // Otherwise, the delegate might reload cells and this cell might get recycled or deleted, so navigation between text fields gets messed up.
//    if (self.delegate)
//    {
//        [self.delegate didEndEditingCell:self];
//    }
}

// Called when the return key is pressed.
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //[textField.delegate textFieldDidEndEditing:textField];

    if (textField == self.priceField)
    {
        // Switch to the quantity text after editing the price text. Only occurs on the iPad since the keyboard has a return button.
        [self.quantityField becomeFirstResponder];
    }
    else if (textField == self.quantityField)
    {
        if (self.hideSizeField)
        {
            if (self.delegate)
            {
                [textField resignFirstResponder];
                [self.delegate didEndEditingCell:self];
            }
        }
        else
        {
            [self.sizeField becomeFirstResponder];
        }
    }
    else if (textField == self.sizeField)
    {
        if (self.delegate)
        {
            [textField resignFirstResponder];
            [self.delegate didEndEditingCell:self];
        }
    }
    
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == self.priceField || textField == self.quantityField || textField == self.sizeField)
    {
        BOOL shouldChangeCharactersInRange = [MAUtil numTextField:textField shouldChangeCharactersInRange:range replacementString:string];
        if (shouldChangeCharactersInRange)
        {
            // Change the text and save it immediately since otherwise the text will be missing the last input character if the user tabs to the next text field.
            NSMutableString *text = [NSMutableString stringWithString:textField.text];
            [text replaceCharactersInRange:range withString:string];
            textField.text = text;
            [self updateProductWithTextField:textField];
            return NO;
        }
        //return shouldChangeCharactersInRange;
    }
    
    return NO;
}

- (void)updateProductWithTextField:(UITextField *)textField
{
    if ( ! self.product)
    {
        return;
    }
    
    if (textField == self.priceField)
    {
        //[self resetTextInTextView:self.priceField];

        NSString *text = self.priceField.text;
        if ( ! text || text.length == 0)
        {
            text = self.priceField.placeholder;
        }

        double price = [MAUtil parseDouble:text];
        self.product.price = [NSNumber numberWithDouble:price];
        self.priceField.placeholder = text;
    }
    else if (textField == self.quantityField)
    {
        NSString *text = self.quantityField.text;
        if ( ! text || text.length == 0)
        {
            text = self.quantityField.placeholder;
        }
        
        double quantity = [MAUtil parseDouble:text];
        if (quantity <= 0)
        {
            quantity = 1;
        }
        self.product.quantity = [NSNumber numberWithDouble:quantity];
        self.quantityField.placeholder = text;
    }
    else if (textField == self.sizeField)
    {
        NSString *text = self.sizeField.text;
        if ( ! text || text.length == 0)
        {
            text = self.sizeField.placeholder;
        }
        
        double size = [MAUtil parseDouble:text];
        if (size <= 0)
        {
            size = 1;
        }
        self.product.size = [NSNumber numberWithDouble:size];
        self.sizeField.placeholder = text;
    }
}

- (void)dismissKeyboard:(UITextField *)textField
{
    if ([textField isFirstResponder])
    {
        [textField resignFirstResponder];
    }
}

- (void)dismissKeyboard
{
    [self.priceField resignFirstResponder];
    [self.quantityField resignFirstResponder];
    [self.sizeField resignFirstResponder];
}

#pragma mark - Input accessory view

- (UIToolbar *)makeInputAccessoryView
{
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    toolbar.frame = CGRectMake(0, 0, self.frame.size.width, 44);
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    self.backBarButton = [[UIBarButtonItem alloc] initWithTitle:@"❮" style:UIBarButtonItemStylePlain target:self action:@selector(backBarButtonTapped)];
    [items addObject:self.backBarButton];

    UIBarButtonItem *fixedItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    fixedItem.width = 42;
    [items addObject:fixedItem];

    self.forwardBarButton = [[UIBarButtonItem alloc] initWithTitle:@"❯" style:UIBarButtonItemStylePlain target:self action:@selector(forwardBarButtonTapped)];
    [items addObject:self.forwardBarButton];

    fixedItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    fixedItem.width = 42;
    [items addObject:fixedItem];
    
    self.update1BarButton = [[UIBarButtonItem alloc] initWithTitle:@"+1" style:UIBarButtonItemStylePlain target:self action:@selector(updateBarButtonTapped:)];
    [items addObject:self.update1BarButton];

    fixedItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    fixedItem.width = 21;
    [items addObject:fixedItem];
    
    self.update2BarButton = [[UIBarButtonItem alloc] initWithTitle:@"-1" style:UIBarButtonItemStylePlain target:self action:@selector(updateBarButtonTapped:)];
    [items addObject:self.update2BarButton];

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
    
    // http://unicode-search.net/unicode-namesearch.pl?term=angle
    self.backBarButton.title = @"❮";
    self.forwardBarButton.title = @"❯";
    
    [self.priceField setInputAccessoryView:self.keyboardAccessoryView];
    [self.quantityField setInputAccessoryView:self.keyboardAccessoryView];
    [self.sizeField setInputAccessoryView:self.keyboardAccessoryView];
}

- (void)updateInputAccessoryView
{
    // Button text defaults to blue, so set to black to match the regular keyboard button title colors.
    UIColor *barButtonColor = [UIColor blackColor];
    DLog(@"updateInputAccessoryView - 1a");
    self.backBarButton.tintColor = barButtonColor;
    self.forwardBarButton.tintColor = barButtonColor;
    self.doneBarButton.tintColor = barButtonColor;
    self.update1BarButton.tintColor = barButtonColor;
    self.update2BarButton.tintColor = barButtonColor;
    DLog(@"updateInputAccessoryView - 1b");
    
    // Or, set to foreground color.
    //self.backBarButton.tintColor = [MAAppearance foregroundColor];
    //self.forwardBarButton.tintColor = [MAAppearance foregroundColor];
    //self.doneBarButton.tintColor = [MAAppearance foregroundColor];
    
    // Set font for backBarButton and forwardBarButton to make arrows larger and also to support dynamic text.
    if (ABOVE_IOS7)
    {
        NSString *textStyle = UIFontTextStyleBody;
        UIFont *font = [UIFont preferredFontForTextStyle:textStyle];
        NSDictionary *textAttr = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
        DLog(@"updateInputAccessoryView - 2a");
        [self.backBarButton setTitleTextAttributes:textAttr forState:UIControlStateNormal];
        [self.backBarButton setTitleTextAttributes:textAttr forState:UIControlStateDisabled];
        [self.forwardBarButton setTitleTextAttributes:textAttr forState:UIControlStateNormal];
        [self.forwardBarButton setTitleTextAttributes:textAttr forState:UIControlStateDisabled];
        [self.update1BarButton setTitleTextAttributes:textAttr forState:UIControlStateNormal];
        [self.update1BarButton setTitleTextAttributes:textAttr forState:UIControlStateDisabled];
        [self.update2BarButton setTitleTextAttributes:textAttr forState:UIControlStateNormal];
        [self.update2BarButton setTitleTextAttributes:textAttr forState:UIControlStateDisabled];
        DLog(@"updateInputAccessoryView - 2b");
    }
}

- (IBAction)backBarButtonTapped
{
    if ([self.quantityField isFirstResponder])
    {
        [self resetTextInTextView:self.quantityField];
        [self.priceField becomeFirstResponder];
    }
    else if ([self.sizeField isFirstResponder])
    {
        [self resetTextInTextView:self.sizeField];
        [self.quantityField becomeFirstResponder];
    }
}

- (IBAction)forwardBarButtonTapped
{
    if ([self.priceField isFirstResponder])
    {
        [self resetTextInTextView:self.priceField];
        [self.quantityField becomeFirstResponder];
    }
    else if ([self.quantityField isFirstResponder])
    {
        [self resetTextInTextView:self.quantityField];
        [self.sizeField becomeFirstResponder];
    }
}

- (void)resetTextInTextView:(UITextField *)textView
{
    // Replace text in the text view with its placeholder text if the text field is empty but the placeholder text is non-empty.
    if ([textView isFirstResponder])
    {
        if ( ! textView.text || textView.text.length == 0)
        {
            NSString *text = textView.placeholder;
            double currentValue = [MAUtil parseDouble:text];
            if (currentValue != 0)
            {
                textView.text = text;
            }
        }
    }
}

- (IBAction)doneBarButtonTapped
{
    if ([self.priceField isFirstResponder])
    {
        [self resetTextInTextView:self.priceField];
    }
    else if ([self.quantityField isFirstResponder])
    {
        [self resetTextInTextView:self.quantityField];
    }
    else if ([self.sizeField isFirstResponder])
    {
        [self resetTextInTextView:self.sizeField];
    }
    else
    {
        // Note: this is expected behavior if this cell's text field has focus but the table is reloaded, which might cause this cell to be discarded.
//        NSLog(@"No first responder!");
    }

    [self dismissKeyboard];
    
    if (self.delegate)
    {
        [self.delegate didEndEditingCell:self];
    }
}

- (IBAction)updateBarButtonTapped:(UIBarButtonItem *)button
{
    double updateAmount = 0;
    UITextField *textField = nil;
    
    if ([self.priceField isFirstResponder])
    {
        updateAmount = 1;
        textField = self.priceField;
    }
    else if ([self.quantityField isFirstResponder])
    {
        updateAmount = 1;
        textField = self.quantityField;
    }
    else if ([self.sizeField isFirstResponder])
    {
        updateAmount = 1;
        textField = self.sizeField;
    }

    if (button == self.update2BarButton)
    {
        updateAmount = -updateAmount;
    }
    
    double currentValue = 0;
    NSString *text = textField.text;
    if (text && text.length != 0)
    {
        currentValue = [MAUtil parseDouble:text];
    }
    else
    {
        // Use the placeholder text.
        // Note: if textField.placeholder is not set or is a string like "Weight", then 0 will be returned.
        text = textField.placeholder;
        currentValue = [MAUtil parseDouble:text];
    }
    
    double newValue = currentValue + updateAmount;
    if (newValue < 0)
    {
        newValue = 0;
    }
    NSString *newValueStr = [MAUtil formatDouble:newValue];
    textField.text = newValueStr;
}

- (void)checkAndSetEnabledBarButtons
{
    self.backBarButton.enabled = YES;
    self.forwardBarButton.enabled = YES;
    
    self.update1BarButton.enabled = YES;
    self.update2BarButton.enabled = YES;
    
    if ([self.priceField isFirstResponder])
    {
        self.backBarButton.enabled = NO;
        self.update1BarButton.title = Localize(@"+1");
        self.update2BarButton.title = Localize(@"-1");
    }
    else if ([self.quantityField isFirstResponder])
    {
        if (self.hideSizeField)
        {
            // Disable switching to size text field.
            self.forwardBarButton.enabled = NO;
        }
        self.update1BarButton.title = Localize(@"+1");
        self.update2BarButton.title = Localize(@"-1");
    }
    else if ([self.sizeField isFirstResponder])
    {
        self.forwardBarButton.enabled = NO;
        self.update1BarButton.title = Localize(@"+1");
        self.update2BarButton.title = Localize(@"-1");
    }
}

// Return an integer to identify the text field that is the current first responder.
- (NSInteger)tagForFirstResponder
{
    NSInteger tag = InvalidTag;
    if ([self.priceField isFirstResponder])
    {
        tag = PriceTag;
    }
    else if ([self.quantityField isFirstResponder])
    {
        tag = QuantityTag;
    }
    else if ([self.sizeField isFirstResponder])
    {
        tag = SizeTag;
    }
    return tag;
}

// Convert tag to its corresponding text field.
- (UITextField *)textFieldForTag:(NSInteger)tag
{
    if (tag == PriceTag)
    {
        return self.priceField;
    }
    else if (tag == QuantityTag)
    {
        return self.quantityField;
    }
    else if (tag == SizeTag)
    {
        return self.sizeField;
    }
    return nil;
}

@end
