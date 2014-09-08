//
//  UIColor+ExtraColors.h
//  Gym Log
//
//  Created by Wade Spires on 10/5/13.
//
//

#import <UIKit/UIKit.h>

@interface UIColor (ExtraColors)

+ (UIColor *)colorWithHexString:(NSString *)hexString;
+ (UIColor *)colorWithHexString:(NSString *)hexString withAlpha:(CGFloat)alpha;
+ (UIColor *)colorWithHex:(NSUInteger)hex;
+ (UIColor *)colorWithHex:(NSUInteger)hex withAlpha:(CGFloat)alpha;

- (UIColor *)colorAdjustedWithBrightnessFactor:(CGFloat)brightnessFactor;
- (UIColor *)lighterColor;
- (UIColor *)darkerColor;
//+ (UIColor *)lighterColorForColor:(UIColor *)color;
//+ (UIColor *)darkerColorForColor:(UIColor *)color;

// Whites and pastels.
+ (UIColor *)snowColor;
+ (UIColor *)snow2Color;
+ (UIColor *)snow3Color;
+ (UIColor *)snow4Color;
+ (UIColor *)ghostWhiteColor;
+ (UIColor *)whiteSmokeColor;
+ (UIColor *)gainsboroColor;
+ (UIColor *)floralWhiteColor;
+ (UIColor *)oldLaceColor;
+ (UIColor *)linenColor;
+ (UIColor *)antiqueWhiteColor;
+ (UIColor *)antiqueWhite2Color;
+ (UIColor *)antiqueWhite3Color;
+ (UIColor *)antiqueWhite4Color;
+ (UIColor *)papayaWhipColor;
+ (UIColor *)blanchedAlmondColor;
+ (UIColor *)bisqueColor;
+ (UIColor *)bisque2Color;
+ (UIColor *)bisque3Color;
+ (UIColor *)bisque4Color;
+ (UIColor *)peachPuffColor;
+ (UIColor *)peachPuff2Color;
+ (UIColor *)peachPuff3Color;
+ (UIColor *)peachPuff4Color;
+ (UIColor *)navajoWhiteColor;
+ (UIColor *)moccasinColor;
+ (UIColor *)cornsilkColor;
+ (UIColor *)cornsilk2Color;
+ (UIColor *)cornsilk3Color;
+ (UIColor *)cornsilk4Color;
+ (UIColor *)ivoryColor;
+ (UIColor *)ivory2Color;
+ (UIColor *)ivory3Color;
+ (UIColor *)ivory4Color;
+ (UIColor *)lemonChiffonColor;
+ (UIColor *)seashellColor;
+ (UIColor *)seashell2Color;
+ (UIColor *)seashell3Color;
+ (UIColor *)seashell4Color;
+ (UIColor *)honeydewColor;
+ (UIColor *)honeydew2Color;
+ (UIColor *)honeydew3Color;
+ (UIColor *)honeydew4Color;
+ (UIColor *)mintCreamColor;
+ (UIColor *)azureColor;
+ (UIColor *)aliceBlueColor;
+ (UIColor *)lavenderColor;
+ (UIColor *)lavenderBlushColor;
+ (UIColor *)mistyRoseColor;
//+ (UIColor *)whiteColor;

// Grays.
//+ (UIColor *)blackColor;
+ (UIColor *)darkSlateGrayColor;
+ (UIColor *)dimGrayColor;
+ (UIColor *)slateGrayColor;
+ (UIColor *)lightSlateGrayColor;
//+ (UIColor *)grayColor;
//+ (UIColor *)lightGrayColor;

