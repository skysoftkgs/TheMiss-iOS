//
//  SettingsViewController.m
//  TheMiss
//
//  Created by lion on 6/27/14.
//  Copyright (c) 2014 Arsan. All rights reserved.
//

#import "SettingsViewController.h"
#import "Utils.h"
#import "Constants.h"
#import "IKLoginViewController.h"
#import "AppDelegate.h"
#import "HomeViewController.h"
#import "UIImageView+AFNetworking.h"
#import "UIImage+RoundedImage.h"
#import "LogoutViewController.h"
#import "DeactivateViewController.h"

#define COVER_SELECTED 0
#define PROFILE_SELECTED 1
#define GENDER_SELECTED 2
#define LANGUAGE_SELECTED 3

#define COVER_MAX_WIDTH 800
#define COVER_MAX_HEIGHT 300
#define PROFILE_MAX_WIDTH 300

extern BOOL refreshRequired;

@interface SettingsViewController ()<UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, IGLoginDelegate>
{
    int selectedCategory;
}
@end

@implementation SettingsViewController

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
    
    PFUser *currentUser = [PFUser currentUser];
    FBSession *session = [FBSession activeSession];
    if (currentUser[@"facebookID"] && session && [session isOpen]) {
        [_facebookLinkImageView setImage:[UIImage imageNamed:@"settings_link_checked.png"]];
    }else{
        [_facebookLinkImageView setImage:[UIImage imageNamed:@"settings_link_unchecked.png"]];
    }
    
    if (currentUser[@"instagramID"]) {
        [_instagramLinkImageView setImage:[UIImage imageNamed:@"settings_link_checked.png"]];
    }else{
        [_instagramLinkImageView setImage:[UIImage imageNamed:@"settings_link_unchecked.png"]];
    }
    
    [_scrollView setContentSize:CGSizeMake(320, 1650)];
    
    [self initDisplayUserData];
}

