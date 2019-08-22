//
//  MailSignupViewController.h
//  TheMiss
//
//  Created by lion on 6/23/14.
//  Copyright (c) 2014 Arsan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RadioButton.h"
#import "TPKeyboardAvoidingScrollView.h"

@interface MailSignupViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITextField *userNameTextField;
@property (strong, nonatomic) IBOutlet UITextField *emailTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UITextField *confirmPasswordTextField;

@property (strong, nonatomic) IBOutlet UIButton *femaleButton;
@property (strong, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *scrollView;


- (IBAction)backAction:(id)sender;
- (IBAction)signupAction:(id)sender;
- (IBAction)loginAction:(id)sender;
- (IBAction)loginWithFacebookAction:(id)sender;

@end
