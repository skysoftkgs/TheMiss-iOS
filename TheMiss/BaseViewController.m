//
//  BaseViewController.m
//  TheMiss
//
//  Created by lion on 6/22/14.
//  Copyright (c) 2014 Arsan. All rights reserved.
//

#import "BaseViewController.h"
#import "LoginViewController.h"
#import "SettingsViewController.h"
#import "ImportViewController.h"
#import "InviteViewController.h"
#import "NotificationViewController.h"
#import "Constants.h"
#import "Utils.h"
#import "AppManager.h"
#import "BundleEx.h"

@interface BaseViewController()<UIDocumentInteractionControllerDelegate>

@end

@implementation BaseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //set lagnuage
    PFUser *currentUser = [PFUser currentUser];
    NSString *language = currentUser[@"language"];
    if (language && [[language uppercaseString] isEqualToString:@"ITALIAN"] ) {
//        LocalizationSetLanguage(@"it");
        [NSBundle setLanguage:@"it"];
    }else{
        [NSBundle setLanguage:@"en"];
    }
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) plusMenuButtonAction{
    PFUser *currentUser = [PFUser currentUser];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:LOGGEDIN]){
        LoginViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        [self.navigationController pushViewController:vc animated:YES];
        
    }else{
        if (!currentUser[@"gender"]) {
            [Utils showError:nil content:LocalizedString(@"you_must_set_gender")];
            
        }else{
            if ([[currentUser[@"gender"] lowercaseString] isEqualToString:@"female"]) {
                ImportViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ImportViewController"];
                [[SlideNavigationController sharedInstance] pushViewController:vc animated:YES];
                
            }else if ([[currentUser[@"gender"] lowercaseString] isEqualToString:@"male"]) {
                InviteViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"InviteViewController"];
                [[SlideNavigationController sharedInstance] pushViewController:vc animated:YES];
            }
        }
    }
}

- (void) loginMenuButtonAction{
    LoginViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void) messageMenuButtonAction{
    NotificationViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"NotificationViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void) openMenuAction{
    [[SlideNavigationController sharedInstance] prepareMenuForReveal:MenuRight forcePrepare:YES];
    [[SlideNavigationController sharedInstance] toggleLeftMenu];
}

#pragma mark - Notification methods - 

- (void) displayNotification:(NSNotification*) notification{
    if (![notification.object isKindOfClass:[UILabel class]]) {
        return;
    }
    UILabel *messageLabel = notification.object;
    [self displayNotificationWithQuery:messageLabel];
}

- (void) displayNotificationWithQuery:(UILabel*) messageLabel{
    self.view.userInteractionEnabled = YES;
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:LOGGEDIN]) {
        return;
    }
    
    PFUser *currentUser = [PFUser currentUser];
    
    if ([currentUser[@"admin"] boolValue] == TRUE) {
        PFQuery *query = [PFQuery queryWithClassName:@"FlagedPicture"];
        [query whereKey:@"new" equalTo:[NSNumber numberWithBool:YES]];
        [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
            if (!error) {
                if (number>0) {
                    [AppManager sharedInstance].messageCount = number;
                    messageLabel.text = [NSString stringWithFormat:@"%d", number];
                    messageLabel.hidden = FALSE;
                }else{
                    messageLabel.hidden = TRUE;
                }
            }
        }];
    }else{
        
        PFQuery *query1= [PFQuery queryWithClassName:@"Notification"];
        [query1 whereKey:@"toUser" equalTo:currentUser];
        [query1 whereKey:@"fromUser" notEqualTo:currentUser];
        
        PFQuery *query2 = [PFQuery queryWithClassName:@"Notification"];
        [query2 whereKey:@"toUser" equalTo:currentUser];
        [query2 whereKey:@"commentUsers" containsAllObjectsInArray:@[currentUser.objectId]];
        
        PFQuery *innerQuery = [PFQuery queryWithClassName:@"Follower"];
        [innerQuery whereKey:@"fromUser" equalTo:currentUser];
        PFQuery *query3 = [PFQuery queryWithClassName:@"Notification"];
        [query3 whereKey:@"toUser" notEqualTo:currentUser];
        [query3 whereKey:@"kind" equalTo:NOTIFICATION_KIND_NEW_POST];
        [query3 whereKey:@"fromUser" matchesKey:@"toUser" inQuery:innerQuery];
        
        NSArray *query0 = [NSArray arrayWithObjects:query1, query2, query3, nil];
        PFQuery *query = [PFQuery orQueryWithSubqueries:query0];
        [query whereKey:@"new" equalTo:[NSNumber numberWithBool:YES]];
        [query setLimit:PARSE_QUERY_MAX_LIMIT_COUNT];
        [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
            if (!error) {
                if (number>0) {
                    [AppManager sharedInstance].messageCount = number;
                    messageLabel.text = [NSString stringWithFormat:@"%d", number];
                    messageLabel.hidden = FALSE;
                }else{
                    messageLabel.hidden = TRUE;
                }
            }
        }];
        
    }
    
}

