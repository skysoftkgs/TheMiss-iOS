//
//  HomeCategoryTableViewCell.h
//  TheMiss
//
//  Created by lion on 6/20/14.
//  Copyright (c) 2014 Arsan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeCategoryTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIButton *lastPicturesButton;
@property (strong, nonatomic) IBOutlet UIButton *missOfMonthButton;
@property (strong, nonatomic) IBOutlet UIButton *theWinnersButton;
@property (strong, nonatomic) IBOutlet UIButton *listModeButton;
@property (strong, nonatomic) IBOutlet UIButton *gridModeButton;
@property (strong, nonatomic) IBOutlet UILabel *remainTimeLabel;
@property (strong, nonatomic) IBOutlet UIView *timeView;
@property (strong, nonatomic) IBOutlet UIView *displayModeView;
@property (weak, nonatomic) IBOutlet UILabel *monthLabel;

- (void) selectButton:(int) category;
- (void) selectMode:(int) mode;

@end
