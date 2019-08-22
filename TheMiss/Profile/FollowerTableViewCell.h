//
//  FollowerTableViewCell.h
//  TheMiss
//
//  Created by lion on 7/7/14.
//  Copyright (c) 2014 Arsan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FollowerTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *profileImageView;
@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *rankingLabel;
@property (strong, nonatomic) IBOutlet UILabel *voteCountLabel;
@end
