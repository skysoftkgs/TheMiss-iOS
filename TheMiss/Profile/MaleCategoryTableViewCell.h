//
//  MaleCategoryTableViewCell.h
//  TheMiss
//
//  Created by lion on 7/7/14.
//  Copyright (c) 2014 Arsan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MaleCategoryTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *voteView;
@property (weak, nonatomic) IBOutlet UIView *followerView;

@property (weak, nonatomic) IBOutlet UILabel *voteCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *followerCountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *voteImageView;
@property (weak, nonatomic) IBOutlet UIImageView *followerImageView;
@property (weak, nonatomic) IBOutlet UILabel *voteLabel;
@property (weak, nonatomic) IBOutlet UILabel *followerLabel;
@end
