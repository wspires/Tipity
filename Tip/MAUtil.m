//
//  MAUtil.m
//  Gym Log
//
//  Created by Wade Spires on 10/8/12.
//
//

#import "MAUtil.h"

#import "MADateUtil.h"
#import "MAFilePaths.h"
#import "MAColorUtil.h"
#import "MAUserUtil.h"
#import "MAAppearance.h"
#import "MAAppDelegate.h"

#import <QuartzCore/QuartzCore.h>

NSUInteger DeviceSystemMajorVersion()
{
    static NSUInteger _deviceSystemMajorVersion = -1;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _deviceSystemMajorVersion = [[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] integerValue];
    });
    return _deviceSystemMajorVersion;
}

@implementation MAUtil

+ (NSString *)tipName
{
//    return Localize(@"Tip");
    return Localize(@"Gratuity");
}

+ (NSString *)billName
{
//    return Localize(@"Bill");
    return Localize(@"Check");
}

+ (BOOL)iPad
{
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
}

+ (NSString *)version
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
}

+ (NSString *)frameToString:(CGRect)frame
{
    return [NSString stringWithFormat:(@"%d, %d -> %d, %d (%d x %d)"), (int)frame.origin.x, (int)frame.origin.y, (int)(frame.origin.x + frame.size.width), (int)(frame.origin.y + frame.size.height), (int)frame.size.width, (int)frame.size.height];
}

// Set the title for the navigation window and make it adjust the font
// size for any length string.
// Note: Must call this from viewWillLoad so that the title gets set properly the first time it's viewed. Call '[MAUtil updateNavItem:self.navigationItem withTitle:self.title];' from viewWillAppear to update the title (possibly with a new font color, too).
+ (void)setAdjustableNavTitle:(NSString *)title withNavigationItem:(UINavigationItem *)navItem
{
    // TODO: Setting a custom label does not seem to work on iOS 5, only on 6.
    float version = [[UIDevice currentDevice].systemVersion floatValue];
    if (version < 6)
    {
        navItem.title = title;
        return;
    }

    CGRect frame = CGRectMake(0, 0, navItem.titleView.frame.size.width, 44);
    //CGRect frame = navItem.titleView.frame;
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    UIFont *font = nil;
    if (ABOVE_IOS7)
    {
        font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    }
    else
    {
        font = [UIFont boldSystemFontOfSize:18.0];
    }
    label.font = font;
    label.adjustsFontSizeToFitWidth = YES;
    label.textAlignment = NSTextAlignmentCenter;
    
    UIColor *textColor = nil;
    if (ABOVE_IOS7)
    {
        textColor = [MAAppearance foregroundColor];
    }
    else
    {
        textColor = [UIColor whiteColor];
    }
    label.textColor = textColor;
    
    label.text = title;
    
    if (BELOW_IOS7)
    {
        // Emboss to improve the look of the label.
        [label setShadowColor:[UIColor darkGrayColor]];
        [label setShadowOffset:CGSizeMake(0, -0.5)];
    }
    
    navItem.titleView = label;
}

+ (void)updateNavItem:(UINavigationItem *)navItem withTitle:(NSString *)title
{
    // TODO: Setting a custom label does not seem to work on iOS 5, only on 6.
    float version = [[UIDevice currentDevice].systemVersion floatValue];
    if (version < 6)
    {
        navItem.title = title;
        return;
    }

    UILabel *label = (UILabel *)navItem.titleView;
    
    UIColor *textColor = nil;
    if (ABOVE_IOS7)
    {
        textColor = [MAAppearance foregroundColor];
    }
    else
    {
        textColor = [UIColor whiteColor];
    }
    label.textColor = textColor;
    
    label.text = title;
}

+ (UILabel *)adjustableNavTitle:(NSString *)title forNavigationItem:(UINavigationItem *)navItem
{
    //CGRect frame = CGRectMake(0, 0
                              //, navItem.titleView.bounds.size.width
                              //, 44);
    CGRect frame = navItem.titleView.frame;
    //UIView *view = [[UIView alloc] initWithFrame:frame];
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:18.0];
    label.adjustsFontSizeToFitWidth = YES;
    label.textAlignment = NSTextAlignmentCenter;
    
    UIColor *textColor = nil;
    if (ABOVE_IOS7)
    {
        textColor = [MAAppearance foregroundColor];
    }
    else
    {
        textColor = [UIColor whiteColor];
    }
    label.textColor = textColor;

    label.text = title;
    
    if (BELOW_IOS7)
    {
        // Emboss to improve the look of the label.
        [label setShadowColor:[UIColor darkGrayColor]];
        [label setShadowOffset:CGSizeMake(0, -0.5)];
    }
    
    return label;
    //navItem.titleView = label;
    
    //navItem.titleView = view;
    //[navItem.titleView addSubview:label];
}

+ (NSString *)trimWhitespace:(NSString *)string
{
    if (!string)
    {
        return string;
    }
    
    NSMutableString *mutableString = [string mutableCopy];
    CFStringTrimWhitespace((CFMutableStringRef)mutableString);
    
    NSString *result = [mutableString copy];
    
    return result;
}

+ (double)parseDouble:(NSString *)s
{
    static dispatch_once_t once;
    static NSNumberFormatter *nf = nil;
    dispatch_once(&once, ^{
        nf = [[NSNumberFormatter alloc] init];
        [nf setNumberStyle:NSNumberFormatterDecimalStyle];
        [nf setLocale:[NSLocale autoupdatingCurrentLocale]];
    });
    
    static dispatch_once_t once2;
    static NSCharacterSet *trimCharSet = nil;
    dispatch_once(&once2, ^{
        NSString *decimalSep = [[NSLocale autoupdatingCurrentLocale] objectForKey:NSLocaleDecimalSeparator];
        NSMutableCharacterSet *digitDecimalCharSet = [NSMutableCharacterSet characterSetWithCharactersInString:decimalSep];
        [digitDecimalCharSet formUnionWithCharacterSet:[NSCharacterSet decimalDigitCharacterSet]];
        trimCharSet = [digitDecimalCharSet invertedSet];
    });

    s = [s stringByTrimmingCharactersInSet:trimCharSet];

    NSNumber *n = [nf numberFromString:s];
    double d = [n doubleValue];
    return d;
}

+ (NSString *)formatDouble:(double)d
{
    static dispatch_once_t once;
    static NSNumberFormatter *nf = nil;
    dispatch_once(&once, ^{
        nf = [[NSNumberFormatter alloc] init];
        [nf setNumberStyle:NSNumberFormatterDecimalStyle];
        [nf setPaddingCharacter:@" "];
        [nf setUsesGroupingSeparator:NO];
        [nf setLocale:[NSLocale autoupdatingCurrentLocale]];
        [nf setMaximumFractionDigits:2];
        [nf setRoundingMode:NSNumberFormatterRoundHalfUp];
    });
    
    // Prevent a signed 0. Sometimes we get a -0 as the result of some calculations, which looks weird to the user, so display as just 0.
    // Note: that '-0 == 0' is true.
    // http://en.wikipedia.org/wiki/Signed_zero
    if (d == 0)
    {
        d = fabs(d);
    }
    
    NSString *s = [nf stringFromNumber:[NSNumber numberWithDouble:d]];
    return s;
}

+ (NSString *)formatHeight:(double)d
{
    // Used to have separate logic for formatDouble and formatHeight, but now they do the same thing.
    return [MAUtil formatDouble:d];
}

