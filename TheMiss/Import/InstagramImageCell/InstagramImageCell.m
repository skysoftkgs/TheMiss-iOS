//
//  InstagramImageCell.m
//  The Miss
//
//  Created by karl on 12/12/14.
//  Copyright (c) 2014 Arsan. All rights reserved.
//

#import "InstagramImageCell.h"

@implementation InstagramImageCell

@synthesize imageView;

- (id)initWithFrame:(CGRect)aRect
{
    self = [super initWithFrame:aRect];
    {
        //we create the UIImageView in this overwritten init so that we always have it at hand.
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(1, 1, 79, 79)];
        //set specs and special wants for the imageView here.
        [self addSubview:imageView]; //the only place we want to do this addSubview: is here!
        
        //We can also prepare views with additional contents here!
        //just add more labels/views/whatever you want.
    }
    return self;
}

@end
