//
//  CommentViewController.h
//  TheMiss
//
//  Created by lion on 7/12/14.
//  Copyright (c) 2014 Arsan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface CommentViewController : BaseViewController

//@property (nonatomic, strong) NSDictionary *postDic;
@property (nonatomic, strong) PFObject *post;
@property (nonatomic, strong) PFUser *profileUser;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIButton *loginButton;
@property (strong, nonatomic) IBOutlet UIButton *refreshButton;
@property (strong, nonatomic) IBOutlet UIButton *messageButton;
@property (strong, nonatomic) IBOutlet UIButton *plusButton;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

- (IBAction)backAction:(id)sender;
- (IBAction)loginAction:(id)sender;
- (IBAction)refreshAction:(id)sender;
- (IBAction)messageAction:(id)sender;
- (IBAction)plusAction:(id)sender;
- (IBAction)voteAction:(id)sender;
- (IBAction)shareAction:(id)sender;

@end