// Blues.
+ (UIColor *)midnightBlueColor;
+ (UIColor *)navyColor;
+ (UIColor *)cornflowerBlueColor;
+ (UIColor *)darkSlateBlueColor;
+ (UIColor *)slateBlueColor;
+ (UIColor *)mediumSlateBlueColor;
+ (UIColor *)lightSlateBlueColor;
+ (UIColor *)mediumBlueColor;
+ (UIColor *)royalBlueColor;
//+ (UIColor *)blueColor;
+ (UIColor *)dodgerBlueColor;
+ (UIColor *)deepSkyBlueColor;
+ (UIColor *)skyBlueColor;
+ (UIColor *)lightSkyBlueColor;
+ (UIColor *)steelBlueColor;
+ (UIColor *)lightSteelBlueColor;
+ (UIColor *)lightBlueColor;
+ (UIColor *)powderBlueColor;
+ (UIColor *)paleTurquoiseColor;
+ (UIColor *)darkTurquoiseColor;
+ (UIColor *)mediumTurquoiseColor;
+ (UIColor *)turquoiseColor;
//+ (UIColor *)cyanColor;
+ (UIColor *)lightCyanColor;
+ (UIColor *)cadetBlueColor;

// Greens.
+ (UIColor *)mediumAquamarineColor;
+ (UIColor *)aquamarineColor;
+ (UIColor *)darkGreenColor;
+ (UIColor *)darkOliveGreenColor;
+ (UIColor *)darkSeaGreenColor;
+ (UIColor *)seaGreenColor;
+ (UIColor *)mediumSeaGreenColor;
+ (UIColor *)lightSeaGreenColor;
+ (UIColor *)paleGreenColor;
+ (UIColor *)springGreenColor;
+ (UIColor *)lawnGreenColor;
+ (UIColor *)chartreuseColor;
+ (UIColor *)mediumSpringGreenColor;
+ (UIColor *)greenYellowColor;
+ (UIColor *)limeGreenColor;
+ (UIColor *)yellowGreenColor;
+ (UIColor *)forestGreenColor;
+ (UIColor *)oliveDrabColor;
+ (UIColor *)darkKhakiColor;
+ (UIColor *)khakiColor;

// Yellows.
+ (UIColor *)paleGoldenrodColor;
+ (UIColor *)lightGoldenrodYellowColor;
+ (UIColor *)lightYellowColor;
//+ (UIColor *)yellowColor;
+ (UIColor *)goldColor;
+ (UIColor *)lightGoldenrodColor;
+ (UIColor *)goldenrodColor;
+ (UIColor *)darkGoldenrodColor;

// Browns.
+ (UIColor *)rosyBrownColor;
+ (UIColor *)indianRedColor;
+ (UIColor *)saddleBrownColor;
+ (UIColor *)siennaColor;
+ (UIColor *)peruColor;
+ (UIColor *)burlywoodColor;
+ (UIColor *)beigeColor;
+ (UIColor *)wheatColor;
+ (UIColor *)sandyBrownColor;
+ (UIColor *)tanColor;
+ (UIColor *)chocolateColor;
+ (UIColor *)firebrickColor;
//+ (UIColor *)brownColor;

// Oranges.
+ (UIColor *)darkSalmonColor;
+ (UIColor *)salmonColor;
+ (UIColor *)lightSalmonColor;
//+ (UIColor *)orangeColor;
+ (UIColor *)darkOrangeColor;
+ (UIColor *)coralColor;
+ (UIColor *)lightCoralColor;
+ (UIColor *)tomatoColor;
+ (UIColor *)orangeRedColor;
//+ (UIColor *)redColor;

// Pinks and violets.
+ (UIColor *)hotPinkColor;
+ (UIColor *)deepPinkColor;
+ (UIColor *)pinkColor;
+ (UIColor *)lightPinkColor;
+ (UIColor *)paleVioletRedColor;
+ (UIColor *)maroonColor;
+ (UIColor *)mediumVioletRedColor;
+ (UIColor *)violetRedColor;
+ (UIColor *)violetColor;
+ (UIColor *)plumColor;
+ (UIColor *)orchidColor;
+ (UIColor *)mediumOrchidColor;
+ (UIColor *)darkOrchidColor;
+ (UIColor *)darkVioletColor;
+ (UIColor *)blueVioletColor;
//+ (UIColor *)purpleColor;
+ (UIColor *)mediumPurpleColor;
+ (UIColor *)thistleColor;

@end