+ (NSString *)formatCount:(NSUInteger)count
{
    static dispatch_once_t once;
    static NSNumberFormatter *nf = nil;
    dispatch_once(&once, ^{
        nf = [[NSNumberFormatter alloc] init];
        [nf setLocale:[NSLocale autoupdatingCurrentLocale]];
        
        NSString *decimalSep = [[NSLocale autoupdatingCurrentLocale] objectForKey:NSLocaleDecimalSeparator];
        [nf setDecimalSeparator:decimalSep];

        [nf setUsesGroupingSeparator:YES];
        NSString *groupSep = [[NSLocale autoupdatingCurrentLocale] objectForKey:NSLocaleGroupingSeparator];
        [nf setGroupingSeparator:groupSep];
        [nf setGroupingSize:3]; // TODO: Does grouping size change by locale?
    });
    NSString *s = [nf stringFromNumber:[NSNumber numberWithUnsignedInt:(unsigned int)count]];
    return s;
}

+ (NSString *)cardioSeparator
{
    // Separating distance and time on different lines to keep it cleaner, especially since time can have milliseconds which includes a dot, too.
    return @"\n";
    
    /*
    // Set separator for Cardio distance and time.
    // Normally, it'd be something like "25:00, 1.5 m", but some locales use ",", so we want "25:00; 1,5 m" instead.
    static dispatch_once_t once;
    static NSString *cardioSep = nil;
    dispatch_once(&once, ^{
        cardioSep = @",";
        NSString *decimalSep = [[NSLocale autoupdatingCurrentLocale] objectForKey:NSLocaleDecimalSeparator];
        if ([decimalSep isEqualToString:@","])
        {
            cardioSep = @";";
        }
    });
    return cardioSep;
     */
}

+ (NSString *)comparisonSeparator
{
    // Set separator for Cardio distance and time.
    // Normally, it'd be something like "25:00, 1.5 m", but some locales use ",", so we want "25:00; 1,5 m" instead.
    static dispatch_once_t once;
    static NSString *separator = nil;
    dispatch_once(&once, ^{
        separator = @",";
        NSString *decimalSep = [[NSLocale autoupdatingCurrentLocale] objectForKey:NSLocaleDecimalSeparator];
        if ([decimalSep isEqualToString:@","])
        {
            separator = @";";
        }
    });
    return separator;
}

+ (NSAttributedString *)formatSetNumber:(NSUInteger)setNumber
{
    //NSString *str = SFmt(@"%-5d", (int)setNumber);
    NSString *str = SFmt(@"%d", (int)setNumber);
    
    UIFont *font = nil;
    if (ABOVE_IOS7)
    {
        font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    }
    else
    {
        font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
    }
    
    NSDictionary *textDict = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:str attributes:textDict];
    [attrStr addAttribute:NSForegroundColorAttributeName value:[MAAppearance tableTextFontColor] range:NSMakeRange(0, attrStr.string.length)];

    return attrStr;
}

+ (NSError *)makeError:(NSString *)msg
{
    NSMutableDictionary* details = [NSMutableDictionary dictionary];
    [details setValue:msg forKey:NSLocalizedDescriptionKey];
    NSError *error = [NSError errorWithDomain:@"world" code:200 userInfo:details];
    return error;
}

+ (UIAlertView *)showAlertWithError:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:[error localizedDescription]
                          message:[error localizedRecoverySuggestion]
                          delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"Dismiss", @"")
                          otherButtonTitles:nil];
    
    [alert show];
    return alert;
}

+ (void)findMisbehavingScrollViewsIn:(UIView *)view
{
    if ([view isKindOfClass:[UIScrollView class]])
    {
        DLog(@"Found UIScrollView: %@", view);
        if ([(UIScrollView *)view scrollsToTop])
        {
            DLog(@"scrollsToTop = YES!");
        }
    }
    for (UIView *subview in [view subviews])
    {
        [MAUtil findMisbehavingScrollViewsIn:subview];
    }
}

+ (void)removeSubviews:(UIView *)view
{
    for (UIView *subview in view.subviews)
    {
        [subview removeFromSuperview];
    }
}

+ (void)brieflyHighlightCells:(NSArray*)indexPaths
                 forTableView:(UITableView *)tableView
{
    [UIView animateWithDuration:0.35
                          delay:0.0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^void() {
                         for (NSIndexPath* indexPath in indexPaths)
                         {
                             [[tableView cellForRowAtIndexPath:indexPath] setHighlighted:YES animated:YES];
                         }
                     }
                     completion:^(BOOL finished) {
                         for (NSIndexPath* indexPath in indexPaths)
                         {
                             [[tableView cellForRowAtIndexPath:indexPath] setHighlighted:NO animated:YES];
                         }
                     }];
}

+ (void)brieflyHighlightCell:(NSIndexPath *)indexPath
                 forTableView:(UITableView *)tableView
{
    [MAUtil brieflyHighlightCells:[NSArray arrayWithObjects:indexPath, nil] forTableView:tableView];
}

+ (NSInteger)toTag:(NSIndexPath *)indexPath
{
    // Convert indexPath to a view tag by starting at 101, 102, ..., 201, 202, etc.
    return ((indexPath.section + 1) * 100) + (indexPath.row + 1);
}

// Note just setting cell.imageView.image so that the labels are lined up without having to manually resize each image. See:
// http://stackoverflow.com/questions/9086664/uitableviewcell-with-images-in-different-dimensions
// 80x44 spacer so label appears to the right of the image.
+ (UIImageView *)setImage:(UIImage *)image forCell:(UITableViewCell *)cell withTag:(NSInteger)tag
{
    // Try to get the thumbnail image if it was already set.
    // Note: the thumbnail will be nil both when the cell is first init'ed and even sometimes after having been inited. Could be a bug in iOS, but in the latter case, the cell still exists, but the imageview cannot be found via its tag.
    UIImageView *thumbnail = (UIImageView *)[cell.contentView viewWithTag:tag];
    if ( ! thumbnail)
    {
        for (UIView *subview in [cell.contentView subviews])
        {
            if ([subview isKindOfClass:[UIImageView class]])
            {
                [subview removeFromSuperview];
            }
        }

        // The "official" cell image is the placeholder image with the required fixed size.
        //CGRect const imageFrame = CGRectMake(0, 0, 80, 42);
        CGRect const imageFrame = CGRectMake(0, 0, 64, 42);
        cell.imageView.frame = imageFrame;
        cell.imageView.image = [UIImage imageNamed:@"tableview_placeholder"];
        //cell.imageView.contentMode = UIViewContentModeCenter;
        
        // Add thumbnail image of arbitrary size.
        thumbnail = [[UIImageView alloc] initWithFrame:imageFrame];
        thumbnail.backgroundColor = [UIColor clearColor];
        thumbnail.contentMode = UIViewContentModeScaleAspectFit;
        thumbnail.tag = tag;
        [cell.contentView addSubview:thumbnail];
    }
    
    [thumbnail setImage:image];
    return thumbnail;
}

+ (void)setKeyboardTypeForTextField:(UITextField *)textField
{
    if ([MAUtil iPad])
    {
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }
    else
    {
        textField.keyboardType = UIKeyboardTypeDecimalPad;
    }
}

/*
 Enforce that a UITextField only allows valid floating-point values.
 
 Call this method from a UITextFieldDelegate's
   - (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
 method.
 */
