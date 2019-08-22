//
//  HomeLastPicturesTableViewCell.m
//  TheMiss
//
//  Created by lion on 6/20/14.
//  Copyright (c) 2014 Arsan. All rights reserved.
//

#import "HomeLastPicturesTableViewCell.h"
#import "Constants.h"

@implementation HomeLastPicturesTableViewCell

- (void)awakeFromNib
{
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)voteAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(voteLastPictures:)]) {
        [self.delegate voteLastPictures:self];
    }
}

- (IBAction)shareAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(shareLastPictures:)]) {
        [self.delegate shareLastPictures:self];
    }

}

- (IBAction)otherAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(otherActionOfLastPictures:)]) {
        [self.delegate otherActionOfLastPictures:self];
    }
}

@end
