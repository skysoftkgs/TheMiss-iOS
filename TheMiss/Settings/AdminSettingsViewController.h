//
//  AdminSettingsViewController.h
//  TheMiss
//
//  Created by lion on 8/9/14.
//  Copyright (c) 2014 Arsan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface AdminSettingsViewController : BaseViewController

@property (weak, nonatomic) IBOutlet UIButton *refreshButton;
@property (weak, nonatomic) IBOutlet UIButton *messageButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *refreshActivityIndicator;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

- (IBAction)backAction:(id)sender;
- (IBAction)messageAction:(id)sender;
- (IBAction)refreshAction:(id)sender;
- (IBAction)languageAction:(id)sender;

- (IBAction)saveAction:(id)sender;
- (IBAction)logoutAction:(id)sender;
@end
