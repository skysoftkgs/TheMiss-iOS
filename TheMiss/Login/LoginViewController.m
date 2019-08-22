//
//  LoginViewController.m
//  TheMiss
//
//  Created by lion on 6/22/14.
//  Copyright (c) 2014 Arsan. All rights reserved.
//

#import "LoginViewController.h"
#import "HomeViewController.h"
#import "IKLoginViewController.h"
#import "Constants.h"
#import "Utils.h"
#import "AppDelegate.h"
#import "AppManager.h"

@interface LoginViewController ()<IGLoginDelegate>

@end

@implementation LoginViewController

//static LoginViewController *singletonInstance;
//
//+ (LoginViewController *)sharedInstance
//{
//	static dispatch_once_t p = 0;
//    __strong static id _sharedObject = nil;
//    
//    dispatch_once(&p, ^{
//        _sharedObject = [[self alloc] init];
//    });
//	
//	return _sharedObject;
//}

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
//    singletonInstance = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backAction:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)loginWithFacebookAction:(id)sender {
    [LoginViewController loginWithFacebook:self.view];
}

+ (void)registerUser:(UIView *)view{
    
    NSLog(@"registering user infomation");
    
    if ([FBSession.activeSession isOpen]) {
        
        NSString *requestPath = @"me/?fields=name,location,gender,birthday,relationship_status,first_name,last_name";
        
        FBRequest *request = [FBRequest requestForGraphPath:requestPath];
        [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            // handle response
            if (!error) {
                // Parse the data received
                NSDictionary *userData = (NSDictionary *)result;
                NSString *facebookId = userData[@"id"];
                NSString *name = userData[@"name"];
                NSString *location = userData[@"location"][@"name"];
                NSString *gender = userData[@"gender"];
                NSString *birthday = userData[@"birthday"];
                NSString *relationship = userData[@"relationship_status"];
                NSString *first_name = userData [@"firstName"];
                NSString *last_name = userData [@"lastName"];
                
                NSLog(@"name: %@",name);
                NSLog(@"id: %@",facebookId);
                NSLog(@"birthday: %@",birthday);
                NSLog(@"relationship: %@",relationship);
                NSLog(@"gender: %@",gender);
                NSLog(@"location: %@",location);
                NSLog(@"first name: %@",first_name);
                NSLog(@"last name: %@",last_name);
                
                PFUser *currentUser = [PFUser currentUser];
                
                [currentUser setObject:facebookId forKey:@"facebookID"];
                if (gender) {
                    [currentUser setObject:gender forKey:@"gender"];
                }
                if (birthday) {
                    [currentUser setObject:birthday forKey:@"birthday"];
                }
                if (relationship) {
                    [currentUser setObject:relationship forKey:@"relationship"];
                }
                if (location) {
                    [currentUser setObject:location forKey:@"location"];
                }
                if (first_name) {
                    [currentUser setObject:first_name forKey:@"firstName"];
                }
                if (last_name) {
                    [currentUser setObject:last_name forKey:@"lastName"];
                }
                
                [currentUser setObject:@"facebook" forKey:@"loggedInWay"];
                
                if ([currentUser isNew]){
                    if (name) {
                        currentUser.username = name;
                    }
                    currentUser.password = @"";
                }
                
                [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        if (![PFFacebookUtils isLinkedWithUser:currentUser]) {
                            [PFFacebookUtils linkUser:currentUser permissions:nil block:^(BOOL succeeded, NSError *error) {
                                if (succeeded) {
                                    NSLog(@"User, user logged in with Facebook!");
                                }
                            }];
                        }
                        
                        PFInstallation *installation = [PFInstallation currentInstallation];
                        [installation setObject:currentUser forKey:@"user"];
                        [installation saveEventually];
                        
                        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle: nil];
                        
                        HomeViewController *vc;
                        if ([[[SlideNavigationController sharedInstance] topViewController] isKindOfClass:[HomeViewController class]]) {
                            vc = (HomeViewController*)[[SlideNavigationController sharedInstance] topViewController] ;
                            [vc setLoginStatus];
                            [vc.tableView reloadData];
                            
                        }else{
                            vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"HomeViewController"];
                        }
                        [[SlideNavigationController sharedInstance] popAllAndSwitchToViewController:vc withCompletion:nil];
                    }
                    [MBProgressHUD hideAllHUDsForView:view animated:YES];
                }];
                
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:LOGGEDIN];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
            }else{
                [MBProgressHUD hideAllHUDsForView:view animated:YES];
            }
        }];
        
    }else{
        [MBProgressHUD hideAllHUDsForView:view animated:YES];
    }
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

+ (void) loginWithFacebook:(UIView *) view{
    NSArray *permissionsArray = @[@"user_photos"];
    
    [MBProgressHUD showMessag:LocalizedString(@"loggingIn") toView:view];
    // Login PFUser using Facebook
    [[FBSession activeSession] closeAndClearTokenInformation];
    [[PFFacebookUtils session] closeAndClearTokenInformation];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.facebookSeesionFromParse = TRUE;
    
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        
        if (!user) {
            [MBProgressHUD hideAllHUDsForView:view animated:YES];
            if (!error) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
            } else {
                NSLog(@"Uh oh. An error occurred: %@", error);
            }
        } else if (user.isNew) {
            NSLog(@"User with facebook signed up and logged in!");
            [self registerUser:view];
            
        } else {
            NSLog(@"User with facebook logged in!");
            [self registerUser:view];
        }
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
