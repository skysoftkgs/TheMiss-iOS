//
//  FemaleInfoTableViewCell.h
//  TheMiss
//
//  Created by lion on 7/5/14.
//  Copyright (c) 2014 Arsan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FemaleInfoTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *monthLabel;
@property (strong, nonatomic) IBOutlet UILabel *positionNoLabel;
@property (strong, nonatomic) IBOutlet UILabel *positionCountLabel;
@property (strong, nonatomic) IBOutlet UILabel *yearVotesCountLabel;
@property (strong, nonatomic) IBOutlet UILabel *yearPhotosLabel;
@property (strong, nonatomic) IBOutlet UILabel *yearLabel;
@property (strong, nonatomic) IBOutlet UILabel *monthVotesLabel;
@property (strong, nonatomic) IBOutlet UILabel *monthPhotosLabel;

@end
