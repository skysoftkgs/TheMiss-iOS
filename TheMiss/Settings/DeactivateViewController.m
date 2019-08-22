//
//  DeactivateViewController.m
//  TheMiss
//
//  Created by lion on 7/4/14.
//  Copyright (c) 2014 Arsan. All rights reserved.
//

#import "DeactivateViewController.h"

extern BOOL refreshRequired;

@interface DeactivateViewController ()

@end

@implementation DeactivateViewController

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

- (IBAction)noAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)yesAction:(id)sender {
    PFUser *currentUser = [PFUser currentUser];
    
    [MBProgressHUD showMessag:LocalizedString(@"deactivating") toView:self.view];
    [currentUser setObject:[NSNumber numberWithBool:TRUE] forKey:@"deactive"];
    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if (succeeded) {
            [self.navigationController popViewControllerAnimated:YES];
            refreshRequired = TRUE;
        }
    }];
}

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
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
