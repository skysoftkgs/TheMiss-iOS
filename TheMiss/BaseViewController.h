//
//  BaseViewController.h
//  TheMiss
//
//  Created by lion on 6/22/14.
//  Copyright (c) 2014 Arsan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController<SlideNavigationControllerDelegate>

#define ACTIONSHEET_REPORT_INAPPROPRIATE 0
#define ACTIONSHEET_DELETE 1
#define ACTIONSHEET_SHARE 2

@property(nonatomic,retain) UIDocumentInteractionController *documentationInteractionController;

- (void) plusMenuButtonAction;
- (void) loginMenuButtonAction;
- (void) messageMenuButtonAction;
- (void) openMenuAction;

- (void) displayNotification:(NSNotification*) notification;
- (void) displayNotificationWithQuery:(UILabel*) messageLabel;
- (void) displayNotificationWithoutQuery:(UILabel*) messageLabel;
- (void) sendNotification:(PFObject*)post kind:(NSString*) kind;
- (void)sendFollowingNotification:(PFUser*) fromUser toUser:(PFUser*) toUser;
- (void)sendFlagNotification;
- (void)sendNewUserSignupNotification;

- (void) shareWithFacebook:(FBSession*)session
                   message:(NSString*)message
                  imageUrl:(NSString*)imageUrl
                  userName:(NSString*)userName;
- (void) shareWithWhatsapp:(NSString*)imageUrl;
@end
