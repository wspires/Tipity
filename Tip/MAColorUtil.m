//
//  MAColorUtil.m
//  Gym Log
//
//  Created by Wade Spires on 9/4/13.
//
//

#import "MAColorUtil.h"

#import "MAAppearance.h"
#import "MAUtil.h"
#import "MAUserUtil.h"

// http://www.cs.rit.edu/~ncs/color/t_convert.html
// r,g,b values are from 0 to 1
// h = [0,360], s = [0,1], v = [0,1]
//		if s == 0, then h = -1 (undefined)
void RGBtoHSV( float r, float g, float b, float *h, float *s, float *v )
{
	float min, max, delta;
	min = MIN3( r, g, b );
	max = MAX3( r, g, b );
	*v = max;				// v
	delta = max - min;
	if( max != 0 )
		*s = delta / max;		// s
	else {
		// r = g = b = 0		// s = 0, v is undefined
		*s = 0;
		*h = -1;
		return;
	}
	if( r == max )
		*h = ( g - b ) / delta;		// between yellow & magenta
	else if( g == max )
		*h = 2 + ( b - r ) / delta;	// between cyan & yellow
	else
		*h = 4 + ( r - g ) / delta;	// between magenta & cyan
	*h *= 60;				// degrees
	if( *h < 0 )
		*h += 360;
}

void HSVtoRGB( float *r, float *g, float *b, float h, float s, float v )
{
	int i;
	float f, p, q, t;
	if( s == 0 ) {
		// achromatic (grey)
		*r = *g = *b = v;
		return;
	}
	h /= 60;			// sector 0 to 5
	i = floor( h );
	f = h - i;			// factorial part of h
	p = v * ( 1 - s );
	q = v * ( 1 - s * f );
	t = v * ( 1 - s * ( 1 - f ) );
	switch( i ) {
		case 0:
			*r = v;
			*g = t;
			*b = p;
			break;
		case 1:
			*r = q;
			*g = v;
			*b = p;
			break;
		case 2:
			*r = p;
			*g = v;
			*b = t;
			break;
		case 3:
			*r = p;
			*g = q;
			*b = v;
			break;
		case 4:
			*r = t;
			*g = p;
			*b = v;
			break;
		default:		// case 5:
			*r = v;
			*g = p;
			*b = q;
			break;
	}
}

@implementation MAColorUtil

+ (BOOL)isDarkColor:(UIColor *)color
{
    return [MAColorUtil isRGBMaxDarkColor:color];
    //return [MAColorUtil isRGBSumDarkColor:color];
}

+ (BOOL)isRGBMaxDarkColor:(UIColor *)color
{
    BOOL isDark = NO;

    // Convert RGB to HSV/HSB and use the value/black component and use light text if the value < 255/2. The value component of HSV is calculated by taking the max(red, green, blue), so would use light text if any of red, green, or blue, is greater than 128.
    static CGFloat const threshold = 255. / 2.;
    
    CGFloat red, green, blue, alpha;
    BOOL const wasConverted = [color getRed:&red green:&green blue:&blue alpha:&alpha];
    if (wasConverted)
    {
        static CGFloat const scaleFactor = 255.; // RGB components are in the range [0, 1], so rescale them to range [0, 255].
        CGFloat maxValue = MAX3(red, green, blue);
        CGFloat const value = scaleFactor * maxValue;
        isDark = value < threshold;
    }
    
    return isDark;
}

+ (BOOL)isRGBSumDarkColor:(UIColor *)color
{
    BOOL isDark = NO;
    
    // Method comes from here:
    // http://stackoverflow.com/questions/8741479/automatically-determine-optimal-fontcolor-by-backgroundcolor
    static CGFloat const threshold = (255. + 255. + 255.) / 2.; // == 382.5
    
    CGFloat red, green, blue, alpha;
    BOOL const wasConverted = [color getRed:&red green:&green blue:&blue alpha:&alpha];
    if (wasConverted)
    {
        static CGFloat const scaleFactor = 3 * 255.; // RGB components are in the range [0, 1], so rescale them to range [0, 255].
        CGFloat const rgbSum = scaleFactor * (red + green + blue);
        isDark = rgbSum < threshold;
    }
    
    return isDark;
}

+ (BOOL)isLightColor:(UIColor *)color
{
    return ![MAColorUtil isDarkColor:color];
}

+ (BOOL)autoChangeTextColor:(UIColor *)backgroundColor forKey:(NSString *)key
{
    BOOL changedTextColor = NO;
    
    BOOL const isBackgroundDark = [MAColorUtil isDarkColor:backgroundColor];
    
    BOOL isTextDark = NO;
    NSDictionary *settings = [MAUserUtil loadSettings];
    NSString *textColorString = [settings objectForKey:key];
    if ([textColorString isEqualToString:BlackColorString])
    {
        isTextDark = YES;
    }
    else // ([textColorString isEqualToString:WhiteColorString])
    {
        isTextDark = NO;
    }
    
    // Flip the text color if it is hard to read with the current background (dark text on a dark background or light text on a light background).
    BOOL const isTextHardToRead = (isBackgroundDark && isTextDark)
        || (!isBackgroundDark && !isTextDark);
    if (isTextHardToRead)
    {
        NSString *newTextColor = @"";
        if (isTextDark)
        {
            newTextColor = WhiteColorString;
        }
        else
        {
            newTextColor = BlackColorString;
        }
        
        settings = [MAUserUtil saveSetting:newTextColor forKey:key];
        NSAssert(settings, @"Nil settings returned by saveSetting");
        
        // Must update the separator color since it depends on the text color setting.
        [MAAppearance setSeparatorColor];

        changedTextColor = YES;
        DLog(@"Auto-changed text color: %@ = %@", key, newTextColor);
    }
    
    return changedTextColor;
}

@end
