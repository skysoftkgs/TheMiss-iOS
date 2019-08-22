//
//  SettingsViewController.h
//  TheMiss
//
//  Created by lion on 6/27/14.
//  Copyright (c) 2014 Arsan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "SZTextView.h"

@interface SettingsViewController : BaseViewController
@property (strong, nonatomic) IBOutlet UIButton *loginButton;
@property (strong, nonatomic) IBOutlet UIButton *messageButton;
@property (strong, nonatomic) IBOutlet UIButton *plusButton;

@property (strong, nonatomic) IBOutlet UIImageView *coverImageView;
@property (strong, nonatomic) IBOutlet UIImageView *profileImageView;
@property (strong, nonatomic) IBOutlet UITextField *userNameTextField;
@property (strong, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (strong, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (strong, nonatomic) IBOutlet UITextField *cityTextField;
@property (strong, nonatomic) IBOutlet UITextField *mobileNumberTextField;
@property (strong, nonatomic) IBOutlet SZTextView *descriptionTextView;
@property (strong, nonatomic) IBOutlet UITextField *emailTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UITextField *confirmPasswordTextField;
@property (strong, nonatomic) IBOutlet UIImageView *facebookLinkImageView;
@property (strong, nonatomic) IBOutlet UIImageView *instagramLinkImageView;
@property (strong, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIButton *languageButton;
@property (strong, nonatomic) IBOutlet UIButton *genderButton;
@property (strong, nonatomic) IBOutlet UIButton *deactivateButton;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIView *instagramView;
@property (assign, nonatomic) BOOL scrollToEnd;

- (IBAction)backAction:(id)sender;
- (IBAction)loginAction:(id)sender;
- (IBAction)messageAction:(id)sender;
- (IBAction)changeCoverPhotoAction:(id)sender;
- (IBAction)changeProfilePhotoAction:(id)sender;
- (IBAction)saveAction:(id)sender;
- (IBAction)logoutAction:(id)sender;
- (IBAction)deactivateAction:(id)sender;
- (IBAction)linkFacebookAction:(id)sender;
- (IBAction)linkInstagramAction:(id)sender;
- (IBAction)genderAction:(id)sender;
- (IBAction)languageAction:(id)sender;


@end