+ (BOOL)numTextField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@""])
    {
        return YES;
    }
    
    // Do not allow two decimal separators, e.g., "2..".
    // TODO: Make sure that this value makes sense for different locales. Currently, it looks like the number pads always have a '.' rather than a ',' for regions such as Europe. Also, using ',' might not working with sqlite.
    NSString *decimalSep = [[NSLocale autoupdatingCurrentLocale] objectForKey:NSLocaleDecimalSeparator];
    //NSString *decimalSep = @".";
    BOOL hasDecimal = [textField.text rangeOfString:decimalSep].location != NSNotFound;
    BOOL wantsToAddDecimal = [string isEqualToString:decimalSep];
    BOOL decimalCheckOkay = !(hasDecimal && wantsToAddDecimal);
    if (!decimalCheckOkay)
    {
        return NO;
    }
    
    /*
    // TODO: Make this an option.
    // Allow + or - as the first character.
    if (range.location == 0)
    {
        char firstChar = [string characterAtIndex:0];
        if (firstChar == '+' || firstChar == '-')
        {
            if (range.length == 1)
            {
                return YES;
            }
            // More characters are being changed,
            // so remove '+' or '-' for any additional checks.
            string = [string substringFromIndex:1];
        }
    }
     */
    
    // Only allow numbers and a decimal point.
    NSMutableCharacterSet *digitDecimalCharSet = [NSMutableCharacterSet characterSetWithCharactersInString:decimalSep];
    [digitDecimalCharSet formUnionWithCharacterSet:[NSCharacterSet decimalDigitCharacterSet]];
    NSString * remainingChars = [string stringByTrimmingCharactersInSet:
                                 [digitDecimalCharSet invertedSet]];
    BOOL floatCheckOkay = remainingChars.length == string.length;
    if (!floatCheckOkay)
    {
        return NO;
    }
    
    return YES;
}

+ (NSNumberFormatter *)hhmmssFormatter
{
    static NSString * const sep = @":";
    
    static dispatch_once_t once;
    static NSNumberFormatter *formatter = nil;
    dispatch_once(&once, ^{
        formatter = [[NSNumberFormatter alloc ] init];
        [formatter setGroupingSeparator:sep];
        [formatter setGroupingSize:2];
        [formatter setUsesGroupingSeparator:YES];
    });
    
    return formatter;
}

+ (NSNumberFormatter *)millisecondFormatter
{
    static dispatch_once_t once;
    static NSNumberFormatter *formatter = nil;
    dispatch_once(&once, ^{
        formatter = [[NSNumberFormatter alloc ] init];
        [formatter setUsesSignificantDigits:YES];
        [formatter setMaximumSignificantDigits:3];
        [formatter setMaximumFractionDigits:2];
        [formatter setRoundingMode:NSNumberFormatterRoundCeiling];
    });
    
    return formatter;
}

+ (BOOL)hhmmssTextField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    static NSString * const timeSep = @":";
    NSString *decimalSep = [[NSLocale autoupdatingCurrentLocale] objectForKey:NSLocaleDecimalSeparator];
    
    // Disallow characters other than 0-9 and '.'.
    NSMutableCharacterSet *digitDecimalCharSet = [NSMutableCharacterSet decimalDigitCharacterSet];
    [digitDecimalCharSet addCharactersInString:decimalSep];
    NSString *remainingChars = [string stringByTrimmingCharactersInSet:[digitDecimalCharSet invertedSet]];
    BOOL numCheckOkay = remainingChars.length == string.length;
    if ( ! numCheckOkay)
    {
        return NO;
    }

    NSString *oldText = textField.text;
    NSString *newText = [oldText stringByReplacingCharactersInRange:range withString:string];
    newText = [newText stringByReplacingOccurrencesOfString:timeSep withString:@""];
    //TLog(@"%@ (%d)", newText, (int) newText.length);

    NSArray *hhmmssMsArray = [newText componentsSeparatedByString:decimalSep];
    if ( ! hhmmssMsArray || hhmmssMsArray.count > 2)
    {
        return NO;
    }
    
    NSString *hhmmss = [hhmmssMsArray objectAtIndex:0];
    if (hhmmss.length != 0)
    {
        if (hhmmss.length >= 7)
        {
            // Do not allow more characters to be added if already have "HH:MM:SS" format.
            return NO;
        }

        NSNumberFormatter *hhmmssFormatter = [MAUtil hhmmssFormatter];
        hhmmss = [hhmmssFormatter stringFromNumber:[NSNumber numberWithDouble:hhmmss.doubleValue]];
    }
    else
    {
        hhmmss = nil;
    }
    
    NSString *ms = nil;
    if (hhmmssMsArray.count == 2)
    {
        ms = [hhmmssMsArray objectAtIndex:1];
        if (ms && ms.length > 0)
        {
            if (ms.length >= 4)
            {
                return NO;
            }
            
            NSNumberFormatter *millisecondFormatter = [MAUtil millisecondFormatter];
            ms = [millisecondFormatter stringFromNumber:[NSNumber numberWithDouble:ms.doubleValue]];
        }
    }
    
    if (hhmmss && ms)
    {
        newText = SFmt(@"%@%@%@", hhmmss, decimalSep, ms);
    }
    else if ( ! hhmmss && ms)
    {
        newText = SFmt(@"%@%@", decimalSep, ms);
    }
    else if (hhmmss && ! ms)
    {
        newText = SFmt(@"%@", hhmmss);
    }
    else // if ( ! hhmmss && ! ms)
    {
        newText = @"";
    }
    textField.text = newText;
    
    return NO;
}

/*
 Enforce that a UITextField only allows time values in HH:MM:SS format.
 
 This version builds up the time as it's typed, so "1" corresponds to 00:00:01, "12" is 00:00:12, "123" is 00:01:23, etc.
 
 Call this method from a UITextFieldDelegate's
 - (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
 method.
 */
+ (BOOL)hhmmssTextField2:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    static NSString * const sep = @":";
    
    static dispatch_once_t once;
    static NSNumberFormatter *formatter = nil;
    dispatch_once(&once, ^{
        formatter = [[NSNumberFormatter alloc ] init];
        [formatter setGroupingSeparator:sep];
        [formatter setGroupingSize:2];
        [formatter setUsesGroupingSeparator:YES];
        
        //[formatter setSecondaryGroupingSize:3];
    });
    
    // Handle deletion. Note that the last character is not necessarily the only character being deleted. Possible multiple characters in the middle of the string can be selected and deleted, so handle deletion ourselves.
    if (string.length == 0)
    {        
        NSString *num = textField.text;
        num = [num stringByReplacingCharactersInRange:range withString:@""];
        num = [num stringByReplacingOccurrencesOfString:sep withString:@""];
        if (num.length == 0)
        {
            textField.text = @"";
            return NO;
        }
        NSString *str = [formatter stringFromNumber:[NSNumber numberWithDouble:num.doubleValue]];
        textField.text = str;
        return NO;
    }
    
    NSString *num = textField.text;
    if (textField.text.length >= 8)
    {
        // Do not allow more characters to be added if already have "HH:MM:SS" format.
        return NO;
    }
    
    // Disallow characters other than 0-9.
    NSCharacterSet *digitDecimalCharSet = [NSCharacterSet decimalDigitCharacterSet];
    NSString *remainingChars = [string stringByTrimmingCharactersInSet:[digitDecimalCharSet invertedSet]];
    BOOL numCheckOkay = remainingChars.length == string.length;
    if ( ! numCheckOkay)
    {
        return NO;
    }

    // Handle insertion. Note that a single character is not necessarily appended to the end. Potentially multiple characters can be copy-and-pasted into the middle, so handle the string replacement here and return NO to not have the string automatically inserted.
    num = [num stringByReplacingCharactersInRange:range withString:string];
    num = [num stringByReplacingOccurrencesOfString:sep withString:@""];
    NSString *str = [formatter stringFromNumber:[NSNumber numberWithDouble:num.doubleValue]];
    textField.text = str;

    return NO;
}

