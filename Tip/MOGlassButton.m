//
//  MOGlassButton.m
//  Licensed under the terms of the BSD License, as specified below.
//
//  Created by Hwee-Boon Yar on Jan/31/2010.
//
/*
 Copyright 2010 Yar Hwee Boon. All rights reserved.
 
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 
 * Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 
 * Neither the name of MotionObj nor the names of its
 contributors may be used to endorse or promote products derived from
 this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
 TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "MOGlassButton.h"
#import "UIColor+ExtraColors.h"
#import "MAUtil.h"
#import "MAAppearance.h"
#import "MAUserUtil.h"

@implementation MOGlassButton

@synthesize gradientLayer1;
@synthesize gradientLayer2;
@synthesize outlineLayer;

- (void)setupLayers
{
    //CGFloat cornerRadius = 6.0f;
    CGFloat cornerRadius = 4.0f;
    if (ABOVE_IOS7)
    {
        cornerRadius = 4.0f;
    }
	self.layer.cornerRadius = cornerRadius;
	self.layer.masksToBounds = YES;
    
    // Border is just darker version of the foreground color.
    //self.layer.borderColor = [[[MAAppearance foregroundColor] darkerColor] CGColor];
	//self.layer.borderWidth = 1.0f;

    if (ABOVE_IOS7)
    {
        // iOS7 has no glossy buttons with borders.
        return;
    }

    //return; // No gloss on iOS 6.

    
    // Make gloss layer.
	self.gradientLayer1 = [[CAGradientLayer alloc] init];
	gradientLayer1.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height/2);
	gradientLayer1.colors = [NSArray arrayWithObjects:(id)[MO_RGBACOLOR(255, 255, 255, 0.45) CGColor], (id)[MO_RGBACOLOR(255, 235, 255, 0.1) CGColor], nil];
	[self.layer insertSublayer:gradientLayer1 atIndex:0];

	self.gradientLayer2 = [[CAGradientLayer alloc] init];
	gradientLayer2.frame = CGRectMake(0, self.frame.size.height/2, self.frame.size.width, self.frame.size.height/2);
	gradientLayer2.colors = [NSArray arrayWithObjects:(id)[MO_RGBACOLOR(205, 205, 205, 0) CGColor], (id)[MO_RGBACOLOR(235, 215, 215, 0.2) CGColor], nil];

    
    return; // No border on iOS 6.
    
    
    /*
    // Add border.
    //self.layer.borderColor = [MO_RGBCOLOR(100, 103, 107) CGColor];
    self.layer.borderColor = [[[MAAppearance foregroundColor] darkerColor] CGColor];
	self.layer.borderWidth = 1.0f;

	self.outlineLayer = [[CALayer alloc] init];
	outlineLayer.frame = CGRectMake(0, 1, self.frame.size.width, self.frame.size.height);
	outlineLayer.borderColor = [MO_RGBCOLOR(255, 255, 255) CGColor];
	outlineLayer.borderWidth = 1.0f;
	outlineLayer.opacity = 0.2;
     */
}


- (id)initWithFrame:(CGRect)aRect {
	if (self = [super initWithFrame:aRect]) {
		[self setupLayers];
	}

	return self;
}


- (void)awakeFromNib {
	[super awakeFromNib];
	[self setupLayers];
}


- (void)dealloc {
	self.gradientLayer1 = nil;
	self.gradientLayer2 = nil;
	self.outlineLayer = nil;

    //[super dealloc]; // ARC forbids explicit message send of 'dealloc'.
}


- (void)layoutSubviews {
	[super layoutSubviews];

	gradientLayer1.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height/2);
	gradientLayer2.frame = CGRectMake(0, self.frame.size.height/2, self.frame.size.width, self.frame.size.height/2);
	outlineLayer.frame = CGRectMake(0, 1, self.frame.size.width, self.frame.size.height);
}

#pragma mark Default Button Background Colors

- (void)setTextColor
{
    UIColor *color = [MAAppearance buttonTextColor];
	[self setTitleColor:color forState:UIControlStateNormal];
    
    // TODO: Set different text color for disabled state depending on the button text color setting.
    [self setTitleColor:MO_RGBCOLOR(205, 212, 220) forState:UIControlStateDisabled];
}

- (void)setupForStandardButtons
{
    [self setTextColor];
    
	//self.titleLabel.shadowOffset = CGSizeMake(0, -1);
	//self.titleLabel.shadowColor = MO_RGBCOLOR(192, 73, 84);
    
    //self.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    //self.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
    
    //self.titleLabel.textColor = [UIColor lightTextColor];
    //self.titleLabel.textColor = [UIColor darkTextColor];    
}

