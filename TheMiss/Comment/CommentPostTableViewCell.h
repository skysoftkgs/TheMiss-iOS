//
//  CommentPostTableViewCell.h
//  TheMiss
//
//  Created by lion on 7/12/14.
//  Copyright (c) 2014 Arsan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentPostTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *profileImageView;
@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UIImageView *postImageView;
@property (strong, nonatomic) IBOutlet UILabel *voteCountLabel;
@property (strong, nonatomic) IBOutlet UILabel *commentCountLabel;
@property (strong, nonatomic) IBOutlet UILabel *shareCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;
@property (weak, nonatomic) IBOutlet UIButton *voteButton;

@end
