//
//  TutorialViewController.h
//  TheMiss
//
//  Created by lion on 8/8/14.
//  Copyright (c) 2014 Arsan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface TutorialViewController : BaseViewController

- (IBAction)backAction:(id)sender;
- (IBAction)loginAction:(id)sender;
- (IBAction)plusAction:(id)sender;
- (IBAction)messageAction:(id)sender;
- (IBAction)refreshAction:(id)sender;
- (IBAction)addPhotoAction:(id)sender;
- (IBAction)prizesAction:(id)sender;
- (IBAction)rulesAndPrivacyAction:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *addPhotoView;

@property (weak, nonatomic) IBOutlet UIButton *addPhotoButton;

@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *plusButton;
@property (weak, nonatomic) IBOutlet UIButton *messageButton;
@property (weak, nonatomic) IBOutlet UIButton *refreshButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *refreshActivityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@end
