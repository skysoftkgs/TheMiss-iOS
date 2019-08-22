//
//  PostModel.h
//  The Miss
//
//  Created by lion on 11/18/14.
//  Copyright (c) 2014 Arsan. All rights reserved.
//

#import <Parse/Parse.h>

@interface PostModel : PFObject<PFSubclassing>
+ (NSString*)parseClassName;

@property (retain) PFFile* image;
@property (retain) PFUser* user;
@property int shareCount;
@property (retain) NSMutableArray* voteUsers;
@property (retain) NSMutableArray* commentUsers;
@property int totalActionCount;
@property (retain) PFFile* thumbnail;


@end
