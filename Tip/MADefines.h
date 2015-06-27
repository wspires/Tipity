//
//  MADefines.h
//  Tip
//
//  Created by Wade Spires on 6/26/15.
//  Copyright © 2015 Minds Aspire LLC. All rights reserved.
//

#ifndef MADefines_h
#define MADefines_h

#define SFmt( s, ... ) [NSString stringWithFormat:(s), ##__VA_ARGS__]

//#define Localize( s ) NSLocalizedStringFromTable((s), @"InfoPlist", nil)
#define Localize( s ) NSLocalizedString((s), nil)

#define APP_NAME @"Tipity"
#define APP_ID @"919137272"

// Create "shortcut" for accessing the app delegate. Users must still include MAAppDelegate.h.
#define AppDelegate ((MAAppDelegate *)[UIApplication sharedApplication].delegate)

#define USE_IOS9

// Courtesy of https://github.com/facebook/three20
#ifndef MO_RGBCOLOR
#define MO_RGBCOLOR(r,g,b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]
#endif
#ifndef MO_RGBCOLOR1
#define MO_RGBCOLOR1(c) [UIColor colorWithRed:c/255.0 green:c/255.0 blue:c/255.0 alpha:1]
#endif
#ifndef MO_RGBACOLOR
#define MO_RGBACOLOR(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#endif


// Simplify declaring types used for tableview indices.
#define DECL_TABLE_IDX(name, value) static NSUInteger const (name) = (value)

// Macro for declaring table index paths. Must be non-const, so they can be re-assigned depending on the settings.
#define DECL_TABLE_IDX_VAR(name, value) static NSUInteger (name) = (value)

#endif /* MADefines_h */
