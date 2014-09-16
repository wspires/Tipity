//
//  MARatingTableViewCell.h
//  Tip
//
//  Created by Wade Spires on 9/16/14.
//  Copyright (c) 2014 Minds Aspire LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MARatingDelegate;

@interface MARatingTableViewCell : UITableViewCell

@property (assign, nonatomic) NSUInteger rating;
@property (weak, nonatomic) IBOutlet UIButton *button1;
@property (weak, nonatomic) IBOutlet UIButton *button2;
@property (weak, nonatomic) IBOutlet UIButton *button3;
@property (weak, nonatomic) IBOutlet UIButton *button4;
@property (weak, nonatomic) IBOutlet UIButton *button5;
@property (assign, nonatomic) BOOL threeStars;

@property (weak, nonatomic) id <MARatingDelegate> delegate;

- (void)setAppearanceInTable:(UITableView *)tableView;

- (IBAction)buttonTapped:(id)sender;

- (NSUInteger)ratingForTipPercent:(NSNumber *)tipPercent;
- (NSNumber *)tipPercentForRating:(NSUInteger)rating;
@end

@protocol MARatingDelegate <NSObject>
@optional
- (void)ratingDidChange:(MARatingTableViewCell *)ratingCell;
@end
