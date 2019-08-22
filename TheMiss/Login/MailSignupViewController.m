//
//  MailSignupViewController.m
//  TheMiss
//
//  Created by lion on 6/23/14.
//  Copyright (c) 2014 Arsan. All rights reserved.
//

#import "MailSignupViewController.h"
#import "LoginViewController.h"
#import "IKLoginViewController.h"
#import "HomeViewController.h"
#import "Utils.h"
#import "Constants.h"


@interface MailSignupViewController ()<IGLoginDelegate>

@end

@implementation MailSignupViewController

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
    [self.scrollView setContentSize:CGSizeMake(320, 770)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)signupAction:(id)sender {
    if (![Utils checkInputValue:_userNameTextField fieldName:LocalizedString(@"username")]) return;
    if (![Utils checkInputValue:_emailTextField fieldName:LocalizedString(@"email")]) return;
    if (![Utils checkInputValue:_passwordTextField fieldName:LocalizedString(@"password")]) return;
    if (![Utils checkInputValue:_confirmPasswordTextField fieldName:LocalizedString(@"confirm_password")]) return;
    if (![_passwordTextField.text isEqualToString:_confirmPasswordTextField.text]) {
        [MBProgressHUD showError:LocalizedString(@"password_not_match") toView:self.view];
        return;
    }
    
    PFUser *user = [[PFUser alloc] init];
    [user setUsername:_userNameTextField.text];
    [user setPassword:_passwordTextField.text];
    [user setEmail:_emailTextField.text];
    [user setObject:@"mail" forKey:@"loggedInWay"];
    [user setObject:@"english" forKey:@"language"];
    if (_femaleButton.selected)
        [user setObject:LocalizedString(@"female") forKey:@"gender"];
    else
        [user setObject:LocalizedString(@"male") forKey:@"gender"];
    
    [_userNameTextField resignFirstResponder];
    [_emailTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
    [_confirmPasswordTextField resignFirstResponder];
    
    [MBProgressHUD showMessag:LocalizedString(@"signing_up") toView:self.view];
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        if (succeeded) {
            PFInstallation *installation = [PFInstallation currentInstallation];
            [installation setObject:user forKey:@"user"];
            [installation saveEventually];
            
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:LOGGEDIN];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            HomeViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"];
            [[SlideNavigationController sharedInstance] popAllAndSwitchToViewController:vc withCompletion:nil];
        }else{
            [MBProgressHUD showError:LocalizedString(@"username_exists") toView:self.view];
        }
    }];
    
}

- (IBAction)loginAction:(id)sender {
    [[SlideNavigationController sharedInstance] popViewControllerAnimated:YES];
}

- (IBAction)loginWithFacebookAction:(id)sender {
    [LoginViewController loginWithFacebook:self.view];
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
