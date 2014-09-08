//
//  UIColor+ExtraColors.m
//  Gym Log
//
//  Created by Wade Spires on 10/5/13.
//
//

#import "UIColor+ExtraColors.h"

// UIColor expects values normalized in the range [0.0, 1.0], so divide input parameters by this factor to achieve such an affect, e.g., the max red value of 255 gets mapped to 1 for UIColor.
static CGFloat const colorNormalizationFactor = 255.;

@implementation UIColor (ExtraColors)

+ (UIColor *)colorWithHexString:(NSString *)hexString
{
    return [UIColor colorWithHexString:hexString withAlpha:1.0];
}

+ (UIColor *)colorWithHexString:(NSString *)hexString withAlpha:(CGFloat)alpha
{
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    unsigned int hex;
    BOOL success = [scanner scanHexInt:&hex];
    if (!success)
    {
        NSLog(@"Invalid hex string: %@", hexString);
    }
    return [UIColor colorWithHex:hex withAlpha:alpha];
}

+ (UIColor *)colorWithHex:(NSUInteger)hex
{
    return [UIColor colorWithHex:hex withAlpha:1.0];
}

+ (UIColor *)colorWithHex:(NSUInteger)hex withAlpha:(CGFloat)alpha
{
    return [UIColor
            colorWithRed:((float)((hex & 0xFF0000) >> 16)) / colorNormalizationFactor
            green:((float)((hex & 0xFF00) >> 8)) / colorNormalizationFactor
            blue:((float)(hex & 0xFF)) / colorNormalizationFactor
            alpha:alpha];
}

// Get lighter and darker versions of a given color.
// http://stackoverflow.com/questions/11598043/get-slightly-lighter-and-darker-color-from-uicolor
- (UIColor *)colorAdjustedWithBrightnessFactor:(CGFloat)brightnessFactor
{
    CGFloat h, s, b, a;
    if ([self getHue:&h saturation:&s brightness:&b alpha:&a])
        return [UIColor colorWithHue:h
                          saturation:s
                          brightness:b * brightnessFactor
                               alpha:a];
    return nil;
}

- (UIColor *)lighterColor
{
    CGFloat h, s, b, a;
    if ([self getHue:&h saturation:&s brightness:&b alpha:&a])
        return [UIColor colorWithHue:h
                          saturation:s
                          brightness:MIN(b * 1.3, 1.0)
                               alpha:a];
    return nil;
}

- (UIColor *)darkerColor
{
    CGFloat h, s, b, a;
    if ([self getHue:&h saturation:&s brightness:&b alpha:&a])
        return [UIColor colorWithHue:h
                          saturation:s
                          brightness:b * 0.75
                               alpha:a];
    return nil;
}

/*
+ (UIColor *)lighterColorForColor:(UIColor *)color
{
    CGFloat r, g, b, a;
    if ([color getRed:&r green:&g blue:&b alpha:&a])
        return [UIColor colorWithRed:MIN(r + 0.2, 1.0)
                               green:MIN(g + 0.2, 1.0)
                                blue:MIN(b + 0.2, 1.0)
                               alpha:a];
    return nil;
}

+ (UIColor *)darkerColorForColor:(UIColor *)color
{
    CGFloat r, g, b, a;
    if ([color getRed:&r green:&g blue:&b alpha:&a])
        return [UIColor colorWithRed:MAX(r - 0.2, 0.0)
                               green:MAX(g - 0.2, 0.0)
                                blue:MAX(b - 0.2, 0.0)
                               alpha:a];
    return nil;
}
*/

// Initialize and return a UIColor with the given hex color value. The color is static for efficiency if used multiple times and is initialized in a thread-safe way.
#define RETURN_STATIC_HEX_COLOR(hex) \
    static UIColor *color = nil; \
    static dispatch_once_t predicate = 0; \
    dispatch_once(&predicate, ^{ \
        color = [UIColor colorWithHex:hex]; \
    }); \
    return color;