/*
 Enforce that a UITextField only allows time values in HH:MM:SS format.
 
 This version puts the first digit as the leading hour component--the first 'H' in "HH:MM:SS".
 
 Call this method from a UITextFieldDelegate's
 - (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
 method.
 */
+ (BOOL)hhmmssTextField3:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    static NSString * const filter = @"##:##:##";
    //static NSString * const filter = @"##:##:##.###";

    NSString *changedString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    // TODO: Only allow [0-5] for leading minute and second digit.
    
    if(range.length == 1 // Only do for single deletes.
       && string.length < range.length
       && [[textField.text substringWithRange:range] rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"0123456789"]].location == NSNotFound)
    {
        // Something was deleted. Delete past the previous number.
        NSInteger location = (changedString.length - 1);
        if(location > 0)
        {
            for(; location > 0; --location)
            {
                if(isdigit([changedString characterAtIndex:location]))
                {
                    break;
                }
            }
            changedString = [changedString substringToIndex:location];
        }
    }
    
    // Update the text in the text field by applying filter.
    // Note: that we return NO since we are changing the text ourselves and do not want the text to be updated automatically now.
    textField.text = filteredPhoneStringFromStringWithFilter(changedString, filter);
    return NO;
}

NSMutableString *filteredPhoneStringFromStringWithFilter(NSString *string, NSString *filter)
{
    NSUInteger onOriginal = 0, onFilter = 0, onOutput = 0;
    char outputString[filter.length];
    BOOL done = NO;
    
    while(onFilter < filter.length && !done)
    {
        char filterChar = [filter characterAtIndex:onFilter];
        char originalChar = onOriginal >= string.length ? '\0' : [string characterAtIndex:onOriginal];
        switch (filterChar)
        {
            case '#':
                if(originalChar=='\0')
                {
                    // We have no more input numbers for the filter, so we're done.
                    done = YES;
                    break;
                }
                if(isdigit(originalChar))
                {
                    outputString[onOutput] = originalChar;
                    ++onOriginal;
                    ++onFilter;
                    ++onOutput;
                }
                else
                {
                    ++onOriginal;
                }
                break;
                
            default:
                // Any other character will automatically be inserted for the user as they type (spaces, -, :, etc.) or deleted as they delete if there are more numbers to come.
                outputString[onOutput] = filterChar;
                ++onOutput;
                ++onFilter;
                if(originalChar == filterChar)
                {
                    ++onOriginal;
                }
                break;
        }
    }
    outputString[onOutput] = '\0'; // Cap the output string
    return [NSMutableString stringWithUTF8String:outputString];
}

+ (NSString *)toHHMMSSFromMinutes:(double)minutes
{
    static double const minutes_in_hour = 60;
    NSInteger hh = minutes / minutes_in_hour;
    minutes -= hh * minutes_in_hour;
    
    NSInteger mm = (NSInteger)minutes;
    minutes -= mm;
    
    static double const seconds_in_minutes = 60;
    assert(minutes < 1);
    double seconds = minutes * seconds_in_minutes;
    NSInteger ss = (int)seconds;
    //NSInteger ss = round(seconds);
    if (ss >= seconds_in_minutes)
    {
        ss = seconds_in_minutes - 1;
    }
    
    // Format milliseconds
    NSString *msStr = nil;
    double ms = seconds - ss;
    static double const milliseconds_in_second = 1000;
    int msInt = round(milliseconds_in_second * ms);
    if (msInt > 0)
    {
        if (msInt >= milliseconds_in_second)
        {
            // After rounding milliseconds, we have an entire second.
            ++ss;
        }
        else
        {
            NSString *decimalSep = [[NSLocale autoupdatingCurrentLocale] objectForKey:NSLocaleDecimalSeparator];
            msStr = SFmt(@"%@%d", decimalSep, (int)msInt);
        }
    }

    NSString *hhmmss = nil;
    if (hh == 0)
    {
        // Do not show hour if it is 0.
        hhmmss = SFmt(@"%02d:%02d", (int)mm, (int)ss);
    }
    else
    {
        hhmmss = SFmt(@"%d:%02d:%02d", (int)hh, (int)mm, (int)ss);
        // hhmmss = SFmt(@"%02d:%02d:%02d", hh, mm, ss);
    }

    if (msStr)
    {
        hhmmss = SFmt(@"%@%@", hhmmss, msStr);
    }
    
    return hhmmss;
}

+ (double)toMinutesFromHHMMSS:(NSString *)hhmmss
{
    NSString *decimalSep = [[NSLocale autoupdatingCurrentLocale] objectForKey:NSLocaleDecimalSeparator];
    NSArray *hhmmssMsArray = [hhmmss componentsSeparatedByString:decimalSep];
    if ( ! hhmmssMsArray || hhmmssMsArray.count > 2)
    {
        return 0;
    }

    double ms = 0;
    if (hhmmssMsArray.count == 2)
    {
        NSString *msStr = [hhmmssMsArray objectAtIndex:1];
        if (msStr && msStr.length > 0)
        {
            msStr = SFmt(@"%@%@", decimalSep, msStr);
            ms = msStr.doubleValue;
        }
    }

    hhmmss = [hhmmssMsArray objectAtIndex:0];

    // Normalize time format by converting "HH:MM:SS" to "HHMMSS" and "MM:SS" to "HHMMSS".
    hhmmss = [MAUtil padHHMMSSFront:hhmmss];
    hhmmss = [hhmmss stringByReplacingOccurrencesOfString:@":" withString:@""];
    assert(hhmmss.length == 6);

    // Extract separate hour, minute, and second components.
    NSRange range;
    range.length = 2;
    range.location = 0;
    
    NSInteger hh = [[hhmmss substringWithRange:range] integerValue];
    range.location += range.length;
    
    NSInteger mm = [[hhmmss substringWithRange:range] integerValue];
    range.location += range.length;
    
    double ss = [[hhmmss substringWithRange:range] doubleValue];
    ss += ms;

    // Calculate in terms of minutes.
    double minutes = mm;
    
    static double const minutes_in_hour = 60;
    minutes += hh * minutes_in_hour;
    
    static double const seconds_in_minutes = 60;
    minutes += ss / seconds_in_minutes;
    
    return minutes;
}

+ (NSString *)padHHMMSS:(NSString *)hhmmss
{
    return [MAUtil padHHMMSSBack:hhmmss];
}

+ (NSString *)padHHMMSSBack:(NSString *)hhmmss
{
    // Likely case is first for efficiency.
    if (hhmmss && hhmmss.length == 8)
    {
        return hhmmss;
    }
    
    if (!hhmmss || hhmmss.length == 0)
    {
        return SFmt(@"00:00:00");
    }
    else if (hhmmss.length == 1)
    {
        return SFmt(@"%@0:00:00", hhmmss);
    }
    else if (hhmmss.length == 2)
    {
        return SFmt(@"%@:00:00", hhmmss);
    }
    else if (hhmmss.length == 3)
    {
        return SFmt(@"%@00:00", hhmmss);
    }
    else if (hhmmss.length == 4)
    {
        return SFmt(@"%@0:00", hhmmss);
    }
    else if (hhmmss.length == 5)
    {
        return SFmt(@"%@:00", hhmmss);
    }
    else if (hhmmss.length == 6)
    {
        return SFmt(@"%@00", hhmmss);
    }
    else if (hhmmss.length == 7)
    {
        return SFmt(@"%@0", hhmmss);
    }
    
    return hhmmss;
}

