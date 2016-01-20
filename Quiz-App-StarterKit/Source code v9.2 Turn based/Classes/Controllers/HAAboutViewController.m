//
//  HAAboutViewController.m
//  TAKE A TEST
//
//  Created by Pavithra Satish on 12/05/14.
//  Copyright (c) 2014 Heaven Apps. All rights reserved.
//

#import "HAAboutViewController.h"

@interface HAAboutViewController ()

@end

@implementation HAAboutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:[HAUtilities nibNameForString:nibNameOrNil] bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString* text = [HASettings sharedManager]._aboutScreenTextOrURL;
    if ([NSURL URLWithString:text] == nil) {
        self._aboutTextView.text = text;
        self._aboutTextView.textColor = [HASettings sharedManager]._appTextColor;
        self._aboutTextView.hidden = NO;
        self._webView.hidden = YES;
    }
    else{
        NSURL* url = [NSURL URLWithString:text];
        NSURLRequest* request = [NSURLRequest requestWithURL:url];
        [self._webView loadRequest:request];
    }
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self._homeButton];
    [self._homeButton setTitleColor:[HASettings sharedManager]._appTextColor forState:UIControlStateNormal];
    self.navigationItem.titleView = self._titleLabel;
    
    [self.navigationController.navigationBar setTranslucent:YES];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action Methods
- (IBAction)homeAction:(id)sender
{
    [HAUtilities playTapSound];
    self._webView.delegate = nil;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Web view delegates
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}
@end
