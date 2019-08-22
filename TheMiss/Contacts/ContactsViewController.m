//
//  ContactsViewController.m
//  TheMiss
//
//  Created by lion on 8/9/14.
//  Copyright (c) 2014 Arsan. All rights reserved.
//

#import "ContactsViewController.h"
#import <MessageUI/MessageUI.h>
#import "Constants.h"

@interface ContactsViewController ()<UIActionSheetDelegate, MFMailComposeViewControllerDelegate>
{
    NSString *subject;
}
@end

@implementation ContactsViewController

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
    
    [self setLoginStatus];
    [_scrollView setContentSize:CGSizeMake(320, 504)];
    subject = LocalizedString(@"report_problem");
}

- (void) viewWillAppear:(BOOL)animated{
    [self displayNotificationWithoutQuery:_messageLabel];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(arriveNotification) name:LOCAL_NOTIFICATION_DISPLAY_NOTIFICATION object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:LOCAL_NOTIFICATION_DISPLAY_NOTIFICATION object:nil];
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

- (IBAction)loginAction:(id)sender {
    [self loginMenuButtonAction];
}

- (IBAction)messageAction:(id)sender {
    [self messageMenuButtonAction];
}

- (IBAction)plusAction:(id)sender {
    [self plusMenuButtonAction];
}

- (IBAction)sendAction:(id)sender {
    [self sendEmail];
}

- (IBAction)categoryAction:(id)sender {
    
    [_nameTextField resignFirstResponder];
    [_messageTextView resignFirstResponder];
    
    NSLog(@"Select category");
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle: nil delegate:self cancelButtonTitle:LocalizedString(@"cancel") destructiveButtonTitle:nil otherButtonTitles:LocalizedString(@"report_problem"), LocalizedString(@"send_suggestion"), LocalizedString(@"business_press"), nil];
    [actionSheet setActionSheetStyle:UIActionSheetStyleDefault];
    [actionSheet showInView:self.view];
}

#pragma mark - UIActionSheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    switch (buttonIndex) {
        case 0:
            subject = LocalizedString(@"report_problem");
            break;
            
        case 1:
            subject = LocalizedString(@"send_suggestion");
            break;
            
        case 2:
            subject = LocalizedString(@"business_press");
            break;
            
        default:
            break;
    }
    
    [_categoryButton setTitle:subject forState:UIControlStateNormal];
}

#pragma mark - interanl methods - 

- (void) sendEmail{
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    if ([MFMailComposeViewController canSendMail]) {
        mc.mailComposeDelegate = self;
        [mc setSubject:subject];
        [mc setMessageBody:_messageTextView.text isHTML:NO];
        [mc setToRecipients:[NSArray arrayWithObjects:@"info@themiss.tv" , nil]];
        
        [self presentViewController:mc animated:YES completion:nil];
    }
}

- (void) setLoginStatus{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:LOGGEDIN]){
        PFUser *currentUser = [PFUser currentUser];
        if (!currentUser[@"admin"]) {
            [_plusButton setHidden:FALSE];
        }else{
            [_plusButton setHidden:TRUE];
        }
        
        [_messageButton setHidden:FALSE];
        [_loginButton setHidden:TRUE];
        
    }else{
        [_plusButton setHidden:TRUE];
        [_messageButton setHidden:TRUE];
        [_loginButton setHidden:FALSE];
    }
}

- (void) arriveNotification{
    [self displayNotificationWithQuery:_messageLabel];
}

#pragma mark - mail compose delegate methods -

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    switch (result) {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
           
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
            
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
            
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failture: %@", [error localizedDescription]);
            break;
            
        default:
            break;
    }
    
    //close the mail interface
    [self dismissViewControllerAnimated:YES completion:nil];
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
