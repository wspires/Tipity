//
//  MAColorSelectionViewController.h
//  Gym Log
//
//  Created by Wade Spires on 10/24/13.
//
//

#import <UIKit/UIKit.h>
#import "MOGlassButton.h"

@interface MAColorSelectionViewController : UIViewController

@property (copy, nonatomic) NSString *settingsKey;

@property (weak, nonatomic) IBOutlet MOGlassButton *testBtn;
@property (weak, nonatomic) IBOutlet UISlider *redSlider;
@property (weak, nonatomic) IBOutlet UISlider *greenSlider;
@property (weak, nonatomic) IBOutlet UISlider *blueSlider;
@property (weak, nonatomic) IBOutlet UILabel *redLabel;
@property (weak, nonatomic) IBOutlet UILabel *greenLabel;
@property (weak, nonatomic) IBOutlet UILabel *blueLabel;
@property (weak, nonatomic) IBOutlet UILabel *noteLabel;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *topSpaceConstraint;

- (IBAction) sliderValueChanged:(id)sender;

@end
