//
//  MailLoginViewController.m
//  TheMiss
//
//  Created by lion on 6/23/14.
//  Copyright (c) 2014 Arsan. All rights reserved.
//

#import "MailLoginViewController.h"
#import "LoginViewController.h"
#import "IKLoginViewController.h"
#import "HomeViewController.h"
#import "Utils.h"
#import "Constants.h"


@interface MailLoginViewController ()<IGLoginDelegate>

@end

@implementation MailLoginViewController

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
    // Do any additional setup after loading the view.
    [self.scrollView setContentSize:CGSizeMake(320, 600)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginWithEmailAction:(id)sender {
    if (![Utils checkInputValue:_emailTextField fieldName:LocalizedString(@"email")]) return;
    if (![Utils checkInputValue:_passwordTextField fieldName:LocalizedString(@"password")]) return;
    
    [_emailTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
    
    [MBProgressHUD showMessag:LocalizedString(@"loggingIn") toView:self.view];
    
    PFQuery *query = [PFUser query];
    [query whereKey:@"email" equalTo:_emailTextField.text];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!objects || [objects count] == 0) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [MBProgressHUD showError:LocalizedString(@"wrong_username") toView:self.view];
            return;
        }
        
        PFUser *user = (PFUser*)objects[0];
        [PFUser logInWithUsernameInBackground:user.username password:_passwordTextField.text block:^(PFUser *user, NSError *error) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            if (user) {
                PFInstallation *installation = [PFInstallation currentInstallation];
                [installation setObject:user forKey:@"user"];
                [installation saveEventually];

                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:LOGGEDIN];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                HomeViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"];
                [[SlideNavigationController sharedInstance] popAllAndSwitchToViewController:vc withCompletion:nil];
            }else{
                [MBProgressHUD showError:LocalizedString(@"wrong_username") toView:self.view];
            }
        }];
    }];
}

- (IBAction)loginWithFacebookAction:(id)sender {
    [LoginViewController loginWithFacebook:self.view];
}

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark IGWebViewDelegate

-(void)igDidLogin{
    
    [self dismissViewControllerAnimated:YES completion:^{
        HomeViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"];
        [[SlideNavigationController sharedInstance] popAllAndSwitchToViewController:vc withCompletion:nil];
    }];
}

-(void)igDidNotLogin:(BOOL)cancelled{
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"Instagram did not login");
        NSString *message = nil;
        if (cancelled) {
            message = @"Access cancelled";
        }else{
            message = @"Access denied";
        }
        [Utils showError:nil content:message];
        
    }];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowInstagramLogin"]) {
        IKLoginViewController *destinationView = (IKLoginViewController *)[segue destinationViewController];
        destinationView.loginDelegate = self;
        destinationView.loggingInWithInstagram = TRUE;
    }
}

@end
