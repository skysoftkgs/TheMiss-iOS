//
//  PostModel.m
//  The Miss
//
//  Created by lion on 11/18/14.
//  Copyright (c) 2014 Arsan. All rights reserved.
//

#import "PostModel.h"
#import <Parse/PFObject+Subclass.h>

@implementation PostModel

@dynamic image;
@dynamic user;
@dynamic shareCount;
@dynamic voteUsers;
@dynamic commentUsers;
@dynamic totalActionCount;
@dynamic thumbnail;

+ (void) load{
    [self registerSubclass];
}

+ (NSString*) parseClassName{
    return @"Post";
}

@end
