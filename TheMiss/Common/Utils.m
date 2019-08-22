//
//  Utils.m
//  Kaiser
//
//  Created by lion on 4/24/14.
//  Copyright (c) 2014 Wang. All rights reserved.
//

#import "Utils.h"
#import "MissOfMonthModel.h"

@implementation Utils

+ (void)showError:(id)delegate content:(NSString *)message
{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:delegate cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    
    [alertView show];
}

//+(UIColor*)colorFromHexString:(NSString *)hexString
//{
//    unsigned colorInt = 0;
//    [[NSScanner scannerWithString:hexString] scanHexInt:&colorInt];
//    return UIColorFromRGB(colorInt);
//}
//
+ (void) setRoundView:(UIView *)view borderColor:(UIColor *)color
{
    view.layer.cornerRadius = roundf(view.frame.size.height/2.0f);
    view.layer.masksToBounds = YES;
    
    CALayer *borderLayer = [CALayer layer];
    CGRect borderFrame = CGRectMake(0, 0, (view.frame.size.width), (view.frame.size.height));
    [borderLayer setBackgroundColor:[[UIColor clearColor] CGColor]];
    [borderLayer setFrame:borderFrame];
    [borderLayer setCornerRadius:view.frame.size.width / 2];
    [borderLayer setBorderWidth:1];
    [borderLayer setBorderColor:color.CGColor];
    [view.layer addSublayer:borderLayer];
}
//
//+ (NSArray *)sortData:(NSArray *)data {
//    
//    NSArray *sortedArray;
//    
//    sortedArray = [data sortedArrayUsingComparator:^NSComparisonResult(PFObject *obj1, PFObject  *obj2) {
//        NSDate *first = obj1.createdAt;
//        NSDate *second = obj2.createdAt;
//        return [second compare:first];
//    }];
//    return sortedArray;
//}
//
+(CGFloat)heightOfTextForString:(NSString *)aString andFont:(UIFont *)aFont maxSize:(CGSize)aSize
{
    // iOS7
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        CGSize sizeOfText = [aString boundingRectWithSize: aSize
                                                  options: (NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                               attributes: [NSDictionary dictionaryWithObject:aFont
                                                                                       forKey:NSFontAttributeName]
                                                  context: nil].size;
        
        return ceilf(sizeOfText.height);
    }
    
    // iOS6
    CGSize textSize = [aString sizeWithFont:aFont
                          constrainedToSize:aSize
                              lineBreakMode:NSLineBreakByWordWrapping];
    return ceilf(textSize.height);
}

+ (NSDate*) setMonth:(int) monthNumber{
    NSDate *today = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorian components:(NSEraCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit) fromDate:today];
    components.month = monthNumber;
    components.day = 1;
    components.hour = 0;
    components.minute = 0;
    components.second = 0;
    
    return [gregorian dateFromComponents:components];
}


+ (NSDate*) getFirstDayOfYear{
    NSDate *today = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorian components:(NSEraCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit) fromDate:today];
    components.month = 0;
    components.day = 1;
    components.hour = 0;
    components.minute = 0;
    components.second = 0;
    
    return [gregorian dateFromComponents:components];
}

+ (NSDate*) getFirstDayOfMonth{
    NSDate *today = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorian components:(NSEraCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit) fromDate:today];
    components.day = 1;
    components.hour = 0;
    components.minute = 0;
    components.second = 0;
    
    return [gregorian dateFromComponents:components];
}

+ (NSDate*) getFirstDayOfPrevMonth{
    NSDate *today = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorian components:(NSEraCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit) fromDate:today];
    components.month = components.month - 1;
    components.day = 1;
    components.hour = 0;
    components.minute = 0;
    components.second = 0;
    
    return [gregorian dateFromComponents:components];
}

+ (NSDate*) getLastDayOfMonth{
    NSDate *today = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorian components:(NSEraCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit) fromDate:today];
    NSInteger month = [components month];
    NSInteger year = [components year];
    
    if(month == 12){
        [components setYear:year + 1];
        [components setMonth:1];
    }else{
        [components setMonth:month + 1];
    }
    [components setDay:1];
    components.hour = 0;
    components.minute = 0;
    components.second = 0;
    
    return [[gregorian dateFromComponents:components] dateByAddingTimeInterval:-1];
}

