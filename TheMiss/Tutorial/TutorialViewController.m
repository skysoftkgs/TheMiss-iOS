//
//  TutorialViewController.m
//  TheMiss
//
//  Created by lion on 8/8/14.
//  Copyright (c) 2014 Arsan. All rights reserved.
//

#import "TutorialViewController.h"
#import "TutorialTableViewCell.h"
#import "PhotoSamplerTableViewCell.h"
#import "PrizesViewController.h"
#import "RulesViewController.h"
#import "UIImageView+AFNetworking.h"
#import "Utils.h"
#import "Constants.h"

@interface TutorialViewController ()<UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate, PhotoSamplerCellDelegate, UIWebViewDelegate>
{
    NSMutableArray *photoSamplerArray;
    PFObject *selectedPhotoSampler;
    
    BOOL refreshing;
    BOOL itVideoLoaded;
    BOOL enVideoLoaded;
}
@property (nonatomic, assign) UIBackgroundTaskIdentifier fileUploadBackgroundTaskId;
@end

@implementation TutorialViewController

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
    itVideoLoaded = NO;
    enVideoLoaded = NO;
    
    photoSamplerArray = [NSMutableArray array];
    [self refreshPhotoSampler];
    
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser && [currentUser[@"admin"] intValue] == 1) {
        _addPhotoView.hidden = FALSE;
    }else{
        _addPhotoView.hidden = TRUE;
        _tableView.frame = CGRectMake(0, 64, 320, 496);
    }
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

- (IBAction)plusAction:(id)sender {
    [self plusMenuButtonAction];
}

- (IBAction)messageAction:(id)sender {
    [self messageMenuButtonAction];
}

- (IBAction)refreshAction:(id)sender {
    [self refreshPhotoSampler];
}

- (IBAction)addPhotoAction:(id)sender {
    NSLog(@"Select Image");
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle: LocalizedString(@"select_image") delegate:self cancelButtonTitle:LocalizedString(@"cancel") destructiveButtonTitle:nil otherButtonTitles:LocalizedString(@"from_album"), LocalizedString(@"from_camera"), nil];
    [actionSheet setActionSheetStyle:UIActionSheetStyleDefault];
    [actionSheet showInView:self.view];
}

- (IBAction)prizesAction:(id)sender {
    PrizesViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"PrizesViewController"];
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
    return photoSamplerArray.count + 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.row ==0 ) {
        return 570;
    } else if(indexPath.row == photoSamplerArray.count+1){
        return 220;
    } else{
        return 370;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        static NSString *TutorialCellIdentifier = @"TutorialCell";
        TutorialTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TutorialCellIdentifier];
        
        //load italian video
        cell.itWebView.delegate = self;
        if(itVideoLoaded == NO){
            NSURL *itUrl = [NSURL URLWithString:@"http://www.deabyday.tv/oa/embed/fr/video?id=1437"];
            NSURLRequest *urlItRequest = [NSURLRequest requestWithURL:itUrl];
            [cell.itWebView loadRequest:urlItRequest];
            cell.itWebView.scrollView.bounces = NO;
            cell.itWebView.tag = 1;
        }
        
        //load english video
        cell.enWebView.delegate = self;
        if (enVideoLoaded == NO) {
            NSURL *enUrl = [NSURL URLWithString:@"http://www.youtube.com/embed/vbqIQcKNE7E"];
            NSURLRequest *urlEnRequest = [NSURLRequest requestWithURL:enUrl];
            [cell.enWebView loadRequest:urlEnRequest];
            cell.enWebView.scrollView.bounces = NO;
            cell.enWebView.tag = 2;
        }
        
        return cell;
        
    }else if (indexPath.row == photoSamplerArray.count+1) {
        static NSString *TutorialFooterCellIdentifier = @"TutorialFooterCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TutorialFooterCellIdentifier];
        
        return cell;
    }else{
        static NSString *PhotoSamplerCellIdentifier = @"PhotoSamplerCell";
        PhotoSamplerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PhotoSamplerCellIdentifier];
        
        PFObject *photoSampler = photoSamplerArray[indexPath.row - 1];
        PFFile *imageFile = photoSampler[@"image"];
        if (imageFile) {
            [cell.contentImageView setImageWithURL:[NSURL URLWithString:imageFile.url]];
        }
        
        cell.delegate = self;
        
        return cell;

    }
    
    return nil;
}


#pragma mark - Prizes Cell delegate methods -

- (void) deletePhoto:(PhotoSamplerTableViewCell *)cell{
    int index = [self.tableView indexPathForCell:cell].row - 1;
    selectedPhotoSampler = photoSamplerArray[index];
    
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
        [selectedPhotoSampler deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [self refreshPhotoSampler];
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
    
    PFObject *photoSampler = [PFObject objectWithClassName:@"PhotoSampler"];
    
    //Resize the image to be square
    UIImage *resizedImage = [Utils centerCropImage:[Utils resizeImage:image withMaxDimension:MAX_UPLOAD_PHOTO_WIDTH]];
    NSData *imageData = UIImageJPEGRepresentation(resizedImage, compressRate);
    PFFile *imageFile = [PFFile fileWithName:@"image.jpg" data:imageData];
    photoSampler[@"image"] = imageFile;
    [photoSampler saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if (succeeded) {
            
            NSLog(@"%@", @"Uploaded successfully");
            //            [MBProgressHUD showSuccess:LocalizedString(@"uploaded_successfully") toView:self.view];
            [self refreshPhotoSampler];
            
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


- (void) refreshPhotoSampler{
    if (refreshing) {
        return;
    }
    
    refreshing = TRUE;
    _refreshActivityIndicator.hidden = FALSE;
    [_refreshActivityIndicator startAnimating];
    _refreshButton.hidden = TRUE;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    PFQuery *query = [PFQuery queryWithClassName:@"PhotoSampler"];
    [query orderByAscending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects && !error) {
            [photoSamplerArray removeAllObjects];
            [photoSamplerArray addObjectsFromArray:objects];
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

#pragma mark - UIWebView delegate methods -

- (void) webViewDidFinishLoad:(UIWebView *)webView{
    if (webView.tag == 1) {
        itVideoLoaded = YES;
    } else if (webView.tag == 2){
        enVideoLoaded = YES;
    }
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