// Whites and pastels.
+ (UIColor *)snowColor
{
    RETURN_STATIC_HEX_COLOR(0xfffafa);
}
+ (UIColor *)snow2Color
{
    RETURN_STATIC_HEX_COLOR(0xeee9e9);
}
+ (UIColor *)snow3Color
{
    RETURN_STATIC_HEX_COLOR(0xcdc9c9);
}
+ (UIColor *)snow4Color
{
    RETURN_STATIC_HEX_COLOR(0x8b8989);
}
+ (UIColor *)ghostWhiteColor
{
    RETURN_STATIC_HEX_COLOR(0xf8f8ff);
}
+ (UIColor *)whiteSmokeColor
{
    RETURN_STATIC_HEX_COLOR(0xf5f5f5);
}
+ (UIColor *)gainsboroColor
{
    RETURN_STATIC_HEX_COLOR(0xdcdcdc);
}
+ (UIColor *)floralWhiteColor
{
    RETURN_STATIC_HEX_COLOR(0xfffaf0);
}
+ (UIColor *)oldLaceColor
{
    RETURN_STATIC_HEX_COLOR(0xfdf5e6);
}
+ (UIColor *)linenColor
{
    RETURN_STATIC_HEX_COLOR(0xfaf0e6);
}
+ (UIColor *)antiqueWhiteColor
{
    RETURN_STATIC_HEX_COLOR(0xfaebd7);
}
+ (UIColor *)antiqueWhite2Color
{
    RETURN_STATIC_HEX_COLOR(0xeedfcc);
}
+ (UIColor *)antiqueWhite3Color
{
    RETURN_STATIC_HEX_COLOR(0xcdc0b0);
}
+ (UIColor *)antiqueWhite4Color
{
    RETURN_STATIC_HEX_COLOR(0x8b8378);
}
+ (UIColor *)papayaWhipColor
{
    RETURN_STATIC_HEX_COLOR(0xffefd5);
}
+ (UIColor *)blanchedAlmondColor
{
    RETURN_STATIC_HEX_COLOR(0xffebcd);
}
+ (UIColor *)bisqueColor
{
    RETURN_STATIC_HEX_COLOR(0xffe4c4);
}
+ (UIColor *)bisque2Color
{
    RETURN_STATIC_HEX_COLOR(0xeed5b7);
}
+ (UIColor *)bisque3Color
{
    RETURN_STATIC_HEX_COLOR(0xcdb79e);
}
+ (UIColor *)bisque4Color
{
    RETURN_STATIC_HEX_COLOR(0x8b7d6b);
}
+ (UIColor *)peachPuffColor
{
    RETURN_STATIC_HEX_COLOR(0xffdab9);
}
+ (UIColor *)peachPuff2Color
{
    RETURN_STATIC_HEX_COLOR(0xeecbad);
}
+ (UIColor *)peachPuff3Color
{
    RETURN_STATIC_HEX_COLOR(0xcdaf95);
}
+ (UIColor *)peachPuff4Color
{
    RETURN_STATIC_HEX_COLOR(0x8b7765);
}
+ (UIColor *)navajoWhiteColor
{
    RETURN_STATIC_HEX_COLOR(0xffdead);
}
+ (UIColor *)moccasinColor
{
    RETURN_STATIC_HEX_COLOR(0xffe4b5);
}
+ (UIColor *)cornsilkColor
{
    RETURN_STATIC_HEX_COLOR(0xfff8dc);
}
+ (UIColor *)cornsilk2Color
{
    RETURN_STATIC_HEX_COLOR(0xeee8dc);
}
+ (UIColor *)cornsilk3Color
{
    RETURN_STATIC_HEX_COLOR(0xcdc8b1);
}
+ (UIColor *)cornsilk4Color
{
    RETURN_STATIC_HEX_COLOR(0x8b8878);
}
+ (UIColor *)ivoryColor
{
    RETURN_STATIC_HEX_COLOR(0xfffff0);
}
+ (UIColor *)ivory2Color
{
    RETURN_STATIC_HEX_COLOR(0xeeeee0);
}
+ (UIColor *)ivory3Color
{
    RETURN_STATIC_HEX_COLOR(0xcdcdc1);
}
+ (UIColor *)ivory4Color
{
    RETURN_STATIC_HEX_COLOR(0x8b8b83);
}
+ (UIColor *)lemonChiffonColor
{
    RETURN_STATIC_HEX_COLOR(0xfffacd);
}
+ (UIColor *)seashellColor
{
    RETURN_STATIC_HEX_COLOR(0xfff5ee);
}
+ (UIColor *)seashell2Color
{
    RETURN_STATIC_HEX_COLOR(0xeee5de);
}
+ (UIColor *)seashell3Color
{
    RETURN_STATIC_HEX_COLOR(0xcdc5bf);
}
+ (UIColor *)seashell4Color
{
    RETURN_STATIC_HEX_COLOR(0x8b8682);
}
+ (UIColor *)honeydewColor
{
    RETURN_STATIC_HEX_COLOR(0xf0fff0);
}
+ (UIColor *)honeydew2Color
{
    RETURN_STATIC_HEX_COLOR(0xe0eee0);
}
+ (UIColor *)honeydew3Color
{
    RETURN_STATIC_HEX_COLOR(0xc1cdc1);
}
+ (UIColor *)honeydew4Color
{
    RETURN_STATIC_HEX_COLOR(0x838b83);
}
+ (UIColor *)mintCreamColor
{
    RETURN_STATIC_HEX_COLOR(0xf5fffa);
}
+ (UIColor *)azureColor
{
    RETURN_STATIC_HEX_COLOR(0xf0ffff);
}
+ (UIColor *)aliceBlueColor
{
    RETURN_STATIC_HEX_COLOR(0xf0f8ff);
}
+ (UIColor *)lavenderColor
{
    RETURN_STATIC_HEX_COLOR(0xe6e6fa);
}
+ (UIColor *)lavenderBlushColor
{
    RETURN_STATIC_HEX_COLOR(0xfff0f5);
}
+ (UIColor *)mistyRoseColor
{
    RETURN_STATIC_HEX_COLOR(0xffe4e1);
}
/*
+ (UIColor *)whiteColor
{
    RETURN_STATIC_HEX_COLOR(0xffffff);
}
*/

