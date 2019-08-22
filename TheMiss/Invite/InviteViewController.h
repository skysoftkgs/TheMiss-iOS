//
//  InviteViewController.h
//  TheMiss
//
//  Created by lion on 6/24/14.
//  Copyright (c) 2014 Arsan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface InviteViewController : BaseViewController
@property (strong, nonatomic) IBOutlet UIButton *loginButton;
@property (strong, nonatomic) IBOutlet UIButton *messageButton;
@property (strong, nonatomic) IBOutlet UIButton *plusButton;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;


- (IBAction)backAction:(id)sender;
- (IBAction)loginAction:(id)sender;
- (IBAction)messageAction:(id)sender;
@end