- (void)viewWillAppear:(BOOL)animated{
    PFUser *currentUser = [PFUser currentUser];
    if ([currentUser[@"deactive"] boolValue]== TRUE) {
        [_deactivateButton setTitle:LocalizedString(@"activate_account") forState:UIControlStateNormal];
    }else{
        [_deactivateButton setTitle:LocalizedString(@"deactivate_account") forState:UIControlStateNormal];
    }

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

#pragma mark - internal methods

- (void) initDisplayUserData{
    
    PFUser *currentUser = [PFUser currentUser];
    
    PFFile *coverImageFile = currentUser[@"coverImage"];
    _coverImageView.clipsToBounds = YES;
    [_coverImageView setImageWithURL:[NSURL URLWithString:coverImageFile.url] placeholderImage:[UIImage imageNamed:@"profile_picture_bg.png"]];
    
    PFFile *profileImageFile = currentUser[@"profileImage"];
    [_profileImageView setImageWithURL:[NSURL URLWithString:profileImageFile.url] placeholderImage:[UIImage imageNamed:@"user_female_256.png"]];
    _profileImageView.clipsToBounds = YES;
    [Utils setRoundView:_profileImageView borderColor:[UIColor clearColor]];
    
    _userNameTextField.text = currentUser.username;
    _emailTextField.text = currentUser.email;
    [_genderButton setTitle:currentUser[@"gender"] forState:UIControlStateNormal];
    _firstNameTextField.text = currentUser[@"firstName"];
    _lastNameTextField.text = currentUser[@"lastName"];
    _cityTextField.text = currentUser[@"city"];
    _mobileNumberTextField.text = currentUser[@"mobileNumber"];
    _descriptionTextView.placeholder = LocalizedString(@"description");
    _descriptionTextView.text = currentUser[@"description"];
    if (currentUser[@"language"]) {
        [_languageButton setTitle:currentUser[@"language"] forState:UIControlStateNormal];
    }else{
        [_languageButton setTitle:@"English" forState:UIControlStateNormal];
    }
    
    if(currentUser[@"gender"] && [currentUser[@"gender"] isEqualToString:@"male"])
        _instagramView.hidden = TRUE;
    
    if (_scrollToEnd) {
        CGPoint bottomOffeset = CGPointMake(0, _scrollView.contentSize.height - _scrollView.bounds.size.height);
        [_scrollView setContentOffset:bottomOffeset animated:YES];
    }
    
}

- (void) setLoginStatus{
    PFUser *currentUser = [PFUser currentUser];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:LOGGEDIN]){
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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    if ([segue.identifier isEqualToString:@"ShowInstagramLogin"]) {
//        IKLoginViewController *destinationView = (IKLoginViewController *)[segue destinationViewController];
//        destinationView.loginDelegate = self;
//        destinationView.loggingInWithInstagram = FALSE;
//    }
//}

#pragma mark - ViewController Actions

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)loginAction:(id)sender {
    [self loginMenuButtonAction];
}

- (IBAction)messageAction:(id)sender {
    [self messageMenuButtonAction];
}

- (IBAction)changeCoverPhotoAction:(id)sender {
    selectedCategory = COVER_SELECTED;
    [self showSelectImageDialog];
}

- (IBAction)changeProfilePhotoAction:(id)sender {
    selectedCategory = PROFILE_SELECTED;
    [self showSelectImageDialog];
}

- (IBAction)saveAction:(id)sender {
    //check if input value is valid
    if (![Utils checkInputValue:_userNameTextField fieldName:@"user_name"]) {
        return;
    }
    if (![_passwordTextField.text isEqualToString:_confirmPasswordTextField.text]) {
        [MBProgressHUD showError:LocalizedString(@"password_not_match") toView:self.view];
    }
    
    [_userNameTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
    [_firstNameTextField resignFirstResponder];
    [_lastNameTextField resignFirstResponder];
    [_cityTextField resignFirstResponder];
    [_mobileNumberTextField resignFirstResponder];
    [_descriptionTextView resignFirstResponder];
    
    [MBProgressHUD showMessag:LocalizedString(@"saving") toView:self.view];
    PFUser *currentUser = [PFUser currentUser];
    
    //save cover image
    UIImage *resizedImage = [Utils resizeImage:_coverImageView.image withMaxDimension:COVER_MAX_WIDTH];
    NSData *coverImageData = UIImageJPEGRepresentation(resizedImage, 0.6f);
    PFFile *coverImageFile = [PFFile fileWithName:@"coverImage.jpg" data:coverImageData];
    currentUser[@"coverImage"] = coverImageFile;
    
    //save profile image
    resizedImage = [Utils resizeImage:_profileImageView.image withMaxDimension:PROFILE_MAX_WIDTH];
    NSData *profileImageData = UIImageJPEGRepresentation(resizedImage, 0.6f);
    PFFile *profileImageFile = [PFFile fileWithName:@"profileImage.png" data:profileImageData];
    currentUser[@"profileImage"] = profileImageFile;
    
    currentUser.username = _userNameTextField.text;
    if (_passwordTextField.text.length>0) {
        currentUser.password = _passwordTextField.text;
    }
    currentUser.email = _emailTextField.text;
    
    [currentUser setObject:_genderButton.titleLabel.text forKey:@"gender"];
    [currentUser setObject:_firstNameTextField.text forKey:@"firstName"];
    [currentUser setObject:_lastNameTextField.text forKey:@"lastName"];
    [currentUser setObject:_cityTextField.text forKey:@"city"];
    [currentUser setObject:_mobileNumberTextField.text forKey:@"mobileNumber"];
    [currentUser setObject:_descriptionTextView.text forKey:@"description"];
    [currentUser setObject:_languageButton.titleLabel.text forKey:@"language"];
    
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

- (IBAction)deactivateAction:(id)sender {
    
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser[@"deactive"]) {
        [MBProgressHUD showMessag:LocalizedString(@"activating") toView:self.view];
        [currentUser removeObjectForKey:@"deactive"];
        [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [_deactivateButton setTitle:LocalizedString(@"deactivate_account") forState:UIControlStateNormal];
                refreshRequired = TRUE;
            }
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        }];
        
    }else{
        DeactivateViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"DeactivateViewController"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)linkFacebookAction:(id)sender {
    PFUser *currentUser = [PFUser currentUser];
    FBSession *session = [FBSession activeSession];
    if (currentUser[@"facebookID"] && session && [session isOpen]) {
        //if user loggedin with facebook, can't disconnect.
        NSString *logInWay = currentUser[@"loggedInWay"];
        if (!logInWay && [logInWay isEqualToString:@"facebook"]) {
            [Utils showError:nil content:LocalizedString(@"cant_disconnect_from_facebook")];
            return;
        }
        
        [currentUser removeObjectForKey:@"facebookID"];
        [MBProgressHUD showMessag:LocalizedString(@"unlinking") toView:self.view];
        
        if ([PFFacebookUtils isLinkedWithUser:currentUser]) {
            [PFFacebookUtils unlinkUser:currentUser];
        }
        
        if ([PFFacebookUtils session]) {
            [[PFFacebookUtils session] closeAndClearTokenInformation];
        }
        if ([FBSession activeSession]) {
            [[FBSession activeSession] closeAndClearTokenInformation];
        }
        
        [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            if (!error) {
                [_facebookLinkImageView setImage:[UIImage imageNamed:@"settings_link_unchecked"]];
            }
        }];
        
    }else{
        [self connectToFacebook];
    }

}

