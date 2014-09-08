//
//  MACreditsViewController.h
//  Gym Log
//
//  Created by Wade Spires on 11/28/13.
//
//

#import <UIKit/UIKit.h>

@interface MACreditsViewController : UIViewController
<UIWebViewDelegate>

@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