- (void)reloadColors
{
    [self setBackgroundColor:[MAAppearance foregroundColor] forState:UIControlStateNormal];
    [self setBackgroundColor:[MAAppearance selectedColor] forState:UIControlStateSelected];
	[self setBackgroundColor:[MAAppearance highlightedColor] forState:UIControlStateHighlighted];
    [self setBackgroundColor:[MAAppearance disabledColor] forState:UIControlStateDisabled];

    // Border is just darker version of the foreground color.
    CGFloat brightnessFactor = .9;
    if (ABOVE_IOS7)
    {
        // Consider using slightly different shade for iOS 7.
        brightnessFactor = .9;
    }
    self.layer.borderColor = [[[MAAppearance foregroundColor] colorAdjustedWithBrightnessFactor:brightnessFactor] CGColor];
	self.layer.borderWidth = 1.0f;
}

- (void)setupAsLogButton
{
    [self reloadColors];
	[self setupForStandardButtons];
}

- (void)setupAsBlueButton {
    [self setBackgroundColor:MO_RGBCOLOR(0, 40, 255) forState:UIControlStateNormal];
	[self setBackgroundColor:MO_RGBCOLOR(0, 100, 255) forState:UIControlStateHighlighted];
	[self setBackgroundColor:MO_RGBCOLOR(110, 123, 139) forState:UIControlStateDisabled];
	[self setupForStandardButtons];
}

+ (UIColor *)grayButtonColor {
    return MO_RGBCOLOR(112, 128, 144);
}

- (void)setupAsBlueLogButton
{
    //[self setBackgroundColor:[UIColor cornflowerBlueColor] forState:UIControlStateNormal];
    //[self setBackgroundColor:[UIColor royalBlueColor] forState:UIControlStateSelected];
	//[self setBackgroundColor:[UIColor royalBlueColor] forState:UIControlStateHighlighted];
    
    [self setBackgroundColor:[UIColor royalBlueColor] forState:UIControlStateNormal];
    [self setBackgroundColor:[UIColor cornflowerBlueColor] forState:UIControlStateSelected];
	[self setBackgroundColor:[UIColor cornflowerBlueColor] forState:UIControlStateHighlighted];
    
	//[self setBackgroundColor:[UIColor midnightBlueColor] forState:UIControlStateDisabled];
    [self setBackgroundColor:MO_RGBCOLOR(105, 105, 105) forState:UIControlStateDisabled];

	[self setupForStandardButtons];
}

- (void)setupAsGrayButton {
    [self setBackgroundColor:MO_RGBCOLOR(112, 128, 144) forState:UIControlStateNormal];
    [self setBackgroundColor:MO_RGBCOLOR(190, 190, 190) forState:UIControlStateSelected];
	[self setBackgroundColor:MO_RGBCOLOR(190, 190, 190) forState:UIControlStateHighlighted];
	[self setBackgroundColor:MO_RGBCOLOR(105, 105, 105) forState:UIControlStateDisabled];
	[self setupForStandardButtons];
}


- (void)setupAsGreenButton {
	[self setBackgroundColor:MO_RGBCOLOR(24, 157, 22) forState:UIControlStateNormal];
	[self setBackgroundColor:MO_RGBCOLOR(9, 54, 14) forState:UIControlStateHighlighted];
	[self setBackgroundColor:MO_RGBCOLOR(24, 157, 22) forState:UIControlStateDisabled];
	[self setupForStandardButtons];
}


- (void)setupAsRedButton {
	[self setBackgroundColor:MO_RGBCOLOR(160, 1, 20) forState:UIControlStateNormal];
	[self setBackgroundColor:MO_RGBCOLOR(120, 0, 0) forState:UIControlStateHighlighted];
	[self setBackgroundColor:MO_RGBCOLOR(160, 1, 20) forState:UIControlStateDisabled];
	[self setupForStandardButtons];
}


- (void)setupAsSmallGreenButton {
	[self setupAsGreenButton];
	self.titleLabel.font = [UIFont boldSystemFontOfSize:15];
	self.layer.cornerRadius = 4.0f;
}


- (void)setupAsSmallRedButton {
	[self setupAsRedButton];
	self.titleLabel.font = [UIFont boldSystemFontOfSize:15];
	self.layer.cornerRadius = 4.0f;
}

- (void)setTitle:(NSString *)title
{
    [self setTitle:title forState:UIControlStateNormal];
    [self setTitle:title forState:UIControlStateSelected];
    [self setTitle:title forState:UIControlStateHighlighted];
}

@end
