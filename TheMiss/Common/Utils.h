//
//  Utils.h
//  Kaiser
//
//  Created by lion on 4/24/14.
//  Copyright (c) 2014 Wang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PFUser;

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface Utils : NSObject

+ (void)showError:(id)delegate content:(NSString *)message;
+ (BOOL)checkInputValue:(UITextField *)tf fieldName:(NSString *)fieldName;
//+ (UIColor*)colorFromHexString:(NSString *)hexString;
+ (void) setRoundView:(UIView *)view borderColor:(UIColor *)color;
//+ (NSArray *)sortData:(NSArray *)data;
+ (CGFloat)heightOfTextForString:(NSString *)aString andFont:(UIFont *)aFont maxSize:(CGSize)aSize;
+ (UIImage *)resizeImage:(UIImage *)image withMaxDimension:(CGFloat)maxDimension;
+ (UIImage *)centerCropImage:(UIImage *)image;
+ (UIImage*) resizeImage:(UIImage*)image scaledToSize:(CGSize)newSize;
+ (NSDate*) setMonth:(int) monthNumber;
+ (NSDate*) getFirstDayOfPrevMonth;
+ (NSDate*) getFirstDayOfMonth;
+ (NSDate*) getLastDayOfMonth;
+ (NSDate*) getFirstDayOfYear;
+ (NSString*)getMonthName:(int) monthNumber;

+ (int) getIndexOfObject:(NSMutableArray*) usersArray user:(PFUser*)user;
+ (int) getIndexOfMissMonth:(NSMutableArray*) missOfMonthArray object:(PFObject*)object;
+ (BOOL) containUser:(NSMutableArray *)userList user:(PFUser*)user;
+ (void) addObject:(NSString*)object list:(NSMutableArray*)list;
+ (NSMutableArray*)removeUser:(PFUser*) user idList:(NSMutableArray*)list;

@end
