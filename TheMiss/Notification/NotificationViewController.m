//
//  NotificationViewController.m
//  TheMiss
//
//  Created by lion on 8/21/14.
//  Copyright (c) 2014 Arsan. All rights reserved.
//

#import "CommentViewController.h"
#import "NotificationViewController.h"
#import "NotificationTableViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "Utils.h"
#import "Constants.h"
#import "AppManager.h"
#import "PostModel.h"

@interface NotificationViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    BOOL refreshing;
    NSMutableArray *notificationsArray;
}
@end

@implementation NotificationViewController

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
    // Do any additional setup after loading the view.
    [self setLoginStatus];
    notificationsArray = [NSMutableArray array];
    [self refreshNotification];

}

- (void)viewWillAppear:(BOOL)animated{
    [AppManager sharedInstance].messageCount = 0;
    self.view.userInteractionEnabled = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView Delegate Methods -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return notificationsArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *NotificationCellIdentifier = @"NotificationCell";
    NotificationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NotificationCellIdentifier];
    
    NSMutableDictionary *notification = notificationsArray[indexPath.row];
    //display username
    PFUser *fromUser = notification[@"fromUser"];
    if (notification[@"fromUser"]) {
        cell.userNameLabel.text = fromUser.username;
    }
    
    cell.timeLabel.text = notification[@"time"];
    if (fromUser) {
        PFFile *profileImageFile = (PFFile*)fromUser[@"profileImage"];
        if (profileImageFile) {
            [cell.profileImageView setImageWithURL:[NSURL URLWithString:profileImageFile.url]];
        }else{
            cell.profileImageView.image = [UIImage imageNamed:@"user_female_256.png"];
        }
    }
    [Utils setRoundView:cell.profileImageView borderColor:[UIColor clearColor]];
    
    PFUser *currentuser = [PFUser currentUser];
    if ([currentuser[@"admin"] boolValue] == TRUE) {
        cell.descriptionLabel.text = @"flagged";
    }else{
        NSString *kind = notification[@"kind"];
        if (!kind) {
            return cell;
        } else if ([kind isEqualToString:NOTIFICATION_KIND_VOTE]){
            cell.descriptionLabel.text = LocalizedString(@"has_voted_one");
        } else if ([kind isEqualToString:NOTIFICATION_KIND_SHARE]){
            cell.descriptionLabel.text = LocalizedString(@"has_shared_one");
        } else if ([kind isEqualToString:NOTIFICATION_KIND_COMMENT]){
            cell.descriptionLabel.text = LocalizedString(@"has_commented_one");
        } else if ([kind isEqualToString:NOTIFICATION_KIND_NEW_POST]){
            cell.descriptionLabel.text = LocalizedString(@"has_posted_new");
        }
        
    }
       
    [self set2HorizontalLabel:cell.descriptionLabel second:cell.photoLabel];
    
    
//    cell.delegate = self;
    
    return cell;

}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self goCommentPage:indexPath.row];
}

#pragma mark - internal methods -

