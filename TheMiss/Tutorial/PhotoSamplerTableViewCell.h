//
//  PhotoSamplerTableViewCell.h
//  TheMiss
//
//  Created by lion on 8/8/14.
//  Copyright (c) 2014 Arsan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PhotoSamplerTableViewCell;

@protocol PhotoSamplerCellDelegate <NSObject>

- (void) deletePhoto:(PhotoSamplerTableViewCell*)cell;

@end

@interface PhotoSamplerTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *contentImageView;

@property (nonatomic, strong) id<PhotoSamplerCellDelegate> delegate;
- (IBAction)deleteAction:(id)sender;

@end
