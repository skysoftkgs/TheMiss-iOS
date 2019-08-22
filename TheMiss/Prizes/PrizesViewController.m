//
//  PrizesViewController.m
//  TheMiss
//
//  Created by lion on 8/8/14.
//  Copyright (c) 2014 Arsan. All rights reserved.
//

#import "PrizesViewController.h"
#import "PrizesTableViewCell.h"
#import "TutorialViewController.h"
#import "RulesViewController.h"
#import "Utils.h"
#import "Constants.h"
#import "UIImageView+AFNetworking.h"

@interface PrizesViewController ()<UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate, PrizeCellDelegate>
{
    NSMutableArray *prizesArray;
    PFObject *selectedPrize;
    
    BOOL refreshing;
}
@property (nonatomic, assign) UIBackgroundTaskIdentifier fileUploadBackgroundTaskId;
@end

@implementation PrizesViewController

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
    
    [self setLoginStatus];
    
    prizesArray = [NSMutableArray array];
    [self refreshPrizes];
    
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser && [currentUser[@"admin"] intValue] == 1) {
        _addPhotoButton.hidden = FALSE;
    }else{
        _addPhotoButton.hidden = TRUE;
    }
}

- (void)viewWillAppear:(BOOL)animated{
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

- (IBAction)refreshAction:(id)sender {
    [self refreshPrizes];
}

- (IBAction)messageAction:(id)sender {
    [self messageMenuButtonAction];
}

- (IBAction)plusAction:(id)sender {
    [self plusMenuButtonAction];
}

- (IBAction)addPhotoAction:(id)sender {
    NSLog(@"Select Image");
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle: LocalizedString(@"select_image") delegate:self cancelButtonTitle:LocalizedString(@"cancel") destructiveButtonTitle:nil otherButtonTitles:LocalizedString(@"from_album"), LocalizedString(@"from_camera"), nil];
    [actionSheet setActionSheetStyle:UIActionSheetStyleDefault];
    [actionSheet showInView:self.view];
}

- (IBAction)tutorialAction:(id)sender {
    TutorialViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"TutorialViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)rulesAndPrivacyAction:(id)sender {
    RulesViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"RulesViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableView Delegate Methods -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return prizesArray.count + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.row <prizesArray.count) {
        PFUser *currentUser = [PFUser currentUser];
        if(currentUser && currentUser[@"admin"] == FALSE)
            return 320;
        else
            return 370;
    }else{
        return 200;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row <prizesArray.count) {
        static NSString *PrizesCellIdentifier = @"PrizesCell";
        PrizesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PrizesCellIdentifier];
        
        PFObject *prize = prizesArray[indexPath.row];
        PFFile *imageFile = prize[@"image"];
        if (imageFile) {
            [cell.contentImageView setImageWithURL:[NSURL URLWithString:imageFile.url]];
        }
        
        PFUser *currentUser = [PFUser currentUser];
        if(currentUser && currentUser[@"admin"] == FALSE)
            cell.deleteView.hidden = TRUE;
        else
            cell.deleteView.hidden = FALSE;
        
        cell.delegate = self;
        
        return cell;
    }else{
        static NSString *PrizeFooterCellIdentifier = @"PrizeFooterCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PrizeFooterCellIdentifier];
        
        return cell;
    }
    
    return nil;
}


#pragma mark - Prizes Cell delegate methods -

- (void) deletePhoto:(PrizesTableViewCell *)cell{
    int index = [self.tableView indexPathForCell:cell].row;
    selectedPrize = prizesArray[index];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"confirm_deleting") message:LocalizedString(@"delete_this_picture") delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [alert show];
}

#pragma mark - AlertView delegate Methods -
- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 1) {
        [MBProgressHUD showMessag:LocalizedString(@"deleting") toView:self.view];
        _refreshActivityIndicator.hidden = FALSE;
        [_refreshActivityIndicator startAnimating];
        _refreshButton.hidden = TRUE;
        [selectedPrize deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [self refreshPrizes];
            }
        }];
    } else {
        
    }
}

#pragma mark - UIActionSheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    [imagePicker setDelegate:self];
    [imagePicker setAllowsEditing:YES];
    
    switch (buttonIndex) {
        case 0:
            [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            [self presentViewController:imagePicker animated:YES completion:nil];
            break;
            
        case 1:
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
                [self presentViewController:imagePicker animated:YES completion:nil];
            }else{
                NSLog(@"NO CAMERA!");
            }
        default:
            break;
    }
}

#pragma mark - UIImagePickerController delegate

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *selectedPhoto = info[UIImagePickerControllerEditedImage];
    [self uploadImage:selectedPhoto rate:0.6f];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - internal methods -

- (void) uploadImage:(UIImage *)image rate:(float)compressRate{
    if (!image) return;
    
    [MBProgressHUD showMessag:LocalizedString(@"uploading") toView:self.view];
    
    PFObject *prize = [PFObject objectWithClassName:@"Prizes"];
    
    //Resize the image to be square
    UIImage *resizedImage = [Utils centerCropImage:[Utils resizeImage:image withMaxDimension:MAX_UPLOAD_PHOTO_WIDTH]];
    NSData *imageData = UIImageJPEGRepresentation(resizedImage, compressRate);
    PFFile *imageFile = [PFFile fileWithName:@"image.jpg" data:imageData];
    prize[@"image"] = imageFile;
    [prize saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if (succeeded) {
            
            NSLog(@"%@", @"Uploaded successfully");
//            [MBProgressHUD showSuccess:LocalizedString(@"uploaded_successfully") toView:self.view];
            [self refreshPrizes];
            
        }else{
            
            [Utils showError:self content:@"Server error"];
        }
        
        [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
    }];
    
    // Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
    self.fileUploadBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
    }];
    
}


- (void) refreshPrizes{
    if (refreshing) {
        return;
    }
    
    refreshing = TRUE;
    _refreshActivityIndicator.hidden = FALSE;
    [_refreshActivityIndicator startAnimating];
    _refreshButton.hidden = TRUE;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Prizes"];
    [query orderByAscending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects && !error) {
            [prizesArray removeAllObjects];
            [prizesArray addObjectsFromArray:objects];
            [self.tableView reloadData];
        }
        
        refreshing = FALSE;
        _refreshActivityIndicator.hidden = TRUE;
        [_refreshActivityIndicator stopAnimating];
        _refreshButton.hidden = FALSE;
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }];
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
