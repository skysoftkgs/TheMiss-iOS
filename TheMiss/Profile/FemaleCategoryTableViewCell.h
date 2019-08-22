//
//  FemaleCategoryTableViewCell.h
//  TheMiss
//
//  Created by lion on 7/7/14.
//  Copyright (c) 2014 Arsan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FemaleCategoryTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *selfieImageView;
@property (strong, nonatomic) IBOutlet UIImageView *followersImageView;
@property (strong, nonatomic) IBOutlet UILabel *selfieCountLabel;
@property (strong, nonatomic) IBOutlet UILabel *selfieLabel;
@property (strong, nonatomic) IBOutlet UILabel *followersCountLabel;
@property (strong, nonatomic) IBOutlet UILabel *followersLabel;
@property (strong, nonatomic) IBOutlet UIView *selfieView;
@property (strong, nonatomic) IBOutlet UIView *followersView;
@end