+ (NSString *)padHHMMSSFront:(NSString *)hhmmss
{
    // Likely case is first for efficiency.
    if (hhmmss && hhmmss.length == 8)
    {
        return hhmmss;
    }
    
    // TODO: Only pad the front if the putting : when user types next character not before. I.e., type 12 just displays "12", not "12:".
    if ( ! hhmmss || hhmmss.length == 0)
    {
        return SFmt(@"00:00:00");
    }
    else if (hhmmss.length == 1)
    {
        return SFmt(@"00:00:0%@", hhmmss);
    }
    else if (hhmmss.length == 2)
    {
        return SFmt(@"00:00:%@", hhmmss);
    }
    else if (hhmmss.length == 3)
    {
        return SFmt(@"00:00%@", hhmmss);
    }
    else if (hhmmss.length == 4)
    {
        return SFmt(@"00:0%@", hhmmss);
    }
    else if (hhmmss.length == 5)
    {
        return SFmt(@"00:%@", hhmmss);
    }
    else if (hhmmss.length == 6)
    {
        return SFmt(@"00%@", hhmmss);
    }
    else if (hhmmss.length == 7)
    {
        return SFmt(@"0%@", hhmmss);
    }
    
    return hhmmss;
}

+ (NSArray *)localizeArray:(NSArray *)array reverseMap:(NSMutableDictionary *)reverseMap
{
    if (!array)
    {
        return nil;
    }
    
    NSMutableArray *localizedArray = [[NSMutableArray alloc] initWithCapacity:array.count];
    for (NSUInteger i = 0; i != array.count; ++i)
    {
        NSString *value = [array objectAtIndex:i];
        NSString *localized_value = Localize(value);
        [localizedArray setObject:localized_value atIndexedSubscript:i];
        if (reverseMap)
        {
            [reverseMap setObject:value forKey:localized_value];
        }
    }
    
    return localizedArray;
}

+ (NSArray *)localizeArray:(NSArray *)array
{
    return [MAUtil localizeArray:array reverseMap:nil];
}

+ (NSString *)nameFromUnitAbbreviation:(NSString *)unit
{
    NSString *name = nil;
    if ([unit isEqualToString:@"mi"])
    {
        name = Localize(@"Miles");
    }
    else if ([unit isEqualToString:@"km"])
    {
        name = Localize(@"Kilometers");
    }
    else if ([unit isEqualToString:@"m"])
    {
        name = Localize(@"Meters");
    }
    else if ([unit isEqualToString:@"lb"])
    {
        name = Localize(@"Pounds");
    }
    else if ([unit isEqualToString:@"kg"])
    {
        name = Localize(@"Kilograms");
    }
    else if ([unit isEqualToString:@"st"])
    {
        name = Localize(@"Stones");
    }
    return name;
}

+ (NSString *)abbreviationFromUnitName:(NSString *)name
{
    NSString *unit = nil;
    if ([name isEqualToString:Localize(@"Miles")])
    {
        unit = @"mi";
    }
    else if ([name isEqualToString:Localize(@"Kilometers")])
    {
        unit = @"km";
    }
    else if ([name isEqualToString:Localize(@"Meters")])
    {
        unit = @"m";
    }
    else if ([name isEqualToString:Localize(@"Pounds")])
    {
        unit = @"lb";
    }
    else if ([name isEqualToString:Localize(@"Kilograms")])
    {
        unit = @"kg";
    }
    else if ([name isEqualToString:Localize(@"Stones")])
    {
        unit = @"st";
    }
    return unit;
}

+ (BOOL)isWeightUnit:(NSString *)unit
{
    return [unit isEqualToString:@"lb"] || [unit isEqualToString:@"kg"];
}

+ (BOOL)isDistanceUnit:(NSString *)unit
{
    return [unit isEqualToString:@"mi"] || [unit isEqualToString:@"km"];
}

+ (BOOL)isHeightUnit:(NSString *)unit
{
    return [unit isEqualToString:@"in"] || [unit isEqualToString:@"m"];
}

+ (double)inchToMeter:(double)inch
{
    static double const InchToMeterFactor = 0.0254;
    return inch * InchToMeterFactor;
}

+ (double)meterToInch:(double)meter
{
    static double const MeterToInchFactor = 39.3701;
    return meter * MeterToInchFactor;
}

+ (double)convertHeight:(double)height unit:(NSString *)unit newUnit:(NSString *)newUnit
{
    if ([unit isEqualToString:newUnit])
    {
        return height;
    }
    
    if ([newUnit isEqualToString:@"in"]
        || [newUnit isEqualToString:@"lb"])
    {
        return [MAUtil meterToInch:height];
    }
    else
    {
        return [MAUtil inchToMeter:height];
    }
}

+ (double)poundToKilogram:(double)pound
{
    static double const ConversionFactor = 0.453592;
    return pound * ConversionFactor;
}

+ (double)kilogramToPound:(double)kilogram
{
    static double const ConversionFactor = 2.20462;
    return kilogram * ConversionFactor;
}

+ (double)mileToKilometer:(double)mile
{
    static double const ConversionFactor = 1.60934;
    return mile * ConversionFactor;
}

+ (double)kilometerToMile:(double)kilometer
{
    static double const ConversionFactor = 0.621371;
    return kilometer * ConversionFactor;
}

+ (double)mileToMeter:(double)mile
{
    static double const ConversionFactor = 1609.34;
    return mile * ConversionFactor;
}

+ (double)kilometerToMeter:(double)kilometer
{
    static double const ConversionFactor = 1000;
    return kilometer * ConversionFactor;
}

+ (double)meterToMile:(double)meter
{
    static double const ConversionFactor = 0.000621371;
    return meter * ConversionFactor;
}

+ (double)metertoKilometer:(double)meter
{
    static double const ConversionFactor = 0.001;
    return meter * ConversionFactor;
}

// Convert to and from stones.
+ (double)poundToStone:(double)value
{
    static double const ConversionFactor = 0.0714286;
    return value * ConversionFactor;
}
+ (double)kilogramToStone:(double)value
{
    static double const ConversionFactor = 0.157473;
    return value * ConversionFactor;
}
+ (double)stoneToPound:(double)value
{
    static double const ConversionFactor = 14;
    return value * ConversionFactor;
}
+ (double)stoneToKilogram:(double)value
{
    static double const ConversionFactor = 6.35029;
    return value * ConversionFactor;
}