+ (NSString*)getMonthName:(int) monthNumber{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    PFUser *currentUser = [PFUser currentUser];
    NSString *language = currentUser[@"language"];
    if (language && [[language uppercaseString] isEqualToString:@"ITALIAN"] ) {
        [df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"it_IT"]];
    }else{
        [df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    }
    NSString *monthName = [[df monthSymbols] objectAtIndex:(monthNumber-1)];
    return [monthName capitalizedString];
}

+ (BOOL)checkInputValue:(UITextField *)tf fieldName:(NSString *)fieldName{
    if (!tf.text || tf.text.length <= 0) {
        [self showError:nil content:[fieldName stringByAppendingString:LocalizedString(@"cant_be_empty")]];
        return FALSE;
    }
    return TRUE;
}

+ (UIImage *)resizeImage:(UIImage *)image withMaxDimension:(CGFloat)maxDimension
{
    UIImage *newImage = [UIImage imageWithCGImage:image.CGImage scale:1.0 orientation:image.imageOrientation];
    
    if (fmax(newImage.size.width, newImage.size.height) <= maxDimension) {
        return newImage;
    }
    
    CGFloat aspect = newImage.size.width / newImage.size.height;
    CGSize newSize;
    
    if (newImage.size.width > newImage.size.height) {
        newSize = CGSizeMake(maxDimension, maxDimension / aspect);
    } else {
        newSize = CGSizeMake(maxDimension * aspect, maxDimension);
    }
    
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 1.0);
    CGRect newImageRect = CGRectMake(0.0, 0.0, newSize.width, newSize.height);
    [newImage drawInRect:newImageRect];
    UIImage *returnImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return returnImage;
}

+ (UIImage *)centerCropImage:(UIImage *)image
{
    // Use smallest side length as crop square length
    CGFloat squareLength = MIN(image.size.width, image.size.height);
    // Center the crop area
    CGRect clippedRect = CGRectMake((image.size.width - squareLength) / 2, (image.size.height - squareLength) / 2, squareLength, squareLength);
    
    // Crop logic
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], clippedRect);
    UIImage * croppedImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return croppedImage;
}

+ (UIImage*) resizeImage:(UIImage*)image scaledToSize:(CGSize)newSize{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (int) getIndexOfMissMonth:(NSMutableArray*) missOfMonthArray object:(PFObject*)object{
    
    if(!missOfMonthArray || !object) return -1;
    
    for(int i=0;i<missOfMonthArray.count;i++){
        MissOfMonthModel *model = missOfMonthArray[i];
        
        if(!model.post[@"user"]) continue;
        
        PFUser *user1 = object[@"user"];
        PFUser *user2 = model.post[@"user"];
        if ([user1.objectId isEqualToString:user2.objectId]) {
            return i;
        }
            
    }
    return -1;
}

+ (int) getIndexOfObject:(NSMutableArray*) usersArray user:(PFUser*)user{
    
    if(!usersArray || !user) return -1;
    
    for(int i=0;i<usersArray.count;i++){
        if(!usersArray[i][@"user"]) continue;
        
        PFUser *tmpUser = usersArray[i][@"user"];
        if([user.objectId isEqualToString:tmpUser.objectId]) return i;
        
    }
    return -1;
}

+ (BOOL) containUser:(NSMutableArray *)userList user:(PFUser*)user{
    for (int i=0; i<userList.count; i++) {
        PFUser *tmpUser = userList[i];
        if ([tmpUser.objectId isEqualToString:user.objectId]) {
            return TRUE;
        }
    }
    return FALSE;
}

+ (void) addObject:(NSString*)object list:(NSMutableArray*)list{
    if (![list containsObject:object]) {
        [list addObject:object];
    }
}

+ (NSMutableArray*)removeUser:(PFUser*) user idList:(NSMutableArray*)list{
    for (int i=0; i<list.count; i++) {
        if ([list[i] isEqualToString:user.objectId]) {
            [list removeObject:user.objectId];
        }
    }
    
    return list;
}

@end
