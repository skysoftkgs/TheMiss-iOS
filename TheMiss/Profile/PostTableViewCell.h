//
//  PostTableViewCell.h
//  TheMiss
//
//  Created by lion on 7/7/14.
//  Copyright (c) 2014 Arsan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GADBannerView.h"

@class PostTableViewCell;

@protocol ProfilePostCellDelegate <NSObject>

- (void) votePost:(PostTableViewCell*)cell;
- (void) sharePost:(PostTableViewCell*)cell;
- (void) commentPost:(PostTableViewCell*)cell;
- (void) otherPost:(PostTableViewCell*)cell;

@end

@interface PostTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *profileImageView;
@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UIImageView *postImageView;
@property (strong, nonatomic) IBOutlet UILabel *voteCountLabel;
@property (strong, nonatomic) IBOutlet UILabel *commentCountLabel;
@property (strong, nonatomic) IBOutlet UILabel *shareCountLabel;
@property (strong, nonatomic) IBOutlet UIButton *voteButton;
@property (strong, nonatomic) IBOutlet UIButton *commentButton;
@property (weak, nonatomic) IBOutlet GADBannerView *bannerView;


@property (nonatomic, strong) id<ProfilePostCellDelegate> delegate;

- (IBAction)voteAction:(id)sender;
- (IBAction)commentAction:(id)sender;
- (IBAction)shareAction:(id)sender;
- (IBAction)otherAction:(id)sender;

@end