// Convert weight to new unit. If the new unit is the same as the old unit, the same value is returned.
// Also converts distance: miles to kilometers and vice versa.
+ (double)convertWeight:(double)weight unit:(NSString *)unit newUnit:(NSString *)newUnit
{
    if ([unit isEqualToString:newUnit])
    {
        return weight;
    }
    
    // Weight conversion.
    if ([newUnit isEqualToString:@"lb"]) // To pounds.
    {
        if ([unit isEqualToString:@"kg"] || [unit isEqualToString:@"km"])
        {
            return [MAUtil kilogramToPound:weight];
        }
    }
    else if ([newUnit isEqualToString:@"kg"]) // To kilograms.
    {
        if ([unit isEqualToString:@"lb"] || [unit isEqualToString:@"mi"])
        {
            return [MAUtil poundToKilogram:weight];
        }
    }
    
    // Distance conversion.
    else if ([newUnit isEqualToString:@"mi"]) // To miles.
    {
        if ([unit isEqualToString:@"kg"] || [unit isEqualToString:@"km"])
        {
            return [MAUtil kilometerToMile:weight];
        }
        else if ([unit isEqualToString:@"m"])
        {
            return [MAUtil meterToMile:weight];
        }
    }
    else if ([newUnit isEqualToString:@"km"]) // To kilometers.
    {
        if ([unit isEqualToString:@"lb"] || [unit isEqualToString:@"mi"])
        {
            return [MAUtil mileToKilometer:weight];
        }
        else if ([unit isEqualToString:@"m"])
        {
            return [MAUtil metertoKilometer:weight];
        }
    }
    else if ([newUnit isEqualToString:@"m"]) // To meters.
    {
        if ([unit isEqualToString:@"lb"] || [unit isEqualToString:@"mi"])
        {
            return [MAUtil mileToMeter:weight];
        }
        else if ([unit isEqualToString:@"kg"] || [unit isEqualToString:@"km"])
        {
            return [MAUtil kilometerToMeter:weight];
        }
    }

    // Bodyweight to and from stones.
    else if ([newUnit isEqualToString:@"st"]) // To stones.
    {
        if ([unit isEqualToString:@"lb"] || [unit isEqualToString:@"mi"])
        {
            return [MAUtil poundToStone:weight];
        }
        else if ([unit isEqualToString:@"kg"] || [unit isEqualToString:@"km"])
        {
            return [MAUtil kilogramToStone:weight];
        }
    }
    else if ([unit isEqualToString:@"st"]) // From stones.
    {
        if ([newUnit isEqualToString:@"lb"] || [newUnit isEqualToString:@"mi"])
        {
            return [MAUtil stoneToPound:weight];
        }
        else if ([newUnit isEqualToString:@"kg"] || [newUnit isEqualToString:@"km"])
        {
            return [MAUtil stoneToKilogram:weight];
        }
    }

    return weight;
}

// Copy contents of an NSString instance into an NSData instance.
// The bytes stored in the NSData instance will be in UTF-16 format and null-terminated.
+ (NSData *)dataFromString:(NSString *)string
{
    // Allocate buffer with the number of bytes given by length of string and null terminator with 2 bytes per character for UTF-16.
    // Note: sizeof(unichar) == 2 != 1 == sizeof(u_char).
    size_t const length = (string.length + 1) * sizeof(unichar);
    u_char *bytes = (u_char *) malloc(length);
    if (bytes == NULL)
    {
        return nil;
    }
    
    // Convert string to bytes in UTF-16.
    NSUInteger usedLength = 0;
    NSRange range;
    range.location = 0;
    range.length = string.length;
    BOOL const didGetBytes = [string getBytes:bytes maxLength:length usedLength:&usedLength encoding:NSUnicodeStringEncoding options:NSStringEncodingConversionAllowLossy range:range remainingRange:NULL];
    if (!didGetBytes)
    {
        free(bytes);
        return nil;
    }
    assert(usedLength == (length - sizeof(unichar))); // Should have copied entire string without null terminator.
    
    // Null-terminate the buffer (2 null bytes for UTF-16).
    // This is not necessary for conversion back to NSString but is necessary for some functions like sqlite3_open16 that rely on a null terminator rather than a buffer count.
    bytes[usedLength] = '\0';
    bytes[usedLength + 1] = '\0';
    
    // Store bytes in NSData instance with data taking ownership of bytes to ensure free() is called automatically on deallocation.
    NSData *data = [NSData dataWithBytesNoCopy:bytes length:length];
    return data;
}

// Copy contents of an NSData instance into an NSString instance.
// The bytes in the NSData instance must be in UTF-16 format and null-terminated, such as is generated by dataFromString.
+ (NSString *)stringFromData:(NSData *)data
{
    // NSString does not expect a null terminator and expects number of characters, not number of bytes.
    NSUInteger const length = (data.length - 1) / sizeof(unichar);
    NSString *string = [NSString stringWithCharacters:data.bytes length:length];
    return string;
}

+ (NSString *)escapeCharsInString:(NSString *)string
{
    // Double quotes are escaped in CSV files by two double quote characters.
    string = [string stringByReplacingOccurrencesOfString:@"\"" withString:@"\"\""];
    return string;
}

+ (NSArray *)splitString:(NSString *)string delimiter:(unichar)delimiter escape:(unichar)escape
{
    NSMutableArray *strings = [[NSMutableArray alloc] init];
    NSMutableString *currentString = [[NSMutableString alloc] init];
    
    BOOL seenEscapedCharacter = NO;
    
    for (int i = 0; i != string.length; ++i)
    {
        unichar character = [string characterAtIndex:i];
        if (seenEscapedCharacter)
        {
            // Appends any character after the escape character, including the delimiter.
            [currentString appendFormat:@"%C", character];
            seenEscapedCharacter = NO;
        }
        else if (character == escape)
        {
            seenEscapedCharacter = YES;
        }
        else if (character == delimiter)
        {
            [strings addObject:currentString];
            currentString = [[NSMutableString alloc] init];
        }
        else
        {
            [currentString appendFormat:@"%C", character];
        }
    }
    [strings addObject:currentString];
    
    return [NSArray arrayWithArray:strings];
}

// Split a single row that is in CSV format. Uses commas as delimiters. Commas can be escaped, that is, used literally, by surrounding them in double quotes, ". Use 2 double quotes to yield a single double quotes character inside of a double-quoted string. For example, the line
// A,"I said, ""Hello, world.""",B,"",C
// will produce an array with the following strings
// A
// I said, "Hello, world."
// B
//
// C
// Note that column 4 (between the columns with strings "B" and "C") is empty as "" is interpreted as a quoted string containing no character, not an escape for a single ".
// https://en.wikipedia.org/wiki/Comma-separated_values#Basic_rules_and_examples
+ (NSArray *)splitCSVString:(NSString *)string
{
    //DLog(@"Input string: '%@'", string);
    //DLog(@"Input string count: %d", string.length);
    
    // Comma is delimiter.
    unichar const comma = 0x002C;
    
    // Double quotes block off a section of text including a section of text. Two double-quotes are used for a single double-quotes character.
    unichar const quotes = 0x0022;
    
    // Check for and skip byte order mark if it is the first character. The character must match the bytes that the CSV export method byteOrderMark returns. Handle both little-endian and big-endian encodings.
    // https://en.wikipedia.org/wiki/Byte_order_mark
    unichar const byteOrderMarkLE = 0xFEFF;
    unichar const byteOrderMarkBE = 0xFFFE;

    NSMutableArray *strings = [[NSMutableArray alloc] init];
    NSMutableString *currentString = [[NSMutableString alloc] init];
    
    BOOL searchingForQuotesStart = YES;
    BOOL areInsideQuotedString = NO;
    BOOL wasQuotesCharacterPrevious = NO;
    
    for (int i = 0; i != string.length; ++i)
    {
        //DLog(@"Current string: '%@'", currentString);
        //DLog(@"Current string count: %d", currentString.length);

        unichar character = [string characterAtIndex:i];
        //DLog(@"Current char: '%C'", character);
        
        if (i == 0 && (character == byteOrderMarkLE || character == byteOrderMarkBE))
        {
            DLog(@"Ignoring BOM");
            continue;
        }
        else if (character == quotes)
        {
            // Start of quoted column, for example:  ,"
            if (searchingForQuotesStart)
            {
                areInsideQuotedString = YES;
                searchingForQuotesStart = NO;
                // Note: do not set 'wasQuotesCharacterPrevious = YES' because this quotes cannot be escaped to yield a literal quotes, for example:  ,"", should yield an empty column, not ".
            }
            else if (wasQuotesCharacterPrevious)
            {
                // 2 x quotes so append a single quotes character, for example:  ,"hi""yo"
                [currentString appendFormat:@"%C", character];
                wasQuotesCharacterPrevious = NO;
            }
            else
            {
                // Mark that a single quotes character has been seen so that a second quotes character can be detected as above.
                // Note: if inside_quotes == NO and no second quotes character is seen, then this single quotes character will be silently ignored.
                wasQuotesCharacterPrevious = YES;
            }
        }
        else if (character == comma)
        {
            // Either was not not inside of quotes to begin with or the previous character was a quotes, so now are outside of quotes.
            if (!areInsideQuotedString || wasQuotesCharacterPrevious)
            {
                // Start new string.
                [strings addObject:currentString];
                currentString = [[NSMutableString alloc] init];
                areInsideQuotedString = NO;
                searchingForQuotesStart = YES;
            }
            else // (insideQuotes && !wasQuotesCharacterPrevious)
            {
                // Append delimiter since inside of quotes.
                [currentString appendFormat:@"%C", character];
            }
            wasQuotesCharacterPrevious = NO;
        }
        else // Regular character: neither quotes nor comma.
        {
            if (wasQuotesCharacterPrevious)
            {
                // Marks end of quoted substring in column:  ,a"b,c"d,
                // where the column will contain ab,cd
                areInsideQuotedString = NO;
                wasQuotesCharacterPrevious = NO;
                searchingForQuotesStart = YES;
            }
            
            // Append regular character.
            [currentString appendFormat:@"%C", character];
        }
    }
    [strings addObject:currentString];
    
    return strings;
}