// Grays.
/*
+ (UIColor *)blackColor
{
    RETURN_STATIC_HEX_COLOR(0x000000);
}
*/
+ (UIColor *)darkSlateGrayColor
{
    RETURN_STATIC_HEX_COLOR(0x2f4f4f);
}
+ (UIColor *)dimGrayColor
{
    RETURN_STATIC_HEX_COLOR(0x696969);
}
+ (UIColor *)slateGrayColor
{
    RETURN_STATIC_HEX_COLOR(0x708090);
}
+ (UIColor *)lightSlateGrayColor
{
    RETURN_STATIC_HEX_COLOR(0x778899);
}
/*
+ (UIColor *)grayColor
{
    RETURN_STATIC_HEX_COLOR(0xbebebe);
}
*/
/*
+ (UIColor *)lightGrayColor
{
    RETURN_STATIC_HEX_COLOR(0xd3d3d3);
}
*/

// Blues.
+ (UIColor *)midnightBlueColor
{
    RETURN_STATIC_HEX_COLOR(0x191970);
}
+ (UIColor *)navyColor
{
    RETURN_STATIC_HEX_COLOR(0x000080);
}
+ (UIColor *)cornflowerBlueColor
{
    RETURN_STATIC_HEX_COLOR(0x6495ed);
}
+ (UIColor *)darkSlateBlueColor
{
    RETURN_STATIC_HEX_COLOR(0x483d8b);
}
+ (UIColor *)slateBlueColor
{
    RETURN_STATIC_HEX_COLOR(0x6a5acd);
}
+ (UIColor *)mediumSlateBlueColor
{
    RETURN_STATIC_HEX_COLOR(0x7b68ee);
}
+ (UIColor *)lightSlateBlueColor
{
    RETURN_STATIC_HEX_COLOR(0x8470ff);
}
+ (UIColor *)mediumBlueColor
{
    RETURN_STATIC_HEX_COLOR(0x0000cd);
}
+ (UIColor *)royalBlueColor
{
    RETURN_STATIC_HEX_COLOR(0x4169e1);
}
/*
+ (UIColor *)blueColor
{
    RETURN_STATIC_HEX_COLOR(0x0000ff);
}
*/
+ (UIColor *)dodgerBlueColor
{
    RETURN_STATIC_HEX_COLOR(0x1e90ff);
}
+ (UIColor *)deepSkyBlueColor
{
    RETURN_STATIC_HEX_COLOR(0x00bfff);
}
+ (UIColor *)skyBlueColor
{
    RETURN_STATIC_HEX_COLOR(0x87ceeb);
}
+ (UIColor *)lightSkyBlueColor
{
    RETURN_STATIC_HEX_COLOR(0x87cefa);
}
+ (UIColor *)steelBlueColor
{
    RETURN_STATIC_HEX_COLOR(0x4682b4);
}
+ (UIColor *)lightSteelBlueColor
{
    RETURN_STATIC_HEX_COLOR(0xb0c4de);
}
+ (UIColor *)lightBlueColor
{
    RETURN_STATIC_HEX_COLOR(0xadd8e6);
}
+ (UIColor *)powderBlueColor
{
    RETURN_STATIC_HEX_COLOR(0xb0e0e6);
}
+ (UIColor *)paleTurquoiseColor
{
    RETURN_STATIC_HEX_COLOR(0xafeeee);
}
+ (UIColor *)darkTurquoiseColor
{
    RETURN_STATIC_HEX_COLOR(0x00ced1);
}
+ (UIColor *)mediumTurquoiseColor
{
    RETURN_STATIC_HEX_COLOR(0x48d1cc);
}
+ (UIColor *)turquoiseColor
{
    RETURN_STATIC_HEX_COLOR(0x40e0d0);
}
/*
+ (UIColor *)cyanColor
{
    RETURN_STATIC_HEX_COLOR(0x00ffff);
}
*/
+ (UIColor *)lightCyanColor
{
    RETURN_STATIC_HEX_COLOR(0xe0ffff);
}
+ (UIColor *)cadetBlueColor
{
    RETURN_STATIC_HEX_COLOR(0x5f9ea0);
}

