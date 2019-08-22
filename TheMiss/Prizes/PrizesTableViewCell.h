//
//  PrizesTableViewCell.h
//  TheMiss
//
//  Created by lion on 8/8/14.
//  Copyright (c) 2014 Arsan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PrizesTableViewCell;

@protocol PrizeCellDelegate <NSObject>

- (void) deletePhoto:(PrizesTableViewCell*)cell;

@end

@interface PrizesTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *contentImageView;
@property (weak, nonatomic) IBOutlet UIView *deleteView;
@property (nonatomic, strong) id<PrizeCellDelegate> delegate;
- (IBAction)deleteAction:(id)sender;

@end
