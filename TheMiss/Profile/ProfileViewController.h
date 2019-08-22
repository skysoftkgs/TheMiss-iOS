//
//  ProfileViewController.h
//  TheMiss
//
//  Created by lion on 7/5/14.
//  Copyright (c) 2014 Arsan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@class PFUser;

@interface ProfileViewController : BaseViewController
@property (strong, nonatomic) IBOutlet UIButton *backButton;
@property (strong, nonatomic) IBOutlet UIButton *loginButton;
@property (strong, nonatomic) IBOutlet UIButton *refreshButton;
@property (strong, nonatomic) IBOutlet UIButton *messageButton;
@property (strong, nonatomic) IBOutlet UIButton *plusButton;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *refreshActivityIndicator;
@property (strong, nonatomic) PFUser *profileUser;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

- (IBAction)backAction:(id)sender;
- (IBAction)loginAction:(id)sender;
- (IBAction)refreshAction:(id)sender;
- (IBAction)messageAction:(id)sender;
- (IBAction)plusAction:(id)sender;
- (IBAction)followAction:(id)sender;

@end
