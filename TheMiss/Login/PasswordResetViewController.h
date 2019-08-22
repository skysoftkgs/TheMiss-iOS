//
//  PasswordResetViewController.h
//  TheMiss
//
//  Created by lion on 6/24/14.
//  Copyright (c) 2014 Arsan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPKeyboardAvoidingScrollView.h"

@interface PasswordResetViewController : UIViewController
@property (strong, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UITextField *emailTextField;
- (IBAction)sendAction:(id)sender;
- (IBAction)loginWithFacebookAction:(id)sender;
- (IBAction)backAction:(id)sender;
- (IBAction)cancelAction:(id)sender;

@end
