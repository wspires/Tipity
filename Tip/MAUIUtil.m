//
//  MAUIUtil.m
//  Tip
//
//  Created by Wade Spires on 6/26/15.
//  Copyright © 2015 Minds Aspire LLC. All rights reserved.
//

#import "MAUIUtil.h"

#import "MAAppearance.h"
#import "MADefines.h"
#import "MADeviceUtil.h"
#import "MALogUtil.h"
#import "MAUtil.h"

@implementation MAUIUtil

// Set the title for the navigation window and make it adjust the font
// size for any length string.
// Note: Must call this from viewWillLoad so that the title gets set properly the first time it's viewed. Call '[MAUIUtil updateNavItem:self.navigationItem withTitle:self.title];' from viewWillAppear to update the title (possibly with a new font color, too).
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

+ (NSError *)makeError:(NSString *)msg
{
    NSMutableDictionary* details = [NSMutableDictionary dictionary];
    [details setValue:msg forKey:NSLocalizedDescriptionKey];
    NSError *error = [NSError errorWithDomain:@"world" code:200 userInfo:details];
    return error;
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
        [MAUIUtil findMisbehavingScrollViewsIn:subview];
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
    [MAUIUtil brieflyHighlightCells:[NSArray arrayWithObjects:indexPath, nil] forTableView:tableView];
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
    if ([MADeviceUtil iPad])
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
        
        NSNumberFormatter *hhmmssFormatter = [MAUIUtil hhmmssFormatter];
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
            
            NSNumberFormatter *millisecondFormatter = [MAUIUtil millisecondFormatter];
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

+ (BOOL)automaticDecimalTextField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *decimalSep = [[NSLocale autoupdatingCurrentLocale] objectForKey:NSLocaleDecimalSeparator];
    
    // Disallow characters other than 0-9 and '.'.
    NSMutableCharacterSet *digitDecimalCharSet = [NSMutableCharacterSet decimalDigitCharacterSet];
    [digitDecimalCharSet addCharactersInString:decimalSep];
    NSString *remainingChars = [string stringByTrimmingCharactersInSet:[digitDecimalCharSet invertedSet]];
    BOOL numCheckOkay = (remainingChars.length == string.length);
    if ( ! numCheckOkay)
    {
        return NO;
    }
    
    NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (newText.length == 0)
    {
        return YES;
    }

    NSArray *billArray = [newText componentsSeparatedByString:decimalSep];
    if ( ! billArray || billArray.count > 2)
    {
        return NO;
    }
    
    newText = [newText stringByReplacingOccurrencesOfString:decimalSep withString:@""];
    
    if ([newText isEqualToString:@"00"] || newText.length == 0)
    {
        // "00" means delete the entire string because, for instance, removing "1" from "001" (originally "0.01").
        textField.text = @"";
        return NO;
    }
    else if (newText.length == 1)
    {
        newText = SFmt(@"0%@0%@", decimalSep, newText);
    }
    else if (newText.length == 2)
    {
        newText = SFmt(@"0%@%@", decimalSep, newText);
    }
    else // (dollars.length >= 3)
    {
        // Fix the position of the decimal point, which will automatically shift over any digits.
        NSUInteger decimalIdx = newText.length - 2;
        NSString *dollars = [newText substringToIndex:decimalIdx];
        NSString *cents = [newText substringFromIndex:decimalIdx];
        newText = SFmt(@"%@%@%@", dollars, decimalSep, cents);
        
        // Remove possible leading "00", "01", etc., but accept "0.12".
        NSString *firstChar = [newText substringToIndex:1];
        if ([firstChar isEqualToString:@"0"])
        {
            NSRange range = NSMakeRange(1, 1);
            NSString *secondChar = [newText substringWithRange:range];
            if ( ! [secondChar isEqualToString:decimalSep])
            {
                newText = [newText substringFromIndex:1];
            }
        }
    }
    
    textField.text = newText;
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
    hhmmss = [MAUIUtil padHHMMSSFront:hhmmss];
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
    return [MAUIUtil padHHMMSSBack:hhmmss];
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
