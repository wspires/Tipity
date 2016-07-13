//
//  MOButton.m
//  Licensed under the terms of the BSD License, as specified below.
//
//  Created by Hwee-Boon Yar on Feb/13/2010.
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

#import "MOButton.h"

#import <QuartzCore/QuartzCore.h>

@implementation MOButton

@synthesize normalBackgroundColor;
@synthesize highlightedBackgroundColor;
@synthesize disabledBackgroundColor;
@synthesize selectedBackgroundColor;
@synthesize highlightEnabled;
@synthesize turnedOn = _turnedOn;

// Have to set up handlers for various touch events. Can't rely on UIButton.highlighted and enabled property because highlighted is still YES when touch up.
- (void)setupStateChangeHandlers
{
    /*
     TODO: Not handling these events because buttonUp seems to get called too frequently so the color gets immediately set back to the normal, non-highlighed color on a touch.
	[self addTarget:self action:@selector(buttonUp:event:) forControlEvents:(UIControlEventTouchUpOutside|UIControlEventTouchUpInside|UIControlEventTouchCancel|UIControlEventTouchDragExit)];
	[self addTarget:self action:@selector(buttonDown:event:) forControlEvents:UIControlEventTouchDown|UIControlEventTouchDragEnter];
     */
}

- (id)init
{
    if (self = [super init])
    {
		[self setupStateChangeHandlers];
        self.highlightEnabled = YES;
        _turnedOn = NO;
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self setupStateChangeHandlers];
        self.highlightEnabled = YES; 
    }
    return self;
}

- (id)initWithFrame:(CGRect)aRect
{
	if (self = [super initWithFrame:aRect])
    {
		[self setupStateChangeHandlers];
        self.highlightEnabled = YES;
	}
	return self;
}


- (void)awakeFromNib
{
    [super awakeFromNib];
	[self setupStateChangeHandlers];
}


- (void)dealloc
{
	self.normalBackgroundColor = nil;
	self.highlightedBackgroundColor = nil;
	self.disabledBackgroundColor = nil;
    self.selectedBackgroundColor = nil;

    //[super dealloc]; // ARC forbids explicit message send of 'dealloc'.
}


- (void)setBackgroundColor:(UIColor*)aColor forState:(UIControlState)aState
{
	switch (aState)
    {
		case UIControlStateNormal:
			self.normalBackgroundColor = aColor;
			if (self.enabled) self.layer.backgroundColor = self.normalBackgroundColor.CGColor;
			break;
		case UIControlStateHighlighted:
			self.highlightedBackgroundColor = aColor;
			break;
		case UIControlStateDisabled:
			self.disabledBackgroundColor = aColor;
			if (!self.enabled) self.layer.backgroundColor = self.disabledBackgroundColor.CGColor;
			break;
        case UIControlStateSelected:
            self.selectedBackgroundColor = aColor;
            break;
		default:
			break;
	}
}

// Manually call this to make the button stay the selected color even after the touch ends. 
- (void)setEnabled:(BOOL)isEnabled
{
	[super setEnabled:isEnabled];
    if (isEnabled)
    {
        if (self.isSelected)
        {
            self.layer.backgroundColor = self.selectedBackgroundColor.CGColor;
        }
        else
        {
            self.layer.backgroundColor = self.normalBackgroundColor.CGColor;        
        }
    }
    else
    {
        self.layer.backgroundColor = self.disabledBackgroundColor.CGColor;
    }
}
- (void)setSelected:(BOOL)isSelected
{
    // Commented out so that image does not get grayed out when manually tapped. This was the only I could figure out how to accomplish this since setting the various built-in color states, etc. did not seem to fix this. However, this meant that I had to add my own 'selected' property, called 'turnedOn' to keep track of selection, which is a hack.
	//[super setSelected:isSelected];
    self.turnedOn = isSelected;

    if (self.isEnabled)
    {
        if (isSelected)
        {
            self.layer.backgroundColor = self.selectedBackgroundColor.CGColor;
            
            // Disable highlighting so that the color stays the background color
            // even after the touch ends, which calls setHighlighted:NO.
            self.highlightEnabled = NO;
        }
        else
        {
            self.layer.backgroundColor = self.normalBackgroundColor.CGColor;
            self.highlightEnabled = YES;
        }
    }
    else
    {
        self.layer.backgroundColor = self.disabledBackgroundColor.CGColor;
    }
}

- (void)setHighlighted:(BOOL)highlighted
{
    if (!self.highlightEnabled)
    {
        return;
    }
    
	[super setHighlighted:highlighted];
    if (self.isEnabled)
    {
        if (highlighted)
        {
            self.layer.backgroundColor = self.highlightedBackgroundColor.CGColor;
        }
        else
        {
            self.layer.backgroundColor = self.normalBackgroundColor.CGColor;
        }
    }
    else
    {
        self.layer.backgroundColor = self.disabledBackgroundColor.CGColor;
    }
}

/*
#pragma mark Events

- (void)buttonUp:(id)aButton event:(id)event
{
    if (self.isSelected)
    {
        self.layer.backgroundColor = self.selectedBackgroundColor.CGColor;
    }
    else
    {
        self.layer.backgroundColor = self.normalBackgroundColor.CGColor;        
    }
}


- (void)buttonDown:(id)aButton event:(id)event
{
    // TODO: Does not display when tapped quickly since buttonUp gets immediately
    // called, so the color is never changed.
	self.layer.backgroundColor = self.highlightedBackgroundColor.CGColor;
}
*/

@end
