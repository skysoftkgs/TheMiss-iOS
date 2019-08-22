//
//  LogoutViewController.m
//  TheMiss
//
//  Created by lion on 6/23/14.
//  Copyright (c) 2014 Arsan. All rights reserved.
//

#import "LogoutViewController.h"
#import "HomeViewController.h"
#import "Constants.h"


@interface LogoutViewController ()

@end

@implementation LogoutViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)noAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)yesAction:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:LOGGEDIN];
    [[NSUserDefaults standardUserDefaults] synchronize];

    if ([PFFacebookUtils session]) {
        [[PFFacebookUtils session] closeAndClearTokenInformation];
    }
    
    if (FBSession.activeSession) {
        [FBSession.activeSession closeAndClearTokenInformation];
    }
    
    [PFUser logOut];
    
    HomeViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"];
    [[SlideNavigationController sharedInstance] popAllAndSwitchToViewController:vc withCompletion:nil];
}

#pragma mark - SlideNavigationController Methods -

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
	return YES;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu
{
	return NO;
}

@end
