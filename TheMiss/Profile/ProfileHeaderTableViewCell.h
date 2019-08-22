//
//  ProfileHeaderTableViewCell.h
//  TheMiss
//
//  Created by lion on 7/5/14.
//  Copyright (c) 2014 Arsan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileHeaderTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *coverImageView;
@property (strong, nonatomic) IBOutlet UIImageView *profileImageView;
@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;
@property (strong, nonatomic) IBOutlet UIButton *followButton;

@end