- (void) refreshNotification{
    if (refreshing) {
        return;
    }
    
    refreshing = TRUE;

    _refreshActivityIndicator.hidden = FALSE;
    [_refreshActivityIndicator startAnimating];
    _refreshButton.hidden = TRUE;
    
    PFUser *currentUser = [PFUser currentUser];
    if (!currentUser) {
        return;
    }
    
    if ([currentUser[@"admin"] boolValue] == TRUE) {
        PFQuery *query = [PFQuery queryWithClassName:@"FlagedPicture"];
        [query orderByDescending:@"createdAt"];
        [query includeKey:@"post"];
        [query includeKey:@"user"];
        [query setLimit:PARSE_QUERY_MAX_LIMIT_COUNT];
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (objects && !error) {
                [notificationsArray removeAllObjects];
                for (PFObject *item in objects) {
                    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
                    [dic setObject:item[@"toUser"] forKey:@"toUser"];
                    [dic setObject:[self getDisplayTime:item.createdAt] forKey:@"time"];
                    [dic setObject:item[@"post"] forKey:@"post"];
                    if ([item[@"new"] boolValue]==TRUE) {
                        [item setObject:[NSNumber numberWithBool:NO] forKey:@"new"];
                        [item saveEventually];
                    }
                    
                    if (!item[@"user"]) {
                        [notificationsArray addObject:dic];
                    }
                }

                [self.tableView reloadData];
            }
            
            refreshing = FALSE;
            _refreshActivityIndicator.hidden = TRUE;
            [_refreshActivityIndicator stopAnimating];
            _refreshButton.hidden = FALSE;
            
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        }];

    }else{
        PFQuery *query1 = [PFQuery queryWithClassName:@"Notification"];
        [query1 whereKey:@"toUser" equalTo:currentUser];
        [query1 whereKey:@"fromUser" notEqualTo:currentUser];
        
        PFQuery *query2 = [PFQuery queryWithClassName:@"Notification"];
        [query2 whereKey:@"toUser" notEqualTo:currentUser];
        [query2 whereKey:@"commentUsers" containsAllObjectsInArray:@[currentUser.objectId]];
        
        PFQuery *innerQuery = [PFQuery queryWithClassName:@"Follower"];
        [innerQuery whereKey:@"fromUser" equalTo:currentUser];
        PFQuery *query3 = [PFQuery queryWithClassName:@"Notification"];
        [query3 whereKey:@"toUser" notEqualTo:currentUser];
        [query3 whereKey:@"kind" equalTo:NOTIFICATION_KIND_NEW_POST];
        [query3 whereKey:@"fromUser" matchesKey:@"toUser" inQuery:innerQuery];
        
        
        NSArray *query0 = [[NSArray alloc] initWithObjects:query1, query2, query3, nil];
        PFQuery *query = [PFQuery orQueryWithSubqueries:query0];
        [query orderByDescending:@"createdAt"];
        [query includeKey:@"fromUser"];
        [query includeKey:@"toUser"];
        [query includeKey:@"post"];
        [query setLimit:PARSE_QUERY_MAX_LIMIT_COUNT];
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (objects && !error) {
                [notificationsArray removeAllObjects];
                for (PFObject *item in objects) {
                    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
                    [dic setObject:item[@"fromUser"] forKey:@"fromUser"];
                    [dic setObject:item[@"toUser"] forKey:@"toUser"];
                    [dic setObject:[self getDisplayTime:item.createdAt] forKey:@"time"];
                    if(item[@"post"])
                        [dic setObject:item[@"post"] forKey:@"post"];
                    if(item[@"kind"])
                        [dic setObject:item[@"kind"] forKey:@"kind"];
                    if ([item[@"new"] boolValue]==TRUE) {
                        [item setObject:[NSNumber numberWithBool:NO] forKey:@"new"];
                        [item saveEventually];
                    }
                    [notificationsArray addObject:dic];
                    
                }
                
                [self.tableView reloadData];
            }
            
            refreshing = FALSE;
            _refreshActivityIndicator.hidden = TRUE;
            [_refreshActivityIndicator stopAnimating];
            _refreshButton.hidden = FALSE;
            
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        }];

    }
    
}

- (void) setLoginStatus{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:LOGGEDIN]){
        PFUser *currentUser = [PFUser currentUser];
        if (!currentUser[@"admin"]) {
            [_plusButton setHidden:FALSE];
        }else{
            [_plusButton setHidden:TRUE];
        }
        
        [_messageButton setHidden:FALSE];
        [_loginButton setHidden:TRUE];
        
    }else{
        [_plusButton setHidden:TRUE];
        [_messageButton setHidden:TRUE];
        [_loginButton setHidden:FALSE];
    }
}

- (void) goCommentPage:(int) pos{
    CommentViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"CommentViewController"];
    PFObject *post = notificationsArray[pos][@"post"];
    vc.profileUser = notificationsArray[pos][@"toUser"];
    vc.post = post;
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (NSString*) getDisplayTime:(NSDate*) date{
    NSDate *today = [NSDate date];
    long diff = [today timeIntervalSinceDate:date];
    long seconds = diff;
    long minutes = (seconds / 60) % 60;
    long hours = (seconds / 3600) % 24;
    long days = (seconds / 3600) / 24;
    return [NSString stringWithFormat:@"%ldd %ldh %ldm", days, hours, minutes];
}

- (void)set2HorizontalLabel:(UILabel*)firstLabel second:(UILabel*)secondLabel
{
    CGRect frame = firstLabel.frame;
    CGSize textViewSize = [firstLabel sizeThatFits:CGSizeMake(firstLabel.frame.size.width, FLT_MAX)];
    if (textViewSize.width > 250)
        frame.size = CGSizeMake(250, textViewSize.height);
    else
        frame.size = textViewSize;
    
    firstLabel.frame = frame;
    secondLabel.frame = CGRectMake(firstLabel.frame.origin.x + firstLabel.frame.size.width+5,
                                    firstLabel.frame.origin.y,
                                    secondLabel.frame.size.width,
                                    firstLabel.frame.size.height);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - SlideNavigationController Methods -

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
	return YES;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu
{
	return NO;
}

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)plusAction:(id)sender {
    [self plusMenuButtonAction];
}

- (IBAction)loginAction:(id)sender {
    [self loginMenuButtonAction];
}

- (IBAction)refreshAction:(id)sender {
    if (!refreshing) {
        [self refreshNotification];
    }
}
@end
