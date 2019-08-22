//
//  MissOfMonthModel.h
//  The Miss
//
//  Created by lion on 10/18/14.
//  Copyright (c) 2014 Arsan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MissOfMonthModel : NSObject

@property (nonatomic, assign) int totalVoteCount;
@property (nonatomic, strong) PFObject *post;

@end
