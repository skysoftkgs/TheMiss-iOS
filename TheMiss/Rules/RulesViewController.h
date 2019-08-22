//
//  RulesViewController.h
//  TheMiss
//
//  Created by lion on 8/8/14.
//  Copyright (c) 2014 Arsan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface RulesViewController : BaseViewController
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *refreshButton;
@property (weak, nonatomic) IBOutlet UIButton *messageButton;
@property (weak, nonatomic) IBOutlet UIButton *plusButton;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

- (IBAction)backAction:(id)sender;
- (IBAction)loginAction:(id)sender;
- (IBAction)messageAction:(id)sender;
- (IBAction)plusAction:(id)sender;
- (IBAction)prizesAction:(id)sender;
- (IBAction)tutorialAction:(id)sender;
- (IBAction)privacyAction:(id)sender;

@end