- (void) displayNotificationWithoutQuery:(UILabel*) messageLabel{
    self.view.userInteractionEnabled = YES;
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:LOGGEDIN]) {
        return;
    }
    
    if ([AppManager sharedInstance].messageCount>0) {
        messageLabel.text = [NSString stringWithFormat:@"%d", [AppManager sharedInstance].messageCount];
        messageLabel.hidden = FALSE;
    }else{
        messageLabel.hidden = TRUE;
    }
}

- (void) sendNotification:(PFObject*)post kind:(NSString*) kind{
    PFUser *currentUser = [PFUser currentUser];
    PFObject *notification = [PFObject objectWithClassName:@"Notification"];
    [notification setObject:currentUser forKey:@"fromUser"];
    [notification setObject:post[@"user"] forKey:@"toUser"];
    [notification setObject:[NSNumber numberWithBool:YES] forKey:@"new"];
    [notification setObject:post forKey:@"post"];
    [notification setObject:kind forKey:@"kind"];
    PFUser *toUser = [post objectForKey:@"user"];
    if ([toUser.objectId isEqualToString:currentUser.objectId] &&
        [kind isEqualToString:NOTIFICATION_KIND_COMMENT]) {
        [notification setObject:post[@"commentUsers"] forKey:@"commentUsers"];
    }
    [notification saveEventually:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            PFQuery *pushQuery = [PFInstallation query];
            if ([kind isEqualToString:NOTIFICATION_KIND_COMMENT] &&
                [toUser.objectId isEqualToString:currentUser.objectId]) {
                NSMutableArray *commentUsers = post[@"commentUsers"];
                if (!commentUsers) {
                    return;
                }
                commentUsers = [Utils removeUser:currentUser idList:commentUsers];
                
                PFQuery *innerQuery = [PFUser query];
                [innerQuery whereKey:@"objectId" containedIn:commentUsers];
                [pushQuery whereKey:@"user" matchesQuery:innerQuery];
                
            }else if ([kind isEqualToString:NOTIFICATION_KIND_NEW_POST]){
                PFQuery *query = [PFQuery queryWithClassName:@"Follower"];
                [query whereKey:@"toUser" equalTo:currentUser];
                [query includeKey:@"fromUser"];
                [pushQuery whereKey:@"user" matchesKey:@"fromUser" inQuery:query];
                
            }else{
                if (![currentUser.objectId isEqualToString:toUser.objectId]) {
                    [pushQuery whereKey:@"user" equalTo:toUser];
                }else{
                    return;
                }
            }
            
            //send push notification to query
            NSDictionary *data;
            if ([kind isEqualToString:NOTIFICATION_KIND_NEW_POST]) {
                data = @{@"action": @"com.ghebb.themiss.VOTE_ACTION",
                         @"postId": post.objectId,
                         @"alert": [NSString stringWithFormat:@"%@ %@", currentUser.username, @"posted new photo"],
                         @"intent": @"CommentFragment"};
                
            }else{
                data = @{@"action": @"com.ghebb.themiss.VOTE_ACTION"};
            }

            [PFPush sendPushDataToQueryInBackground:pushQuery withData:data];
        }
    }];
}

