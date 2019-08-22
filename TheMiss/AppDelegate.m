//
//  AppDelegate.m
//  TheMiss
//
//  Created by lion on 6/19/14.
//  Copyright (c) 2014 Arsan. All rights reserved.
//

#import "AppDelegate.h"
#import "LeftMenuViewController.h"
#import "ProfileViewController.h"
#import "CommentViewController.h"
#import "InstagramKit.h"
#import "Constants.h"

#define FACEBOOK_SCHEME  @"fb1502622856621347"
#define INSTAGRAM_SCHEME  @"ig4170a3d8782c4e02bb7d46e69b3c9644"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone"
															 bundle: nil];
	
	LeftMenuViewController *leftMenu = (LeftMenuViewController*)[mainStoryboard
                                                                 instantiateViewControllerWithIdentifier: @"LeftMenuViewController"];
    
	[SlideNavigationController sharedInstance].leftMenu = leftMenu;

    // Parse initialization
    [Parse setApplicationId:@"0KdXHybrKxDaQcAioiZj9V5Ndz0jBF1GKLkpOnDg" clientKey:@"ADGvEBoPyA7rmFNXmfRIME47M3VKPdLAkpI7HX0V"];
    [PFFacebookUtils initializeFacebook];
    
    
    // Track app open.
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
//    if (application.applicationIconBadgeNumber != 0) {
//        application.applicationIconBadgeNumber = 0;
//        [[PFInstallation currentInstallation] saveInBackground];
//    }
    
    // Enable public read access by default, with any newly created PFObjects belonging to the current user
    [PFUser enableAutomaticUser];
    PFACL *defaultACL = [PFACL ACL];
    [defaultACL setPublicReadAccess:YES];
    [defaultACL setPublicWriteAccess:YES];
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
    
    
    // Register for Push Notitications, if running iOS 8
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                        UIUserNotificationTypeBadge |
                                                        UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                                 categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    } else {
        // Register for Push Notifications before iOS 8
        [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                         UIRemoteNotificationTypeAlert |
                                                         UIRemoteNotificationTypeSound)];
    }
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    NSLog(@"url scheme: %@", [url scheme]);
    
    if ([[url scheme] isEqualToString:FACEBOOK_SCHEME]){
        if (self.facebookSeesionFromParse == TRUE) {
            return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication withSession:[PFFacebookUtils session]];
        }else{
            return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication withSession:[FBSession activeSession]];
        }
    }
    
    if ([[url scheme] isEqualToString:INSTAGRAM_SCHEME]){
        return [[InstagramEngine sharedEngine] application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
    }
    
    return NO;
}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
//    currentInstallation.channels = @[@"global"];
    [currentInstallation saveInBackground];
    NSLog(@"My token is: %@", deviceToken);
    
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    [PFPush handlePush:userInfo];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:LOCAL_NOTIFICATION_DISPLAY_NOTIFICATION object:nil];
    
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateActive) {
        return;
    }
    
    NSString *intent = [userInfo objectForKey:@"intent"];
    if ([intent isEqualToString:@"ProfileFragment"]) {
        NSString *userId = [userInfo objectForKey:@"fromUser"];
        PFQuery *query = [PFUser query];
        [query whereKey:@"objectId" equalTo:userId];
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if (object) {
                PFUser *user = (PFUser*)object;
                UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
                ProfileViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
                vc.profileUser = user;
                [[SlideNavigationController sharedInstance] pushViewController:vc animated:YES];

            }
        }];
        
    }else if([intent isEqualToString:@"CommentFragment"]){
        NSString *postId = [userInfo objectForKey:@"postId"];
        PFQuery *query = [PFQuery queryWithClassName:@"Post"];
        [query whereKey:@"objectId" equalTo:postId];
        [query includeKey:@"user"];
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if (object) {
                UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
                CommentViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"CommentViewController"];
                vc.post = object;
                vc.profileUser = [object objectForKey:@"user"];
                [[SlideNavigationController sharedInstance] pushViewController:vc animated:YES];

            }
        }];
    }
}

@end
