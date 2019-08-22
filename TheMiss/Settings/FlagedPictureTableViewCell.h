//
//  FlagedPictureTableViewCell.h
//  TheMiss
//
//  Created by lion on 8/9/14.
//  Copyright (c) 2014 Arsan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FlagedPictureTableViewCell;

@protocol FlagedPictureCellDelegate <NSObject>

- (void) deletePhoto:(FlagedPictureTableViewCell*)cell;

@end


@interface FlagedPictureTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *contentImageView;
@property (nonatomic, strong) id<FlagedPictureCellDelegate> delegate;

- (IBAction)deleteAction:(id)sender;
@end
