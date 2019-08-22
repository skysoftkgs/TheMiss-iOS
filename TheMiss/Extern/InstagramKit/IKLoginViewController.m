//
//    Copyright (c) 2013 Shyam Bhat
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy of
//    this software and associated documentation files (the "Software"), to deal in
//    the Software without restriction, including without limitation the rights to
//    use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//    the Software, and to permit persons to whom the Software is furnished to do so,
//    subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in all
//    copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//    FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//    COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//    IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//    CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "IKLoginViewController.h"
#import "InstagramKit.h"
#import "Constants.h"

@implementation IKLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    mWebView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    mWebView.scrollView.bounces = NO;
    mWebView.contentMode = UIViewContentModeScaleAspectFit;
    mWebView.delegate = self;
    NSDictionary *configuration = [InstagramEngine sharedEngineConfiguration];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?client_id=%@&redirect_uri=%@&response_type=token&scope=likes+comments", configuration[kInstagramKitAuthorizationUrlConfigurationKey], configuration[kInstagramKitAppClientIdConfigurationKey], configuration[kInstagramKitAppRedirectUrlConfigurationKey]]];
    [mWebView loadRequest:[NSURLRequest requestWithURL:url]];
    
}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *URLString = [request.URL absoluteString];
    if ([URLString hasPrefix:[[InstagramEngine sharedEngine] appRedirectURL]]) {
        NSString *delimiter = @"access_token=";
        NSArray *components = [URLString componentsSeparatedByString:delimiter];
        if (components.count > 1) {
            
            
            NSString *accessToken = [components lastObject];
            NSLog(@"ACCESS TOKEN = %@",accessToken);
            [[InstagramEngine sharedEngine] setAccessToken:accessToken];
            
            [[InstagramEngine sharedEngine] getSelfUserDetailWithSuccess:^(InstagramUser *userDetail) {
                
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                
                if (self.loggingInWithInstagram) {
                    [self loginWithInstagram:userDetail];
                }else{
                    [self linkWithInstagram:userDetail];
                }
                
            } failure:^(NSError *error) {
                
                [self.loginDelegate igDidNotLogin:NO];
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            }];
            

        }else{
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        }
        return NO;
    }
    return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

-(void) instagramLoginSuccess:(PFUser*)user{
    PFInstallation *installation = [PFInstallation currentInstallation];
    [installation setObject:user forKey:@"user"];
    [installation saveEventually];
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:LOGGEDIN];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.loginDelegate igDidLogin];
}

- (void) loginWithInstagram:(InstagramUser*)userDetail{
    
    NSString *igUserID = userDetail.Id;
    
    PFQuery *query = [PFUser query];
    [query whereKey:@"instagramID" equalTo:igUserID];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {

        if (object) { //lgoin with instagram
            if (object[@"loggedInWay"] && [object[@"loggedInWay"] isEqualToString:@"instagram"]) {
                
                [PFUser logInWithUsernameInBackground:userDetail.username password:@"" block:^(PFUser *user, NSError *error) {
                    if (!error) {
                        [self instagramLoginSuccess:user];
                    }else{
                        [self.loginDelegate igDidNotLogin:NO];
                    }
                }];
                
            }else{
                [self.loginDelegate igDidNotLogin:NO];
            }
        }else{  //signup with instagram
            
            PFUser *user = [[PFUser alloc] init];
            user.username = userDetail.username;
            user.password = @"";
            [user setObject:igUserID forKey:@"instagramID"];
            [user setObject:@"instagram" forKey:@"loggedInWay"];
            [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    [self instagramLoginSuccess:user];
                }else{
                    [self.loginDelegate igDidNotLogin:NO];
                }
            }];
        }
    }];

}

- (void) linkWithInstagram:(InstagramUser*)userDetail{
    
    NSString *igUserID = userDetail.Id;
    
    PFQuery *query = [PFUser query];
    [query whereKey:@"instagramID" equalTo:igUserID];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        
        if (object) {
            [self.loginDelegate igDidNotLogin:NO];
        }else{
            PFUser *currentUser = [PFUser currentUser];
            [currentUser setObject:igUserID forKey:@"instagramID"];
            [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    [self.loginDelegate igDidLogin];
                }else{
                    [self.loginDelegate igDidNotLogin:NO];
                }
            }];
        }
        
    }];
}

@end
