//
//  PostTableViewCell.m
//  TheMiss
//
//  Created by lion on 7/7/14.
//  Copyright (c) 2014 Arsan. All rights reserved.
//

#import "PostTableViewCell.h"

@implementation PostTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)voteAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(votePost:)]) {
        [self.delegate votePost:self];
    }
}

- (IBAction)commentAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(commentPost:)]) {
        [self.delegate commentPost:self];
    }
}

- (IBAction)shareAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(sharePost:)]) {
        [self.delegate sharePost:self];
    }
}

- (IBAction)otherAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(otherPost:)]) {
        [self.delegate otherPost:self];
    }
}

@end
