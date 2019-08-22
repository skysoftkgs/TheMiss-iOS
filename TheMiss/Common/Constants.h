//
//  Constants.h
//  TheMiss
//
//  Created by lion on 6/19/14.
//  Copyright (c) 2014 Arsan. All rights reserved.
//

#import <Foundation/Foundation.h>

#define INSTAGRAM_CLIENT_ID @"4170a3d8782c4e02bb7d46e69b3c9644"
#define GOOGLE_ADS_ID @"ca-app-pub-2639229483569920/2062303293"

#define MAX_UPLOAD_PHOTO_WIDTH 800
#define MAIN_RED_COLOR 0xF0536B
#define LOGGEDIN @"loggedIn"

#define SELECT_HOME_LASTPICTURES 0
#define SELECT_HOME_MISSOFMONTH 1
#define SELECT_HOME_WINNERS 2

#define LIST_MODE 0
#define GRID_MODE 1

#define LOCAL_NOTIFICATION_DISPLAY_NOTIFICATION @"LocalNotification_DisplayNotification"
#define LOCAL_NOTIFICATION_INCREASE_SHARE_COUNT @"LocalNotification_IncreaseShareCount"

#define NOTIFICATION_KIND_VOTE @"vote"
#define NOTIFICATION_KIND_SHARE @"share"
#define NOTIFICATION_KIND_COMMENT @"comment"
#define NOTIFICATION_KIND_SHARE_SUCCESS @"share_success"
#define NOTIFICATION_KIND_NEW_POST @"post"

#define PARSE_QUERY_MAX_LIMIT_COUNT 10000000

@interface Constants : NSObject

@end
