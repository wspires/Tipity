//
//  MACreditsViewController.m
//  Gym Log
//
//  Created by Wade Spires on 11/28/13.
//
//

#import "MACreditsViewController.h"

#import "MAAppearance.h"
#import "MAFilePaths.h"
#import "MAUtil.h"
#import "MAViewUtil.h"

#import "QuartzCore/QuartzCore.h"

@interface MACreditsViewController ()

@end

@implementation MACreditsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[self view] setBackgroundColor:[MAAppearance backgroundColor]];
    [MAUtil setAdjustableNavTitle:self.navigationItem.title withNavigationItem:self.navigationItem];

    self.webView.backgroundColor = [UIColor clearColor];
    self.webView.opaque = NO;
    //self.webView.layer.borderWidth = 1.0;
    //self.webView.layer.borderColor = [UIColor darkGrayColor].CGColor;
    //self.webView.layer.cornerRadius = 5;
    //self.webView.clipsToBounds = YES;
    NSString* htmlString = [NSString stringWithContentsOfFile:
                            [MAFilePaths creditsFile]
                            //encoding:NSUnicodeStringEncoding // TODO: Unicode support.
                                                     encoding:NSUTF8StringEncoding // English only.
                                                        error:nil];
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    [self.webView loadHTMLString:htmlString baseURL:baseURL];
    
    // Make web view scroll to the top when the status view is touched.
    // Have to use the scroll view contained within the webview since a web
    // view does not have the scrollsToTop property itself.
    ((UIScrollView*)[self.webView.subviews objectAtIndex:0]).scrollsToTop = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [[self view] setBackgroundColor:[MAAppearance backgroundColor]];
    [MAUtil updateNavItem:self.navigationItem withTitle:self.title];

    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return [MAViewUtil shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.activityIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.activityIndicator stopAnimating];
}

@end