// Greens.
+ (UIColor *)mediumAquamarineColor
{
    RETURN_STATIC_HEX_COLOR(0x66cdaa);
}
+ (UIColor *)aquamarineColor
{
    RETURN_STATIC_HEX_COLOR(0x7fffd4);
}
+ (UIColor *)darkGreenColor
{
    RETURN_STATIC_HEX_COLOR(0x006400);
}
+ (UIColor *)darkOliveGreenColor
{
    RETURN_STATIC_HEX_COLOR(0x556b2f);
}
+ (UIColor *)darkSeaGreenColor
{
    RETURN_STATIC_HEX_COLOR(0x8fbc8f);
}
+ (UIColor *)seaGreenColor
{
    RETURN_STATIC_HEX_COLOR(0x2e8b57);
}
+ (UIColor *)mediumSeaGreenColor
{
    RETURN_STATIC_HEX_COLOR(0x3cb371);
}
+ (UIColor *)lightSeaGreenColor
{
    RETURN_STATIC_HEX_COLOR(0x20b2aa);
}
+ (UIColor *)paleGreenColor
{
    RETURN_STATIC_HEX_COLOR(0x98fb98);
}
+ (UIColor *)springGreenColor
{
    RETURN_STATIC_HEX_COLOR(0x00ff7f);
}
+ (UIColor *)lawnGreenColor
{
    RETURN_STATIC_HEX_COLOR(0x7cfc00);
}
+ (UIColor *)chartreuseColor
{
    RETURN_STATIC_HEX_COLOR(0x7fff00);
}
+ (UIColor *)mediumSpringGreenColor
{
    RETURN_STATIC_HEX_COLOR(0x00fa9a);
}
+ (UIColor *)greenYellowColor
{
    RETURN_STATIC_HEX_COLOR(0xadff2f);
}
+ (UIColor *)limeGreenColor
{
    RETURN_STATIC_HEX_COLOR(0x32cd32);
}
+ (UIColor *)yellowGreenColor
{
    RETURN_STATIC_HEX_COLOR(0x9acd32);
}
+ (UIColor *)forestGreenColor
{
    RETURN_STATIC_HEX_COLOR(0x228b22);
}
+ (UIColor *)oliveDrabColor
{
    RETURN_STATIC_HEX_COLOR(0x6b8e23);
}
+ (UIColor *)darkKhakiColor
{
    RETURN_STATIC_HEX_COLOR(0xbdb76b);
}
+ (UIColor *)khakiColor
{
    RETURN_STATIC_HEX_COLOR(0xf0e68c);
}

// Yellows.
+ (UIColor *)paleGoldenrodColor
{
    RETURN_STATIC_HEX_COLOR(0xeee8aa);
}
+ (UIColor *)lightGoldenrodYellowColor
{
    RETURN_STATIC_HEX_COLOR(0xfafad2);
}
+ (UIColor *)lightYellowColor
{
    RETURN_STATIC_HEX_COLOR(0xffffe0);
}
/*
+ (UIColor *)yellowColor
{
    RETURN_STATIC_HEX_COLOR(0xffff00);
}
*/
+ (UIColor *)goldColor
{
    RETURN_STATIC_HEX_COLOR(0xffd700);
}
+ (UIColor *)lightGoldenrodColor
{
    RETURN_STATIC_HEX_COLOR(0xeedd82);
}
+ (UIColor *)goldenrodColor
{
    RETURN_STATIC_HEX_COLOR(0xdaa520);
}
+ (UIColor *)darkGoldenrodColor
{
    RETURN_STATIC_HEX_COLOR(0xb8860b);
}

