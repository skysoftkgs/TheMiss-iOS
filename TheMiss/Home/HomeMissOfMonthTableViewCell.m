//
//  HomeMissOfMonthTableViewCell.m
//  TheMiss
//
//  Created by lion on 6/24/14.
//  Copyright (c) 2014 Arsan. All rights reserved.
//

#import "HomeMissOfMonthTableViewCell.h"

@implementation HomeMissOfMonthTableViewCell

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
    if ([self.delegate respondsToSelector:@selector(voteMissOfMonth:)]) {
        [self.delegate voteMissOfMonth:self];
    }
}

- (IBAction)shareAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(shareMissOfMonth:)]) {
        [self.delegate shareMissOfMonth:self];
    }
}

- (IBAction)otherAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(otherActionOfMissOfMonth:)]) {
        [self.delegate otherActionOfMissOfMonth:self];
    }

}
@end