- (void)sendFollowingNotification:(PFUser*) fromUser toUser:(PFUser*) toUser{
    NSDictionary *data;
    NSString *message = [NSString stringWithFormat:@"%@ %@", fromUser.username, LocalizedString(@"is_following_you")];
    data = @{@"action": @"com.ghebb.themiss.VOTE_ACTION",
             @"alert": message,
             @"fromUser": fromUser.objectId,
             @"intent": @"ProfileFragment"};
    PFQuery *pushQuery = [PFInstallation query];
    [pushQuery whereKey:@"user" equalTo:toUser];
    [PFPush sendPushDataToQueryInBackground:pushQuery withData:data];
}

- (void)sendFlagNotification{
    NSDictionary* data = @{@"action": @"com.ghebb.themiss.VOTE_ACTION"};
    PFQuery *pushQuery = [PFInstallation query];
    [PFPush sendPushDataToQueryInBackground:pushQuery withData:data];
}

- (void)sendNewUserSignupNotification{
    NSDictionary* data = @{@"action": @"com.ghebb.themiss.VOTE_ACTION",
                           @"intent": @"NewUsersSignup"};
    PFQuery *pushQuery = [PFInstallation query];
    [PFPush sendPushDataToQueryInBackground:pushQuery withData:data];
}

#pragma mark - Share related methods -

- (void) shareWithFacebook:(FBSession*)session
                   message:(NSString*)message
                  imageUrl:(NSString*)imageUrl
                  userName:(NSString*)userName{
    
    PFUser *currentUser = [PFUser currentUser];
    
    if (!currentUser[@"facebookID"] || !session || ![session isOpen]) {
        SettingsViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingsViewController"];
        vc.scrollToEnd = TRUE;
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    
    // Put together the dialog parameters
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @"TheMiss", @"name",
                                   message, @"message",
                                   [NSString stringWithFormat:@"%@ shared %@'s photo.", currentUser.username, userName], @"caption",
                                   @"http://themiss.com", @"link",
                                   imageUrl, @"picture",
                                   nil];
    	
    // Show the feed dialog
    [FBWebDialogs presentFeedDialogModallyWithSession:session
                                           parameters:params
                                              handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                  if (error) {
                                                      // An error occurred, we need to handle the error
                                                      // See: https://developers.facebook.com/docs/ios/errors
                                                      NSLog(@"Error publishing story: %@", error.description);
                                                  } else {
                                                      if (result == FBWebDialogResultDialogNotCompleted) {
                                                          // User cancelled.
                                                          NSLog(@"User cancelled.");
                                                      } else {
                                                          // Handle the publish feed callback
                                                          NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                                                          
                                                          if (![urlParams valueForKey:@"post_id"]) {
                                                              // User cancelled.
                                                              NSLog(@"User cancelled.");
                                                              
                                                          } else {
                                                              // User clicked the Share button
                                                              NSString *result = [NSString stringWithFormat: @"Posted story, id: %@", [urlParams valueForKey:@"post_id"]];
                                                              NSLog(@"result %@", result);
                                                              
                                                              [MBProgressHUD showSuccess:@"Posted successfully" toView:self.view];
                                                              
                                                              [[NSNotificationCenter defaultCenter] postNotificationName:LOCAL_NOTIFICATION_INCREASE_SHARE_COUNT object:nil];
                                                          }
                                                      }
                                                  }
                                              }];
    
}

- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
}

- (void) shareWithWhatsapp:(NSString*)imageUrl{
    
    NSURL *imageFileURL = [NSURL URLWithString:imageUrl];
    
    NSLog(@"imag %@",imageFileURL);
    
    self.documentationInteractionController.delegate = self;
    self.documentationInteractionController.UTI = @"net.whatsapp.image";
    self.documentationInteractionController = [self setupControllerWithURL:imageFileURL usingDelegate:self];
    [self.documentationInteractionController presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:LOCAL_NOTIFICATION_INCREASE_SHARE_COUNT object:nil];
}

- (UIDocumentInteractionController *) setupControllerWithURL: (NSURL*) fileURL
                                               usingDelegate: (id <UIDocumentInteractionControllerDelegate>) interactionDelegate {
    self.documentationInteractionController = [UIDocumentInteractionController interactionControllerWithURL: fileURL];
    self.documentationInteractionController.delegate = interactionDelegate;
    
    return self.documentationInteractionController;
}

@end
