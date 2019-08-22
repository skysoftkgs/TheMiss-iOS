//
//  HomeLastPicturesTableViewCell.h
//  TheMiss
//
//  Created by lion on 6/20/14.
//  Copyright (c) 2014 Arsan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GADBannerView.h"

@class HomeLastPicturesTableViewCell;

@protocol HomeLastPicturesCellDelegate <NSObject>

- (void) voteLastPictures:(HomeLastPicturesTableViewCell*)cell;
- (void) shareLastPictures:(HomeLastPicturesTableViewCell*)cell;
- (void) otherActionOfLastPictures:(HomeLastPicturesTableViewCell*)cell;

@end

@interface HomeLastPicturesTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *postTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *profileImageView;
@property (strong, nonatomic) IBOutlet UIImageView *postImageView;
@property (strong, nonatomic) IBOutlet UILabel *voteCountLabel;
@property (strong, nonatomic) IBOutlet UILabel *shareCountLabel;
@property (strong, nonatomic) IBOutlet UIButton *voteButton;
@property (strong, nonatomic) IBOutlet UIButton *shareButton;
@property (strong, nonatomic) IBOutlet UIProgressView *progressView;

@property (weak, nonatomic) IBOutlet GADBannerView *bannerView;


@property (nonatomic, strong) id<HomeLastPicturesCellDelegate> delegate;

- (IBAction)voteAction:(id)sender;
- (IBAction)shareAction:(id)sender;
- (IBAction)otherAction:(id)sender;


@end
