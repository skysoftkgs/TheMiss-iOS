//
//  TutorialTableViewCell.m
//  TheMiss
//
//  Created by lion on 8/8/14.
//  Copyright (c) 2014 Arsan. All rights reserved.
//

#import "TutorialTableViewCell.h"

@implementation TutorialTableViewCell

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

@end
