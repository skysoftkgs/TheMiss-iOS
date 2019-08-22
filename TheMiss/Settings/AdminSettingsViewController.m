//
//  AdminSettingsViewController.m
//  TheMiss
//
//  Created by lion on 8/9/14.
//  Copyright (c) 2014 Arsan. All rights reserved.
//

#import "AdminSettingsViewController.h"
#import "HomeViewController.h"
#import "LogoutViewController.h"
#import "FlagedPictureTableViewCell.h"
#import "AdminSettingsFooterTableViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "Constants.h"

@interface AdminSettingsViewController ()<UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, FlagedPictureCellDelegate>
{
    NSMutableArray *flagedPictureArray;
    PFObject *selectedFlagedPictureObject;
    
    NSString *language;
    BOOL refreshing;
}

@end

@implementation AdminSettingsViewController

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
    
    language = LocalizedString(@"english");
    flagedPictureArray = [NSMutableArray array];
    [self refreshFlagedPictures];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayNotification:) name:LOCAL_NOTIFICATION_DISPLAY_NOTIFICATION object:_messageLabel];
}

- (void) viewWillAppear:(BOOL)animated{
    [self displayNotificationWithoutQuery:_messageLabel];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:LOCAL_NOTIFICATION_DISPLAY_NOTIFICATION object:_messageLabel];
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

- (IBAction)messageAction:(id)sender {
    [self messageMenuButtonAction];
}

- (IBAction)refreshAction:(id)sender {
    [self refreshFlagedPictures];
}

- (IBAction)languageAction:(id)sender {
    AdminSettingsFooterTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"AdminSettingsFooterCell"];
    [cell.emailTextField resignFirstResponder];
    [cell.passwordTextField resignFirstResponder];
    [cell.confirmPasswordTextField resignFirstResponder];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle: nil delegate:self cancelButtonTitle:LocalizedString(@"cancel") destructiveButtonTitle:nil otherButtonTitles:LocalizedString(@"English"), LocalizedString(@"Italian"), nil];
    [actionSheet setActionSheetStyle:UIActionSheetStyleDefault];
    [actionSheet showInView:self.view];
}

- (IBAction)saveAction:(id)sender {
    
    AdminSettingsFooterTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"AdminSettingsFooterCell"];
    
    //check if input value is valid
    if (![cell.passwordTextField.text isEqualToString:cell.confirmPasswordTextField.text]) {
        [MBProgressHUD showError:LocalizedString(@"password_not_match") toView:self.view];
    }
    
    [cell.emailTextField resignFirstResponder];
    [cell.passwordTextField resignFirstResponder];
    [cell.confirmPasswordTextField resignFirstResponder];
    
    [MBProgressHUD showMessag:LocalizedString(@"saving") toView:self.view];
    PFUser *currentUser = [PFUser currentUser];
    
    currentUser.email = cell.emailTextField.text;
    currentUser.password = cell.passwordTextField.text;
    [currentUser setObject:cell.languageButton.titleLabel.text forKey:@"language"];
    
    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        if (succeeded) {
            [MBProgressHUD showSuccess:LocalizedString(@"user_saved_successfully") toView:self.parentViewController.view];
            
            HomeViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"];
            [[SlideNavigationController sharedInstance] popAllAndSwitchToViewController:vc withCompletion:nil];
        }else{
            [MBProgressHUD showError:LocalizedString(@"unknown_server_error") toView:self.view];
        }
        
    }];

}

- (IBAction)logoutAction:(id)sender {
    LogoutViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"LogoutViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableView Delegate Methods -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return flagedPictureArray.count + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.row <flagedPictureArray.count) {
        return 425;
    }else{
        return 420;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row <flagedPictureArray.count) {
        static NSString *FlagedPictureCellIdentifier = @"FlagedPictureCell";
        FlagedPictureTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:FlagedPictureCellIdentifier];
        
        PFObject *flagedObject = flagedPictureArray[indexPath.row];
        PFObject *post = flagedObject[@"post"];
        PFFile *imageFile = post[@"image"];
        if (imageFile) {
            [cell.contentImageView setImageWithURL:[NSURL URLWithString:imageFile.url]];
        }
        
        
        cell.delegate = self;
        
        return cell;
    }else{
        static NSString *AdminSettingsFooterCellIdentifier = @"AdminSettingsFooterCell";
        AdminSettingsFooterTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:AdminSettingsFooterCellIdentifier];
        [cell.languageButton setTitle:language forState:UIControlStateNormal];
        
        return cell;
    }
    
    return nil;
}

#pragma mark - Prizes Cell delegate methods -

- (void) deletePhoto:(FlagedPictureTableViewCell *)cell{
    int index = [self.tableView indexPathForCell:cell].row;
    selectedFlagedPictureObject = flagedPictureArray[index];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"confirm_deleting") message:LocalizedString(@"delete_this_picture") delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [alert show];
}

#pragma mark - UIActionSheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    switch (buttonIndex) {
        case 0:
            language = LocalizedString(@"english");
            break;
            
        case 1:
            language = LocalizedString(@"italian");
            break;
            
        default:
            break;
    }
    
    [self.tableView reloadData];
}

#pragma mark - AlertView delegate Methods -
- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 1) {
        [MBProgressHUD showMessag:LocalizedString(@"deleting") toView:self.view];
        _refreshActivityIndicator.hidden = FALSE;
        [_refreshActivityIndicator startAnimating];
        _refreshButton.hidden = TRUE;
        [selectedFlagedPictureObject deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [self refreshFlagedPictures];
            }
        }];
    } else {
        
    }
}

#pragma mark - internal methods - 

- (void) refreshFlagedPictures{
    if (refreshing) {
        return;
    }
    
    refreshing = TRUE;
    _refreshActivityIndicator.hidden = FALSE;
    [_refreshActivityIndicator startAnimating];
    _refreshButton.hidden = TRUE;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    PFQuery *query = [PFQuery queryWithClassName:@"FlagedPicture"];
    [query orderByAscending:@"createdAt"];
    [query includeKey:@"post"];
    [query includeKey:@"user"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects && !error) {
            [flagedPictureArray removeAllObjects];
            [flagedPictureArray addObjectsFromArray:objects];
            [self.tableView reloadData];
        }
        
        refreshing = FALSE;
        _refreshActivityIndicator.hidden = TRUE;
        [_refreshActivityIndicator stopAnimating];
        _refreshButton.hidden = FALSE;
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }];
}

//- (void) sendNotification{
//    AppDelegate *appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
//    [appDelegate displayNotification:_messageLabel];
//}

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
