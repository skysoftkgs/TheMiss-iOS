//
//  AppManager.h
//  TheMiss
//
//  Created by lion on 8/22/14.
//  Copyright (c) 2014 Arsan. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface AppManager : NSObject

@property (assign, nonatomic) int messageCount;
@property (assign, nonatomic) BOOL headerHidden;
@property (strong, nonatomic) PFObject* winnerPost;

+(AppManager *) sharedInstance;
- (BOOL) isFemale:(PFUser*)user;
- (BOOL) isLogedIn;
@end