- (IBAction)linkInstagramAction:(id)sender {

    PFUser *currentUser = [PFUser currentUser];
    if (currentUser[@"instagramID"]) {
        //if user loggedin with facebook, can't disconnect.
        NSString *logInWay = currentUser[@"loggedInWay"];
        if (!logInWay && [logInWay isEqualToString:@"instagram"]) {
            [Utils showError:nil content:LocalizedString(@"cant_disconnect_from_instagram")];
            return;
        }
        
        [currentUser removeObjectForKey:@"instagramID"];
        [MBProgressHUD showMessag:LocalizedString(@"unlinking") toView:self.view];
        
        [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            if (!error) {
                [_instagramLinkImageView setImage:[UIImage imageNamed:@"settings_link_unchecked"]];
            }
        }];
    }else{
        IKLoginViewController *destinationView = (IKLoginViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"InstagramLogin"];
        destinationView.loginDelegate = self;
        destinationView.loggingInWithInstagram = FALSE;
        
        //remove web browser cookie
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        for(NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]){
            NSString *domainName = [cookie domain];
            NSRange domainRange = [domainName rangeOfString:@"instagram"];
            if (domainRange.length > 0) {
                [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
            }
        }
        
        [self.navigationController presentViewController:destinationView animated:YES completion:nil];

    }
}

- (IBAction)genderAction:(id)sender {
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser[@"gender"] && [currentUser[@"gender"] length]>0) {
        return;
    }
    
    selectedCategory = GENDER_SELECTED;
    
    NSLog(@"Select gender");
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle: nil delegate:self cancelButtonTitle:LocalizedString(@"cancel") destructiveButtonTitle:nil otherButtonTitles:LocalizedString(@"female"), LocalizedString(@"male"), nil];
    [actionSheet setActionSheetStyle:UIActionSheetStyleDefault];
    [actionSheet showInView:self.view];
}

- (IBAction)languageAction:(id)sender {
    selectedCategory = LANGUAGE_SELECTED;
    
    NSLog(@"Select language");
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle: nil delegate:self cancelButtonTitle:LocalizedString(@"cancel") destructiveButtonTitle:nil otherButtonTitles:LocalizedString(@"english"), LocalizedString(@"italian"), nil];
    [actionSheet setActionSheetStyle:UIActionSheetStyleDefault];
    [actionSheet showInView:self.view];
}

#pragma mark - UIActionSheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    [imagePicker setDelegate:self];
    [imagePicker setAllowsEditing:YES];
    
    switch (selectedCategory) {
        case COVER_SELECTED:
        case PROFILE_SELECTED:      //if clicking cover or profile button.
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
                    break;
            }

            break;
           
        case GENDER_SELECTED:
            switch (buttonIndex) {
                case 0:
                    [_genderButton setTitle:LocalizedString(@"female") forState:UIControlStateNormal];
                    break;
                    
                case 1:
                    [_genderButton setTitle:LocalizedString(@"male") forState:UIControlStateNormal];
                    break;

            }

            break;
            
        case LANGUAGE_SELECTED:
            switch (buttonIndex) {
                case 0:
                    [_languageButton setTitle:LocalizedString(@"english") forState:UIControlStateNormal];
                    break;
                    
                case 1:
                    [_languageButton setTitle:LocalizedString(@"italian") forState:UIControlStateNormal];
                    break;
                    
            }
            
            break;

    }
}

#pragma mark - UIImagePickerController delegate

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *selectedPhoto = info[UIImagePickerControllerEditedImage];
    if (selectedCategory == COVER_SELECTED) {
        _coverImageView.image = selectedPhoto;
    }else{
//        UIImage *resizedImage = [Utils centerCropImage:[Utils resizeImage:selectedPhoto withMaxDimension:PROFILE_MAX_WIDTH]];
        _profileImageView.image = selectedPhoto;
        
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void) showSelectImageDialog{
    NSLog(@"Select Image");
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle: LocalizedString(@"select_image") delegate:self cancelButtonTitle:LocalizedString(@"cancel") destructiveButtonTitle:nil otherButtonTitles:LocalizedString(@"from_album"), LocalizedString(@"from_camera"), nil];
    [actionSheet setActionSheetStyle:UIActionSheetStyleDefault];
    [actionSheet showInView:self.view];
}

- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState)state error:(NSError *)error
{
    // If the session was opened successfully
    if (!error && state == FBSessionStateOpen){
        NSLog(@"Session opened");
        // Show the user the logged-in UI
        [self facebookLoggedIn];
        return;
    }
    if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed){
        // If the session is closed
        NSLog(@"Session closed");
        // Show the user the logged-out UI
        [self facebookLoggedOut];
    }
    
    // Handle errors
    if (error){
        NSLog(@"Error");
        NSString *alertText;
        NSString *alertTitle;
        // If the error requires people using an app to make an action outside of the app in order to recover
        if ([FBErrorUtility shouldNotifyUserForError:error] == YES){
            alertTitle = @"Something went wrong";
            alertText = [FBErrorUtility userMessageForError:error];
            [Utils showError:nil content:alertText];
        } else {
            
            // If the user cancelled login, do nothing
            if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
                NSLog(@"User cancelled login");
                
                // Handle session closures that happen outside of the app
            } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession){
                alertTitle = @"Session Error";
                alertText = @"Your current session is no longer valid. Please log in again.";
                [Utils showError:nil content:alertText];
                
                // For simplicity, here we just show a generic message for all other errors
                // You can learn how to handle other errors using our guide: https://developers.facebook.com/docs/ios/errors
            } else {
                //Get more error information from the error
                NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
                
                // Show the user an error message
                alertTitle = @"Something went wrong";
                alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
                [Utils showError:nil content:alertText];
            }
        }
        // Clear this token
        [FBSession.activeSession closeAndClearTokenInformation];
        // Show the user the logged-out UI
        [self facebookLoggedOut];
    }
}

//login with Facebook
- (void)connectToFacebook{
    // Clear this token
    [FBSession.activeSession closeAndClearTokenInformation];
    [[PFFacebookUtils session] closeAndClearTokenInformation];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.facebookSeesionFromParse = FALSE;
    
    NSArray *permissionsArray = @[@"email", @"user_photos"];
    
    [FBSession openActiveSessionWithReadPermissions:permissionsArray
                                       allowLoginUI:YES
                                  completionHandler:
     ^(FBSession *session, FBSessionState state, NSError *error) {
         
         [self sessionStateChanged:session state:state error:error];
         
     }];
}

// Show the user the logged-out UI
- (void)facebookLoggedOut
{
    
}

// Show the user the logged-in UI
- (void)facebookLoggedIn
{
    [self linkWithFacebook];
}

- (void) linkWithFacebook{
   
    [MBProgressHUD showMessag:LocalizedString(@"linking") toView:self.view];
    
    NSString *requestPath = @"me/?fields=name,location,gender,birthday,relationship_status,first_name,last_name";
    
    FBRequest *request = [FBRequest requestForGraphPath:requestPath];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            // Success! Include your code to handle the results here
            NSLog(@"user info: %@", result);
            
            NSDictionary *userData = (NSDictionary *)result;
            NSString *fbUserID = userData[@"id"];
            PFUser *currentUser = [PFUser currentUser];
            [currentUser setObject:fbUserID forKey:@"facebookID"];
            [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                
                if (succeeded) {
                    [_facebookLinkImageView setImage:[UIImage imageNamed:@"settings_link_checked"]];
                    if (![PFFacebookUtils isLinkedWithUser:currentUser]) {
                        [PFFacebookUtils linkUser:currentUser permissions:nil block:^(BOOL succeeded, NSError *error) {
                            if (succeeded) {
                                NSLog(@"linked with Facebook!");
                            }
                        }];
                    }
                }else{
                    [_facebookLinkImageView setImage:[UIImage imageNamed:@"settings_link_unchecked"]];
                }
            }];
            
        } else {
            // An error occurred, we need to handle the error
            // See: https://developers.facebook.com/docs/ios/errors
            NSLog(@"Facebook user info request error: %@", error.description);
            
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        }
    }];
    
}

#pragma mark - IGWebViewDelegate

-(void)igDidLogin{
    
    [self dismissViewControllerAnimated:YES completion:^{
        [_instagramLinkImageView setImage:[UIImage imageNamed:@"settings_link_checked.png"]];
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
        [_instagramLinkImageView setImage:[UIImage imageNamed:@"settings_link_unchecked.png"]];
        [Utils showError:nil content:message];
        
    }];
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