// Browns.
+ (UIColor *)rosyBrownColor
{
    RETURN_STATIC_HEX_COLOR(0xbc8f8f);
}
+ (UIColor *)indianRedColor
{
    RETURN_STATIC_HEX_COLOR(0xcd5c5c);
}
+ (UIColor *)saddleBrownColor
{
    RETURN_STATIC_HEX_COLOR(0x8b4513);
}
+ (UIColor *)siennaColor
{
    RETURN_STATIC_HEX_COLOR(0xa0522d);
}
+ (UIColor *)peruColor
{
    RETURN_STATIC_HEX_COLOR(0xcd853f);
}
+ (UIColor *)burlywoodColor
{
    RETURN_STATIC_HEX_COLOR(0xdeb887);
}
+ (UIColor *)beigeColor
{
    RETURN_STATIC_HEX_COLOR(0xf5f5dc);
}
+ (UIColor *)wheatColor
{
    RETURN_STATIC_HEX_COLOR(0xf5deb3);
}
+ (UIColor *)sandyBrownColor
{
    RETURN_STATIC_HEX_COLOR(0xf4a460);
}
+ (UIColor *)tanColor
{
    RETURN_STATIC_HEX_COLOR(0xd2b48c);
}
+ (UIColor *)chocolateColor
{
    RETURN_STATIC_HEX_COLOR(0xd2691e);
}
+ (UIColor *)firebrickColor
{
    RETURN_STATIC_HEX_COLOR(0xb22222);
}
/*
+ (UIColor *)brownColor
{
    RETURN_STATIC_HEX_COLOR(0xa52a2a);
}
*/

// Oranges.
+ (UIColor *)darkSalmonColor
{
    RETURN_STATIC_HEX_COLOR(0xe9967a);
}
+ (UIColor *)salmonColor
{
    RETURN_STATIC_HEX_COLOR(0xfa8072);
}
+ (UIColor *)lightSalmonColor
{
    RETURN_STATIC_HEX_COLOR(0xffa07a);
}
/*
+ (UIColor *)orangeColor
{
    RETURN_STATIC_HEX_COLOR(0xffa500);
}
*/
+ (UIColor *)darkOrangeColor
{
    RETURN_STATIC_HEX_COLOR(0xff8c00);
}
+ (UIColor *)coralColor
{
    RETURN_STATIC_HEX_COLOR(0xff7f50);
}
+ (UIColor *)lightCoralColor
{
    RETURN_STATIC_HEX_COLOR(0xf08080);
}
+ (UIColor *)tomatoColor
{
    RETURN_STATIC_HEX_COLOR(0xff6347);
}
+ (UIColor *)orangeRedColor
{
    RETURN_STATIC_HEX_COLOR(0xff4500);
}
/*
+ (UIColor *)redColor
{
    RETURN_STATIC_HEX_COLOR(0xff0000);
}
*/

// Pinks and violets.
+ (UIColor *)hotPinkColor
{
    RETURN_STATIC_HEX_COLOR(0xff69b4);
}
+ (UIColor *)deepPinkColor
{
    RETURN_STATIC_HEX_COLOR(0xff1493);
}
+ (UIColor *)pinkColor
{
    RETURN_STATIC_HEX_COLOR(0xffc0cb);
}
+ (UIColor *)lightPinkColor
{
    RETURN_STATIC_HEX_COLOR(0xffb6c1);
}
+ (UIColor *)paleVioletRedColor
{
    RETURN_STATIC_HEX_COLOR(0xdb7093);
}
+ (UIColor *)maroonColor
{
    RETURN_STATIC_HEX_COLOR(0xb03060);
}
+ (UIColor *)mediumVioletRedColor
{
    RETURN_STATIC_HEX_COLOR(0xc71585);
}
+ (UIColor *)violetRedColor
{
    RETURN_STATIC_HEX_COLOR(0xd02090);
}
+ (UIColor *)violetColor
{
    RETURN_STATIC_HEX_COLOR(0xee82ee);
}
+ (UIColor *)plumColor
{
    RETURN_STATIC_HEX_COLOR(0xdda0dd);
}
+ (UIColor *)orchidColor
{
    RETURN_STATIC_HEX_COLOR(0xda70d6);
}
+ (UIColor *)mediumOrchidColor
{
    RETURN_STATIC_HEX_COLOR(0xba55d3);
}
+ (UIColor *)darkOrchidColor
{
    RETURN_STATIC_HEX_COLOR(0x9932cc);
}
+ (UIColor *)darkVioletColor
{
    RETURN_STATIC_HEX_COLOR(0x9400d3);
}
+ (UIColor *)blueVioletColor
{
    RETURN_STATIC_HEX_COLOR(0x8a2be2);
}
/*
+ (UIColor *)purpleColor
{
    RETURN_STATIC_HEX_COLOR(0xa020f0);
}
*/
+ (UIColor *)mediumPurpleColor
{
    RETURN_STATIC_HEX_COLOR(0x9370db);
}
+ (UIColor *)thistleColor
{
    RETURN_STATIC_HEX_COLOR(0xd8bfd8);
}

@end
