//
//  ImportInsideTableViewController.m
//  TheMiss
//
//  Created by lion on 6/24/14.
//  Copyright (c) 2014 Arsan. All rights reserved.
//

#import "HomeViewController.h"
#import "ImportViewController.h"
#import "ImportInsideTableViewController.h"
#import "ImportFacebookTableViewCell.h"
#import "SettingsViewController.h"
#import "Utils.h"
#import "Constants.h"
#import "FacebookAlbumPicker.h"
#import "InstagramImagePikcerViewController.h"

extern BOOL refreshRequired;

@interface ImportInsideTableViewController ()<UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{

}
@property (nonatomic, assign) UIBackgroundTaskIdentifier fileUploadBackgroundTaskId;
@end

@implementation ImportInsideTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void) viewWillAppear:(BOOL)animated{
    FBSession *session = [FBSession activeSession];
    PFUser *currentUser = [PFUser currentUser];
    
    if (currentUser[@"facebookID"] && session && [session isOpen]) {
        _connectedLabel.text = [NSString stringWithFormat:@"%@ %@", LocalizedString(@"connected_as"), currentUser.username ];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    
//    switch (indexPath.section) {
//        case 0:
//        {
//            ImportFacebookTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ImportFacebookTableViewCell" forIndexPath:indexPath];
//            cell.c
//            return cell;
//            break;
//        }
//        default:
//            break;
//    }
//    
//    return nil;
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFUser *currentUser = [PFUser currentUser];
	switch (indexPath.section)
	{
		case 0:    //Facebook
        {
            FBSession *session = [FBSession activeSession];
            if (!currentUser[@"facebookID"] || !session || ![session isOpen]) {
                SettingsViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingsViewController"];
                vc.scrollToEnd = TRUE;
                [self.navigationController pushViewController:vc animated:YES];
                return;
            }
            
			FacebookAlbumPicker *objPicker = [[FacebookAlbumPicker alloc] initWithNibName:@"FacebookAlbumPicker" bundle:nil];
            [self.navigationController pushViewController:objPicker animated:YES];
            break;
        }
        case 1:    //Instagram
        {
            if (!currentUser[@"instagramID"]) {
                SettingsViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingsViewController"];
                vc.scrollToEnd = TRUE;
                [self.navigationController pushViewController:vc animated:YES];
                return;
            }
            
			InstagramImagePikcerViewController *instagramPicker = [[InstagramImagePikcerViewController alloc] initWithNibName:@"InstagramImagePikcerViewController" bundle:nil];
            [self.navigationController pushViewController:instagramPicker animated:YES];
 			break;
        }
        case 2:    //Camera
			NSLog(@"Select Image");
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle: LocalizedString(@"select_image") delegate:self cancelButtonTitle:LocalizedString(@"cancel") destructiveButtonTitle:nil otherButtonTitles:LocalizedString(@"from_album"), LocalizedString(@"from_camera"), nil];
            [actionSheet setActionSheetStyle:UIActionSheetStyleDefault];
            [actionSheet showInView:self.view];
 			break;
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
    
    [MBProgressHUD showMessag:LocalizedString(@"uploading") toView:self.parentViewController.view];
    
    PFObject *post = [PFObject objectWithClassName:@"Post"];
    PFUser *currentUser = [PFUser currentUser];
    
    post[@"user"] = currentUser;

    //Resize the image to be square
    UIImage *resizedImage = [Utils centerCropImage:[Utils resizeImage:image withMaxDimension:MAX_UPLOAD_PHOTO_WIDTH]];
    NSData *imageData = UIImageJPEGRepresentation(resizedImage, compressRate);
    PFFile *imageFile = [PFFile fileWithName:@"image.jpg" data:imageData];
    post[@"image"] = imageFile;
    [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.parentViewController.view animated:YES];
        if (succeeded) {
            
            NSLog(@"%@", @"Posted successfully");
            [MBProgressHUD showSuccess:LocalizedString(@"uploaded_successfully") toView:self.parentViewController.view];
            
            refreshRequired = TRUE;
            HomeViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"];
            [[SlideNavigationController sharedInstance] popAllAndSwitchToViewController:vc withCompletion:nil];
            
            [vc sendNotification:post kind:NOTIFICATION_KIND_NEW_POST];
            
        }else{
            
            [Utils showError:self content:@"Server error"];
        }
        
//        [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
    }];

    // Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
//    self.fileUploadBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
//        [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
//    }];

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

@end
