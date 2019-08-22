//
//  NotificationViewController.h
//  TheMiss
//
//  Created by lion on 8/21/14.
//  Copyright (c) 2014 Arsan. All rights reserved.
//

#import "BaseViewController.h"
#import "BaseViewController.h"

@interface NotificationViewController : BaseViewController
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *plusButton;
@property (weak, nonatomic) IBOutlet UIButton *messageButton;
@property (weak, nonatomic) IBOutlet UIButton *refreshButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *refreshActivityIndicator;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)backAction:(id)sender;
- (IBAction)plusAction:(id)sender;
- (IBAction)loginAction:(id)sender;
- (IBAction)refreshAction:(id)sender;
@end
