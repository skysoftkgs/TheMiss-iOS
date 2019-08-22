//
//  HomeViewController.h
//  TheMiss
//
//  Created by lion on 6/19/14.
//  Copyright (c) 2014 Arsan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

BOOL refreshRequired;

@interface HomeViewController : BaseViewController

@property (strong, nonatomic) IBOutlet UIButton *plusButton;
@property (strong, nonatomic) IBOutlet UIButton *messageButton;
@property (strong, nonatomic) IBOutlet UIButton *refreshButton;
@property (strong, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UITableView *postTableView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *refreshActivityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic,retain) UIDocumentInteractionController *documentationInteractionController;

- (void) setLoginStatus;

- (IBAction)showLeftMenuAction:(id)sender;
- (IBAction)displayLastPicturesAction:(id)sender;
- (IBAction)displayMissOfMonthAction:(id)sender;
- (IBAction)displayWinnersAction:(id)sender;
- (IBAction)loginAction:(id)sender;
- (IBAction)listModeAction:(id)sender;
- (IBAction)gridModeAction:(id)sender;
- (IBAction)plusAction:(id)sender;
- (IBAction)refreshAction:(id)sender;
- (IBAction)messageAction:(id)sender;
- (IBAction)signupAction:(id)sender;
- (IBAction)closeHeaderAction:(id)sender;

- (IBAction)winnerSignupAction:(id)sender;

@end
