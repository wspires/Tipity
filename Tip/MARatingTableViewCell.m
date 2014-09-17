//
//  MARatingTableViewCell.m
//  Tip
//
//  Created by Wade Spires on 9/16/14.
//  Copyright (c) 2014 Minds Aspire LLC. All rights reserved.
//

#import "MARatingTableViewCell.h"

#import "MAAppearance.h"
#import "MAFilePaths.h"
#import "MAUserUtil.h"

static NSUInteger const BUTTON_START_TAG = 1;
static NSUInteger const BUTTON_END_TAG = 6;
//static NSUInteger const BUTTON_TAGS = BUTTON_END_TAG - BUTTON_START_TAG;

@implementation MARatingTableViewCell
@synthesize rating = _rating;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setRating:(NSUInteger)rating
{
    if (rating < BUTTON_START_TAG || rating >= BUTTON_END_TAG)
    {
        return;
    }
    _rating = rating;
    
    UIImage *filledStarImage = [MAFilePaths filledStarImage];
    UIImage *emptyStarImage = [MAFilePaths emptyStarImage];
    
    for (NSUInteger i = BUTTON_START_TAG; i != BUTTON_END_TAG; ++i)
    {
        UIView *view = [self viewWithTag:i];
        UIButton *button = (UIButton *)view;

        UIImage *image = filledStarImage;
        if (i > rating)
        {
            image = emptyStarImage;
        }
        button.imageView.image = image;
        [button setImage:image forState:UIControlStateHighlighted];
        [button setImage:image forState:UIControlStateSelected];
        [button setImage:image forState:UIControlStateNormal];
    }
}

- (void)delegateWillChangeRating
{
    if (_delegate && [_delegate respondsToSelector:@selector(ratingDidChange:)])
    {
        [_delegate ratingDidChange:self];
    }
}

- (void)setAppearanceInTable:(UITableView *)tableView;
{
    [MAAppearance setAppearanceForCell:self tableStyle:tableView.style];

    self.rating = 3;
}

- (void)setThreeStars:(BOOL)threeStars
{
    _threeStars = threeStars;
    self.button1.hidden = YES;
    self.button5.hidden = YES;
}

- (IBAction)buttonTapped:(id)sender
{
    UIButton *button = (UIButton *)sender;
    self.rating = button.tag;
    [self delegateWillChangeRating];
}

- (NSUInteger)ratingForTipPercent:(NSNumber *)tipPercent
{
    NSUInteger rating = 1;
    double tipPercentDouble = tipPercent.doubleValue;
    
    if (self.threeStars)
    {
//        double serviceRatingFair = [[MAUserUtil sharedInstance] serviceRatingFair].doubleValue;
        double serviceRatingGood = [[MAUserUtil sharedInstance] serviceRatingGood].doubleValue;
        double serviceRatingGreat = [[MAUserUtil sharedInstance] serviceRatingGreat].doubleValue;
        
        if (tipPercentDouble < serviceRatingGood)
        {
            rating = 2;
        }
        else if (tipPercentDouble >= serviceRatingGood && tipPercentDouble < serviceRatingGreat)
        {
            rating = 3;
        }
        else // if (tipPercentDouble >= serviceRatingGreat)
        {
            rating = 4;
        }
    }
    else
    {
        if (tipPercentDouble < 12)
        {
            rating = 1;
        }
        else if (tipPercentDouble >= 12 && tipPercentDouble < 15)
        {
            rating = 2;
        }
        else if (tipPercentDouble >= 15 && tipPercentDouble < 18)
        {
            rating = 3;
        }
        else if (tipPercentDouble >= 18 && tipPercentDouble < 20)
        {
            rating = 4;
        }
        else // if (tipPercentDouble >= 20)
        {
            rating = 5;
        }
    }

    return rating;
}

- (NSNumber *)tipPercentForRating:(NSUInteger)rating
{
    double tipPercentDouble = 0;

    if (self.threeStars)
    {
        NSNumber *tipPercent = nil;
        if (rating <= 2)
        {
            tipPercent = [[MAUserUtil sharedInstance] serviceRatingFair];
        }
        else if (rating <= 3)
        {
            tipPercent = [[MAUserUtil sharedInstance] serviceRatingGood];
        }
        else // if (rating <= 4)
        {
            tipPercent = [[MAUserUtil sharedInstance] serviceRatingGreat];
        }
        tipPercentDouble = tipPercent.doubleValue;
    }
    else
    {
        if (rating == 1)
        {
            tipPercentDouble = 10;
        }
        else if (rating == 2)
        {
            tipPercentDouble = 12;
        }
        else if (rating == 3)
        {
            tipPercentDouble = 15;
        }
        else if (rating == 4)
        {
            tipPercentDouble = 18;
        }
        else // if (rating == 5)
        {
            tipPercentDouble = 20;
        }
    }

    return [NSNumber numberWithDouble:tipPercentDouble];
}

@end
