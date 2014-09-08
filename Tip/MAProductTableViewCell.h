//
//  MAPricePickerCellTableViewCell.h
//  Gym Log
//
//  Created by Wade Spires on 8/25/14.
//
//

#import <UIKit/UIKit.h>

#import "MAProduct.h"

static NSInteger const InvalidTag = -1;
static NSInteger const PriceTag = 1;
static NSInteger const QuantityTag = 2;
static NSInteger const SizeTag = 3;

@protocol MAProductCellDelegate;

@interface MAProductTableViewCell : UITableViewCell

@property (weak, nonatomic) MAProduct *product;
@property (weak, nonatomic) id <MAProductCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UITextField *priceField;
@property (weak, nonatomic) IBOutlet UITextField *quantityField;
@property (weak, nonatomic) IBOutlet UITextField *sizeField;
@property (weak, nonatomic) IBOutlet UILabel *separatorLabel;
@property (weak, nonatomic) IBOutlet UILabel *quantitySizeSeparatorLabel;
@property (strong, nonatomic) UIToolbar *keyboardAccessoryView;
@property (assign, nonatomic) BOOL hideIconView;
@property (assign, nonatomic) BOOL hideSizeField;
@property (assign, nonatomic) BOOL hideDescription;
@property (assign, nonatomic) BOOL userInteractionEnabled;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (assign, readonly, nonatomic) CGFloat rowHeight;
@property (nonatomic, assign) NSUInteger pricePerUnitFractionDigits;

- (void)configureWithProduct:(MAProduct *)product;

- (void)dismissKeyboard;
- (NSInteger)tagForFirstResponder;
- (UITextField *)textFieldForTag:(NSInteger)tag;
@end

@protocol MAProductCellDelegate <NSObject>
@optional
- (void)didBeginEditingCell:(MAProductTableViewCell *)cell;
- (void)didEndEditingCell:(MAProductTableViewCell *)cell;
@end
