//
//  LoginViewController.h
//  TheMiss
//
//  Created by lion on 6/22/14.
//  Copyright (c) 2014 Arsan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController

//- (void) loginWithFacebook:(UIView *) view;

- (IBAction)backAction:(id)sender;
- (IBAction)loginWithFacebookAction:(id)sender;
//+ (LoginViewController *)sharedInstance;

+ (void) loginWithFacebook:(UIView *) view;
@end
