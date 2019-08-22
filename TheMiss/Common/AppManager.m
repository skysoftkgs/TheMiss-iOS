//
//  AppManager.m
//  TheMiss
//
//  Created by lion on 8/22/14.
//  Copyright (c) 2014 Arsan. All rights reserved.
//

#import "AppManager.h"
#import "Constants.h"

@implementation AppManager

+ (AppManager*) sharedInstance
{
    static dispatch_once_t p = 0;
    __strong static id _sharedObject = nil;
    
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] init];
    });
    
    return _sharedObject;
}

- (BOOL) isFemale:(PFUser*)user{
    if(user[@"gender"] && [[user[@"gender"] lowercaseString] isEqualToString:@"female"])
        return YES;
    else
        return NO;
}

- (BOOL) isLogedIn{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:LOGGEDIN])
        return YES;
    else
        return NO;
}

@end