+ (UILabel *)navView:(UIView *)navView withBackgroundColor:(UIColor *)backgroundColor
{
    CGRect frame = CGRectMake(0, 0, navView.bounds.size.width, 25);
    UILabel *headerView = [[UILabel alloc] initWithFrame:frame];
    [headerView setBackgroundColor:backgroundColor];
    headerView.font = [UIFont boldSystemFontOfSize:18.0];
    headerView.adjustsFontSizeToFitWidth = YES;
    headerView.textColor = [UIColor whiteColor];
    
    // Apply gradient.
    CGRect bounds = headerView.bounds;
	CAGradientLayer *gradient = [[CAGradientLayer alloc] init];
	gradient.frame = CGRectMake(bounds.origin.x
                                , bounds.origin.y
                                , bounds.size.width
                                , bounds.size.height / 2
                                );
	gradient.colors = [NSArray arrayWithObjects:
                       (id)[MO_RGBACOLOR(255, 255, 255, 0.45) CGColor]
                       , (id)[MO_RGBACOLOR(255, 235, 255, 0.1) CGColor]
                       , nil];
	[headerView.layer insertSublayer:gradient atIndex:0];
    
    return headerView;
}

+ (void)addGradientToView:(UIView *)view
{
    // Add Border
    CALayer *layer = view.layer;
    layer.cornerRadius = 8.0f;
    layer.masksToBounds = YES;
    layer.borderWidth = 1.0f;
    layer.borderColor = [UIColor colorWithWhite:0.5f alpha:0.2f].CGColor;
    
    // Add Shine
    CAGradientLayer *shineLayer = [CAGradientLayer layer];
    shineLayer.frame = layer.bounds;
    shineLayer.colors = [NSArray arrayWithObjects:
                         (id)[UIColor colorWithWhite:1.0f alpha:0.4f].CGColor,
                         (id)[UIColor colorWithWhite:1.0f alpha:0.2f].CGColor,
                         (id)[UIColor colorWithWhite:0.75f alpha:0.2f].CGColor,
                         (id)[UIColor colorWithWhite:0.4f alpha:0.2f].CGColor,
                         (id)[UIColor colorWithWhite:1.0f alpha:0.4f].CGColor,
                         nil];
    shineLayer.locations = [NSArray arrayWithObjects:
                            [NSNumber numberWithFloat:0.0f],
                            [NSNumber numberWithFloat:0.5f],
                            [NSNumber numberWithFloat:0.5f],
                            [NSNumber numberWithFloat:0.8f],
                            [NSNumber numberWithFloat:1.0f],
                            nil];
    [layer addSublayer:shineLayer];
}

+ (BOOL)isStringOn:(NSString *)string
{
    return string && [string isEqualToString:@"on"];
}

+ (NSString *)formatWeight:(NSNumber *)weight
                     units:(NSString *)units
                prevWeight:(NSNumber *)prevWeight
{
    double weightGain = weight.doubleValue - prevWeight.doubleValue;
    //if (weightGain != 0)
    {
        NSString *sign = @"+";
        if (weightGain < 0)
        {
            sign = @"";
        }
        
        NSString *weightGainStr = [MAUtil formatDouble:weightGain];
        return [NSString stringWithFormat:
                @"%@ %@ (%@%@)"
                , [MAUtil formatDouble:weight.doubleValue]
                , units
                , sign
                , weightGainStr
                ];
    }
    /*
     else
     {
     return [NSString stringWithFormat:
     @"%@ %@ (=) ― %@"
     , [MAUtil formatDouble:weight.doubleValue]
     , units
     , time
     ];
     }
     */
}

+ (NSString *)formatWeight:(NSNumber *)weight
                     units:(NSString *)units
                      time:(NSString *)time
                prevWeight:(NSNumber *)prevWeight
{
    NSDate *dateTime = [MADateUtil dateFromString:time];
    NSString *date = [MADateUtil formatDateForSection:dateTime];
    time = [MADateUtil timeFromDate:dateTime];
    
    double weightGain = weight.doubleValue - prevWeight.doubleValue;
    //if (weightGain != 0)
    {
        NSString *sign = @"+";
        if (weightGain < 0)
        {
            sign = @"";
        }
        
        NSString *weightGainStr = [MAUtil formatDouble:weightGain];
        return [NSString stringWithFormat:
                @"%@ %@ (%@%@) ― %@ ― %@"
                , [MAUtil formatDouble:weight.doubleValue]
                , units
                , sign
                , weightGainStr
                , date
                , time
                ];
    }
    /*
     else
     {
     return [NSString stringWithFormat:
     @"%@ %@ (=) ― %@"
     , [MAUtil formatDouble:weight.doubleValue]
     , units
     , time
     ];
     }
     */
}

+ (NSString *)formatWeight:(NSNumber *)weight
                     units:(NSString *)units
                      time:(NSString *)time
{
    return [NSString stringWithFormat:
            @"%@ %@"
            , [MAUtil formatDouble:weight.doubleValue]
            , units
            ];
}

+ (double)calculateBMI:(double)weight weightUnits:(NSString *)weightUnits height:(double)height heightUnits:(NSString *)heightUnits
{
    // BMI calculation requires both weight and height. Return 0 if height is 0 even though it is technically undefined.
    if (weight == 0 || height == 0)
    {
        return 0;
    }
    
    // Convert units to metric if necessary.
    double weightInKilograms = weight;
    NSString *newUnit = @"kg";
    if (![weightUnits isEqualToString:newUnit])
    {
        weightInKilograms = [MAUtil convertWeight:weight unit:weightUnits newUnit:newUnit];
    }
    
    double heightInMeters = height;
    if ([heightUnits isEqualToString:@"in"])
    {
        heightInMeters = [MAUtil inchToMeter:height];
    }
    
    // Calculate BMI assuming units are all in metric.
    double bmi = weightInKilograms / (heightInMeters * heightInMeters);
    return bmi;
}

