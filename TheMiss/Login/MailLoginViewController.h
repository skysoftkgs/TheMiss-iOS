//
//  MailLoginViewController.h
//  TheMiss
//
//  Created by lion on 6/23/14.
//  Copyright (c) 2014 Arsan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPKeyboardAvoidingScrollView.h"

@interface MailLoginViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITextField *emailTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;

@property (strong, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *scrollView;

- (IBAction)loginWithEmailAction:(id)sender;
- (IBAction)loginWithFacebookAction:(id)sender;
- (IBAction)backAction:(id)sender;

@end
