//
//  PasswordResetViewController.m
//  TheMiss
//
//  Created by lion on 6/24/14.
//  Copyright (c) 2014 Arsan. All rights reserved.
//

#import "PasswordResetViewController.h"
#import "LoginViewController.h"
#import "IKLoginViewController.h"
#import "HomeViewController.h"
#import "Utils.h"


@interface PasswordResetViewController ()<IGLoginDelegate>

@end

@implementation PasswordResetViewController

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
    [self.scrollView setContentSize:CGSizeMake(320, 520)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sendAction:(id)sender {
    [PFUser requestPasswordResetForEmailInBackground:_emailTextField.text block:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [MBProgressHUD showSuccess:LocalizedString(@"check_your_email") toView:self.view];
        }else{
            [Utils showError:nil content:LocalizedString(@"that_email_not_register")];
        }
    }];
}

- (IBAction)loginWithFacebookAction:(id)sender {
    [LoginViewController loginWithFacebook:self.view];
}

- (IBAction)backAction:(id)sender {
    [[SlideNavigationController sharedInstance] popViewControllerAnimated:YES];
}

- (IBAction)cancelAction:(id)sender {
    [[SlideNavigationController sharedInstance] popViewControllerAnimated:YES];
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