+ (NSArray *)sortStringArray:(NSArray *)array ascending:(BOOL)ascending
{
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:nil ascending:ascending selector:@selector(localizedCompare:)];
    return [array sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
}
+ (NSArray *)sortStringArray:(NSArray *)array
{
    return [MAUtil sortStringArray:array ascending:YES];
}
+ (NSArray *)reverseSortStringArray:(NSArray *)array
{
    return [MAUtil sortStringArray:array ascending:NO];
}

+ (double)calculatePercentageChange:(double)newValue oldValue:(double)oldValue
{
    if (oldValue == 0)
    {
        if (newValue == 0)
        {
            // No change.
            return 0;
        }
        
        // Default to 100% change if no previous value.
        return 100;
    }
    
    return 100. * (newValue - oldValue) / fabs(oldValue);
}

+ (void)showActivityIndicatorInTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath receiver:(NSObject *)receiver performSelector:(SEL)aSelector withObject:(id)anArgument afterDelay:(NSTimeInterval)delay
{
    // http://stackoverflow.com/questions/6342553/activity-indicators-when-pushing-next-view-didselectrowatindexpath
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:[MAAppearance tableViewActivityIndicatorStyle]];
    cell.accessoryView = spinner;
    [spinner startAnimating];
    
    [receiver performSelector:aSelector withObject:anArgument afterDelay:delay];
}

// Fades out top and bottom cells in table view as they leave the screen.
// http://stackoverflow.com/questions/5000354/how-to-fade-the-content-of-cell-of-table-view-which-reaches-at-the-top-while-scr
+ (void)fadeOutTableView:(UITableView *)tableView
{
    NSArray *visibleCells = [tableView visibleCells];
    if (visibleCells == nil || visibleCells.count == 0)
    {
        return;
    }
    
    // Make sure other cells stay opaque.
    // Avoids issues with skipped method calls during rapid scrolling
    for (UITableViewCell *cell in visibleCells)
    {
        cell.contentView.alpha = 1.0;
    }
    
    // Get top and bottom cells.
    UITableViewCell *topCell = [visibleCells objectAtIndex:0];
    UITableViewCell *bottomCell = [visibleCells lastObject];
    
    // Set necessary constants.
    NSInteger cellHeight = topCell.frame.size.height - 1;   // -1 to allow for typical separator line height.
    NSInteger tableViewTopPosition = tableView.frame.origin.y;
    NSInteger tableViewBottomPosition = tableView.frame.origin.y + tableView.frame.size.height;
    
    // Get content offset to set opacity.
    CGRect topCellPositionInTableView = [tableView rectForRowAtIndexPath:[tableView indexPathForCell:topCell]];
    CGRect bottomCellPositionInTableView = [tableView rectForRowAtIndexPath:[tableView indexPathForCell:bottomCell]];
    CGFloat topCellPosition = [tableView convertRect:topCellPositionInTableView toView:[tableView superview]].origin.y;
    CGFloat bottomCellPosition = ([tableView convertRect:bottomCellPositionInTableView toView:[tableView superview]].origin.y + cellHeight);
    
    // Set opacity based on amount of cell that is outside of view.
    CGFloat modifier = 3.5;     /* Increases the speed of fading (1.0 for fully transparent when the cell is entirely off the screen,
                                 2.0 for fully transparent when the cell is half off the screen, etc) */
    CGFloat topCellOpacity = (1.0f - ((tableViewTopPosition - topCellPosition) / cellHeight) * modifier);
    CGFloat bottomCellOpacity = (1.0f - ((bottomCellPosition - tableViewBottomPosition) / cellHeight) * modifier);
    
    // Set cell opacity.
    if (topCell)
    {
        topCell.contentView.alpha = topCellOpacity;
    }
    if (bottomCell)
    {
        bottomCell.contentView.alpha = bottomCellOpacity;
    }
}

+ (NSString *)setSeparator
{
    return @"×"; // Unicode character for multiplication sign u00D7.
}
+ (NSString *)starSymbol
{
    return @"☆";
    //return @"★";
}
+ (NSString *)maxSymbol
{
    //return @"Max";

    // This is what the Weather app uses for the high, so it makes since to use as the max. However, it does not display properly for some reason, as a ? instead of as an arrow. Perhaps it's a font issue or an issue using attributed text.
    //return @"⤒";
    //return @"\u2912";

    //return @"↑";
    //return @"⇧";
    
    return [MAUtil starSymbol];
    
    //return @"⇯";
    //return @"⊼";
    //return @"∨";
    //return @"⌆";
    //return @"⌅";
    //return @"≛";
    //return @"≤";
    //return @"↥";
}
+ (NSString *)repSymbol
{
    return @"Reps";
    //return [MAUtil setSeparator];
}
+ (NSString *)weightSymbol
{
    return @"Weight";
    //return @"#";
    
    //MAUserUtil *userUtil = [MAUserUtil sharedInstance];
    //return [userUtil objectForKey:WeightUnit];
}
+ (NSString *)totalSymbol
{
    return @"Total";
    //return @"∑";
}
+ (NSString *)timeSymbol
{
    return @"Time";
    
    // http://stackoverflow.com/questions/5437674/what-unicode-character-is-a-good-mark-of-time
    //return @"⌛";
    //return @"⌚";
    //return @"⏳";
    //return @"⧖";
    //return @"⧗";
    //return @"🕒";
}
+ (NSString *)distanceSymbol
{
    return @"Distance";
    //return @"➠";
    //return @"📏";
    
    //return @"⤏";
    //return @"⤍";
    //return @"⤐";
    
    //MAUserUtil *userUtil = [MAUserUtil sharedInstance];
    //return [userUtil objectForKey:CardioUnit];
}
+ (NSString *)maxRepsString
{
    return Localize(SFmt(@"%@ %@", [MAUtil maxSymbol], [MAUtil repSymbol]));
}
+ (NSString *)maxWeightString
{
    return Localize(SFmt(@"%@ %@", [MAUtil maxSymbol], [MAUtil weightSymbol]));
}
+ (NSString *)maxTotalString
{
    return Localize(SFmt(@"%@ %@", [MAUtil maxSymbol], [MAUtil totalSymbol]));
}
+ (NSString *)maxTimeString
{
    return Localize(SFmt(@"%@ %@", [MAUtil maxSymbol], [MAUtil timeSymbol]));
}
+ (NSString *)maxDistanceString
{
    return Localize(SFmt(@"%@ %@", [MAUtil maxSymbol], [MAUtil distanceSymbol]));
}

+ (BOOL)stringArray:(NSArray *)array1 isEqualToStringArray:(NSArray *)array2
{
    if (array1 == array2)
    {
        return YES;
    }
    
    if (array1.count != array2.count)
    {
        return NO;
    }
    
    for (NSUInteger i = 0; i != array1.count; ++i)
    {
        NSString *value1 = [array1 objectAtIndex:i];
        NSString *value2 = [array2 objectAtIndex:i];
        if (![value1 isEqualToString:value2])
        {
            return NO;
        }
    }

    return YES;
}

+ (CGFloat)rowHeightForTableView:(UITableView *)tableView
{
    // Use the table view's row heigh by default, but double-check the value because it can be -1 on iOS 8 Beta.
    CGFloat rowHeight = tableView.rowHeight;
    if (rowHeight < 0)
    {
        rowHeight = 44;
    }
    return rowHeight;
}

@end
