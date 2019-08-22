//
//  HomeMissOfMonthTableViewCell.h
//  TheMiss
//
//  Created by lion on 6/24/14.
//  Copyright (c) 2014 Arsan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GADBannerView.h"

@class HomeMissOfMonthTableViewCell;

@protocol HomeMissOfMonthCellDelegate <NSObject>

- (void) voteMissOfMonth:(HomeMissOfMonthTableViewCell*)cell;
- (void) shareMissOfMonth:(HomeMissOfMonthTableViewCell*)cell;
- (void) otherActionOfMissOfMonth:(HomeMissOfMonthTableViewCell*)cell;

@end

@interface HomeMissOfMonthTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *profileImageView;
@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *rankingLabel;
@property (strong, nonatomic) IBOutlet UILabel *voteCountLabel;
@property (strong, nonatomic) IBOutlet UILabel *shareCountLabel;
@property (strong, nonatomic) IBOutlet UIImageView *postImageView;
@property (strong, nonatomic) IBOutlet UILabel *allVoteCountLabel;
@property (strong, nonatomic) IBOutlet UIButton *voteButton;
@property (strong, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet GADBannerView *bannerView;

@property (weak, nonatomic) IBOutlet UILabel *winnerMonthLabel;

@property (nonatomic, strong) id<HomeMissOfMonthCellDelegate> delegate;

- (IBAction)voteAction:(id)sender;
- (IBAction)shareAction:(id)sender;
- (IBAction)otherAction:(id)sender;

@end
