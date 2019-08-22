//
//  ProfileViewController.m
//  TheMiss
//
//  Created by lion on 7/5/14.
//  Copyright (c) 2014 Arsan. All rights reserved.
//

#import "ProfileViewController.h"
#import "CommentViewController.h"
#import "SettingsViewController.h"
#import "LoginViewController.h"
#import "ProfileHeaderTableViewCell.h"
#import "FemaleInfoTableViewCell.h"
#import "FemaleCategoryTableViewCell.h"
#import "MaleCategoryTableViewCell.h"
#import "PostTableViewCell.h"
#import "FollowerTableViewCell.h"
#import "MonthListTableViewCell.h"
#import "FanRankingCell.h"
#import "Utils.h"
#import "Constants.h"
#import "UIImageView+AFNetworking.h"
#import "AppManager.h"
#import "GADBannerView.h"
#import "GADRequest.h"

#define FOLLOW_ME_STATUS 0
#define FOLLOWING_STATUS 1
#define EDIT_STATUS   2

#define POST_SELECT 0
#define FOLLOWER_SELECT 1

@interface ProfileViewController ()<ProfilePostCellDelegate, UIActionSheetDelegate, UIAlertViewDelegate, UIDocumentInteractionControllerDelegate>
{
    PFUser *currentUser;
    PFObject *selectedPost;
    
    NSMutableArray *postDataArray;
    NSMutableArray *followerDataArray;
    
    BOOL refreshingPosts;
    BOOL refreshingFollowers;
    BOOL refreshingFollowing;
    int followingStatus;
    
    int sharesOfYear;
    int votesOfYear;
    int sharesOfMonth;
    int votesOfMonth;
    int positionNo;
    int positionCount;
    int currentMonth;
    int selectedMonth;
    
    int selectedCategory;
    int actionSheetCategory;
    
    NSString *shareImageUrl;
    NSString *sharePostUserName;
    PostTableViewCell *selectedPostCell;
}
@end

@implementation ProfileViewController

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
    currentUser = [PFUser currentUser];
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:[NSDate date]];
    currentMonth = [components month];
    selectedMonth = currentMonth;
    
    [self setLoginStatus];
    [self.backButton setTitle:self.profileUser.username forState:UIControlStateNormal];
    
    [self displayFollowStatus];
    if ([[AppManager sharedInstance] isFemale:_profileUser]) {
        [self displaySelfPosts];
        
    }else{
        [self displayVotedPosts];
    }
}

- (void) viewWillAppear:(BOOL)animated{
    [self displayNotificationWithoutQuery:_messageLabel];
}

- (void) viewDidAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(arriveNotification) name:LOCAL_NOTIFICATION_DISPLAY_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(increaseShareCount) name:LOCAL_NOTIFICATION_INCREASE_SHARE_COUNT object:nil];
}

- (void) viewDidDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:LOCAL_NOTIFICATION_DISPLAY_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:LOCAL_NOTIFICATION_INCREASE_SHARE_COUNT object:nil];
}

- (void)didReceiveMemoryWarning{
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
    if (selectedCategory == FOLLOWER_SELECT) {
        return followerDataArray.count + 7;
        
    }else if (selectedCategory == POST_SELECT){
        if ([[AppManager sharedInstance] isFemale:_profileUser]) {
            return postDataArray.count + 6 + (currentMonth -1);
            
        }else{
            return postDataArray.count + 6;
        }
    }

    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    if(indexPath.row == 0){     //profile picture cell
        return 220;
        
    }else if (indexPath.row == 1){      //description cell
        if (_profileUser[@"description"] && ![_profileUser[@"description"] isEqual:@""]) {
            CGRect rect = [self getDescriptionHeightWithText:_profileUser[@"description"] width:_tableView.frame.size.width];
            return rect.size.height + 20;
        }else{
            return 0;
        }
        
    }else if (indexPath.row == 2){      //count, ranking cell
        if (_profileUser[@"gender"] && [[_profileUser[@"gender"] lowercaseString] isEqualToString:@"male"]) {
            return 0;
        }else{
            return 136;
        }
        
    }else if (indexPath.row == 3){      //red line cell
        return 1;
        
    }else if (indexPath.row == 4){      //female category cell
        if (_profileUser[@"gender"] && [[_profileUser[@"gender"] lowercaseString] isEqualToString:@"male"]) {
            return 0;
        }else{
            return 44;
        }

        
    }else if (indexPath.row == 5){      //male cetegory cell
        if (_profileUser[@"gender"] && [[_profileUser[@"gender"] lowercaseString] isEqualToString:@"male"]) {
            return 44;
        }else{
            return 0;
        }
        
    }
    
    if (selectedCategory == FOLLOWER_SELECT) {
        if (_profileUser[@"gender"] && [[_profileUser[@"gender"] lowercaseString] isEqualToString:@"male"]) {
            if (indexPath.row == 6){
                return 0;
            }else if (indexPath.row > 6){
                return 60;
            }

        }else{
            if (indexPath.row == 6){
                return 65;
            }else if (indexPath.row > 6){
                return 60;
            }
        }
        
    }else if (selectedCategory == POST_SELECT){
        if (indexPath.row >= 6 && indexPath.row < 6 + postDataArray.count){
            if((indexPath.row - 6) % 5 == 4)
                return 500;
            else
                return 450;
        }else{
            return 44;
        }
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {   //display logo view
        static NSString *ProfileHeaderCellIdentifier = @"ProfileHeaderCell";
        ProfileHeaderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ProfileHeaderCellIdentifier];
        if (!cell) {
            cell = [[ProfileHeaderTableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:ProfileHeaderCellIdentifier];
        }
        
        PFFile *coverImageFile = self.profileUser[@"coverImage"];
        cell.coverImageView.clipsToBounds = YES;
        if (coverImageFile) {
             [cell.coverImageView setImageWithURL:[NSURL URLWithString:coverImageFile.url] placeholderImage:[UIImage imageNamed:@"profile_picture_bg.png"]];
        }
        
        PFFile *profileImageFile = self.profileUser[@"profileImage"];
        cell.profileImageView.clipsToBounds = YES;
        if (profileImageFile) {
            [cell.profileImageView setImageWithURL:[NSURL URLWithString:profileImageFile.url] placeholderImage:[UIImage imageNamed:@"user_female_256.png"]];

        }
        [Utils setRoundView:cell.profileImageView borderColor:[UIColor clearColor]];
        
        cell.userNameLabel.text = self.profileUser.username;
        
        //set follow button
        if (![[AppManager sharedInstance] isLogedIn]) {
            cell.followButton.hidden = TRUE;
            return cell;
        }

        if (![[AppManager sharedInstance] isFemale:_profileUser]) {
            cell.followButton.hidden = TRUE;
        }
        
        if (followingStatus == EDIT_STATUS) {
            [cell.followButton setTitle:LocalizedString(@"edit") forState:UIControlStateNormal];
            [cell.followButton setTitleColor:UIColorFromRGB(MAIN_RED_COLOR) forState:UIControlStateNormal];
            [cell.followButton setBackgroundImage:[UIImage imageNamed:@"red_border_btn_bg.png"] forState:UIControlStateNormal];
            cell.followButton.hidden = FALSE;
            
        } else if (followingStatus == FOLLOWING_STATUS) {
            [cell.followButton setTitle:LocalizedString(@"following") forState:UIControlStateNormal];
            [cell.followButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [cell.followButton  setBackgroundImage:[UIImage imageNamed:@"profile_following_bg.png"] forState:UIControlStateNormal];
            
        } else if(followingStatus == FOLLOW_ME_STATUS){
            [cell.followButton setTitle:LocalizedString(@"follow_me") forState:UIControlStateNormal];
            [cell.followButton setTitleColor:UIColorFromRGB(MAIN_RED_COLOR) forState:UIControlStateNormal];
            [cell.followButton setBackgroundImage:[UIImage imageNamed:@"red_border_btn_bg.png"] forState:UIControlStateNormal];
        }
        
        return cell;
        
    }else if (indexPath.row == 1){  //description cell
        static NSString *ProfileDesciptionCellIdentifier = @"ProfileDescriptonCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ProfileDesciptionCellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:ProfileDesciptionCellIdentifier];
        }
        
        cell.textLabel.text = self.profileUser[@"description"];
        cell.textLabel.font = [UIFont systemFontOfSize:12.0f];
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.frame = [self getDescriptionHeightWithText:self.profileUser[@"description"] width:cell.contentView.frame.size.width];
          
        return cell;
    }else if (indexPath.row == 2){      //female info cell
        FemaleInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FemaleInfoCell"];
        if (_profileUser[@"gender"] && [[_profileUser[@"gender"] lowercaseString] isEqualToString:@"male"]) {
            cell.contentView.hidden = TRUE;
        }else{
            
        }
        
        //display current year
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy"];
        cell.yearLabel.text = [df stringFromDate:[NSDate date]];
        
        //display selected month
        [df setDateFormat:@"MMM yyyy"];
        cell.monthLabel.text = [df stringFromDate:[Utils setMonth:selectedMonth]];
        cell.yearPhotosLabel.text = [NSString stringWithFormat:@"%d", sharesOfYear];
        cell.yearVotesCountLabel.text = [NSString stringWithFormat:@"%d", votesOfYear];
        cell.monthPhotosLabel.text = [NSString stringWithFormat:@"%d", sharesOfMonth];
        cell.monthVotesLabel.text = [NSString stringWithFormat:@"%d", votesOfMonth];
        cell.positionNoLabel.text = [NSString stringWithFormat:@"%d/", positionNo];
        cell.positionCountLabel.text = [NSString stringWithFormat:@"%d", positionCount];
        return cell;
        
    }else if (indexPath.row == 3){  //red line cell
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RedLineCell"];
        return cell;
    }
    else if (indexPath.row == 4){   //female cetegory cell
        FemaleCategoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FemaleCategoryCell"];
        if (_profileUser[@"gender"] && [[_profileUser[@"gender"] lowercaseString] isEqualToString:@"male"]) {
            cell.contentView.hidden = TRUE;
        }else{
           
        }
        
        cell.selfieCountLabel.text = [NSString stringWithFormat:@"%d", postDataArray.count];
        cell.followersCountLabel.text = [NSString stringWithFormat:@"%d", followerDataArray.count];
        
        UITapGestureRecognizer *tapGestureRecognizerSelf = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(displaySelfPosts)];
        tapGestureRecognizerSelf.numberOfTapsRequired =1;
        [cell.selfieView addGestureRecognizer:tapGestureRecognizerSelf];
        cell.selfieView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tapGestureRecognizerFollower = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(displayFollowers)];
        tapGestureRecognizerFollower.numberOfTapsRequired =1;
        [cell.followersView addGestureRecognizer:tapGestureRecognizerFollower];
        cell.followersView.userInteractionEnabled = YES;
        
        return cell;
    }
    else if (indexPath.row == 5){   //male category cell
        MaleCategoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MaleCategoryCell"];
        if (_profileUser[@"gender"] && [[_profileUser[@"gender"] lowercaseString] isEqualToString:@"male"]) {
            
        }else{
            cell.contentView.hidden = TRUE;
        }
        
        cell.voteCountLabel.text = [NSString stringWithFormat:@"%d", postDataArray.count];
        cell.followerCountLabel.text = [NSString stringWithFormat:@"%d", followerDataArray.count];
        
        UITapGestureRecognizer *tapGestureRecognizerVote = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(displayVotedPosts)];
        tapGestureRecognizerVote.numberOfTapsRequired =1;
        [cell.voteView addGestureRecognizer:tapGestureRecognizerVote];
        cell.voteView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tapGestureRecognizerFollower = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(displayMaleFollowers)];
        tapGestureRecognizerFollower.numberOfTapsRequired =1;
        [cell.followerView addGestureRecognizer:tapGestureRecognizerFollower];
        cell.followerView.userInteractionEnabled = YES;

        
        return cell;
    }
    
    if (selectedCategory == FOLLOWER_SELECT) {
        if (indexPath.row == 6){
            FanRankingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FanRankingCell"];
            if (_profileUser[@"gender"] && [[_profileUser[@"gender"] lowercaseString] isEqualToString:@"male"]) {
                cell.contentView.hidden = YES;
            }
            return cell;
            
        }else if (indexPath.row > 6){
            FollowerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FollowerCell"];
            PFObject *follower = followerDataArray[indexPath.row -7];
            PFUser *user = follower[@"user"];
            cell.userNameLabel.text = user.username;
            if (user[@"gender"] && [user[@"gender"] isEqualToString:@"female"]) {
                cell.userNameLabel.textColor = UIColorFromRGB(MAIN_RED_COLOR);
            }else{
                cell.userNameLabel.textColor = [UIColor blackColor];
            }
            
            PFFile *profileImageFile = user[@"profileImage"];
            if (profileImageFile) {
                [cell.profileImageView setImageWithURL:[NSURL URLWithString:profileImageFile.url]];
            }else{
                cell.profileImageView.image = [UIImage imageNamed:@"user_female_64.png"];
            }
            
            [Utils setRoundView:cell.profileImageView borderColor:[UIColor clearColor]];
            
            if (currentUser[@"gender"] && [currentUser[@"gender"] isEqualToString:@"female"]) {
                cell.voteCountLabel.text = [follower[@"totalActionCount"] stringValue];
                cell.rankingLabel.text = [NSString stringWithFormat:@"%d", indexPath.row - 7 + 1];
            }else{
                cell.voteCountLabel.hidden = YES;
                cell.rankingLabel.hidden = YES;
            }
            
            return cell;
        }
        
    }else if (selectedCategory == POST_SELECT){
        if (indexPath.row >= 6 && indexPath.row < 6 + postDataArray.count){
            PostTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PostCell"];
            PFObject *post = postDataArray[indexPath.row -6];
            
            //display profile image
            if(_profileUser[@"gender"] && [[_profileUser[@"gender"] lowercaseString] isEqualToString:@"male"]){
                PFUser *user = post[@"user"];
                if (user) {
                    PFFile *profileImageFile = user[@"profileImage"];
                    if (profileImageFile) {
                        [cell.profileImageView setImageWithURL:[NSURL URLWithString:profileImageFile.url]];
                    }
                    [Utils setRoundView:cell.profileImageView borderColor:[UIColor clearColor]];
                    cell.userNameLabel.text = user.username;
                }
                
            }else{
                PFFile *profileImageFile = _profileUser[@"profileImage"];
                if (profileImageFile) {
                    [cell.profileImageView setImageWithURL:[NSURL URLWithString:profileImageFile.url]];
                }
                [Utils setRoundView:cell.profileImageView borderColor:[UIColor clearColor]];
                cell.userNameLabel.text = _profileUser.username;
            }
            
            //display post image
            PFFile *postImageFile = post[@"image"];
            if (postImageFile) {
                [cell.postImageView setImageWithURL:[NSURL URLWithString:postImageFile.url]];
            }
            
            //display post month
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            NSString *language = currentUser[@"language"];
            if (language && [[language uppercaseString] isEqualToString:@"ITALIAN"] ) {
                [dateFormat setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"it_IT"]];
            }else{
                [dateFormat setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
            }
            [dateFormat setDateFormat:@"dd MMM"];
            cell.dateLabel.text = [[dateFormat stringFromDate:post.createdAt] capitalizedString];
            
            //display vote count.
            cell.voteCountLabel.text = [NSString stringWithFormat:@"%d", [post[@"voteUsers"] count]];
            
            //display share count.
            cell.shareCountLabel.text = [NSString stringWithFormat:@"%d", [post[@"shareCount"] intValue]];
            
            //display comment count.
            cell.commentCountLabel.text = [NSString stringWithFormat:@"%d", [post[@"commentUsers"] count]];
            
            //display comment status
            if ([[NSUserDefaults standardUserDefaults] boolForKey:LOGGEDIN] && _profileUser){
                if ([post[@"commentUsers"] containsObject:currentUser.objectId]) {
                    cell.commentButton.selected = TRUE;
                }else{
                    cell.commentButton.selected = FALSE;
                }
            }
            
            //display vote status
            if ([[NSUserDefaults standardUserDefaults] boolForKey:LOGGEDIN] && _profileUser){
                if ([post[@"voteUsers"] containsObject:currentUser.objectId]) {
                    cell.voteButton.selected = TRUE;
                }else{
                    cell.voteButton.selected = FALSE;
                }
            }
            
            //add banner view
            if((indexPath.row - 6) % 5 == 4){
                cell.bannerView.adUnitID = GOOGLE_ADS_ID;
                cell.bannerView.rootViewController = self;
                GADRequest *request = [GADRequest request];
                [cell.bannerView loadRequest:request];
                cell.bannerView.rootViewController = self;
                cell.bannerView.hidden = FALSE;
                
            }else{
                cell.bannerView.hidden = TRUE;
            }

            
            cell.delegate = self;
            
            return cell;

        }else{
            MonthListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MonthListCell"];
            int month = currentMonth - (indexPath.row - 6 - postDataArray.count);
            if (month <= selectedMonth) {
                cell.monthLabel.text = [NSString stringWithFormat:@"%@", [Utils getMonthName:month -1]];
            }else{
                 cell.monthLabel.text = [NSString stringWithFormat:@"%@", [Utils getMonthName:month]];
            }
            
            return cell;
        }
    }

    return nil;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (selectedCategory == POST_SELECT && indexPath.row >= postDataArray.count + 6){
        int month = currentMonth - (indexPath.row - (postDataArray.count + 6));
        if (month <= selectedMonth) {
            selectedMonth = month - 1;
        }else{
            selectedMonth = month;
        }
        
        [self refreshSelfPosts];
        
    }else if(selectedCategory == FOLLOWER_SELECT && indexPath.row > 6){
        ProfileViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
        PFObject *follower = followerDataArray[indexPath.row -7];
        vc.profileUser = follower[@"user"];
        [self.navigationController pushViewController:vc animated:YES];
    }
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

#pragma mark - ViewController Action -

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)loginAction:(id)sender {
    [self loginMenuButtonAction];
}

- (IBAction)refreshAction:(id)sender {
    [self refresh];
}

- (IBAction)messageAction:(id)sender {
    [self messageMenuButtonAction];
}

- (IBAction)plusAction:(id)sender {
    [self plusMenuButtonAction];
}

- (IBAction)followAction:(id)sender {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:LOGGEDIN]){
        [Utils showError:nil content:@"You must login first."];
        return;
    }
    
    if (followingStatus == FOLLOW_ME_STATUS) {
        [self addFollower];
    }else if (followingStatus == FOLLOWING_STATUS){
        [self removeFollower];
    }else if (followingStatus == EDIT_STATUS){
        SettingsViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingsViewController"];
        [[SlideNavigationController sharedInstance] pushViewController:vc animated:YES];
    }
}

#pragma mark - UIActionSheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    switch (actionSheetCategory) {
        case ACTIONSHEET_DELETE:
            if (buttonIndex == 0) {
                [self deletePicture];
            }
            break;
            
        case ACTIONSHEET_REPORT_INAPPROPRIATE:
            if (buttonIndex == 0) {
                [self reportFlaggedPicture];
            }
            break;
            
        case ACTIONSHEET_SHARE:
            if (buttonIndex == 0) {
                NSString *message = [NSString stringWithFormat:@"%@ %@ %@", LocalizedString(@"share_message_first"),
                                     sharePostUserName, LocalizedString(@"share_message_end")];
                [self shareWithFacebook:[FBSession activeSession] message:message imageUrl:shareImageUrl userName:sharePostUserName];
                
            } else if (buttonIndex == 1) {
                [self shareWithWhatsapp:shareImageUrl];
            } else if (buttonIndex == 2) {
                [self shareTo];
            }
            
            break;
            
        default:
            break;
    }
}

#pragma mark - AlertView delegate Methods -
- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 1) {
        [MBProgressHUD showMessag:LocalizedString(@"deleting") toView:self.view];
        _refreshActivityIndicator.hidden = FALSE;
        [_refreshActivityIndicator startAnimating];
        _refreshButton.hidden = TRUE;
        [selectedPost deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [self refresh];
            }
        }];
    } else {
        
    }
}

#pragma mark - PostTableViewCell delegate Methods -

- (void) votePost:(PostTableViewCell *)cell{
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:LOGGEDIN]) return;
    
    int voteCount = [cell.voteCountLabel.text intValue];
    int index = [self.tableView indexPathForCell:cell].row - 6;
    PFObject *post = postDataArray[index];
    
    NSMutableArray *voteUsersList = [NSMutableArray array];
    if (post[@"voteUsers"]) {
        [voteUsersList addObjectsFromArray:post[@"voteUsers"]];
    }
    
    if (!cell.voteButton.selected) {
        cell.voteButton.selected = YES;
        cell.voteCountLabel.text = [NSString stringWithFormat:@"%d",  voteCount + 1 ];
        [voteUsersList addObject:currentUser.objectId];
        [post setObject:voteUsersList forKey:@"voteUsers"];
        [post setObject:[NSNumber numberWithInt:[post[@"totalActionCount"] intValue]+1] forKey:@"totalActionCount"];
        [post saveEventually];
        
        //for notification
        PFObject *notification = [PFObject objectWithClassName:@"Notification"];
        [notification setObject:currentUser forKey:@"fromUser"];
        [notification setObject:post[@"user"] forKey:@"toUser"];
        [notification saveEventually:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                PFQuery *pushQuery = [PFInstallation query];
                [pushQuery whereKey:@"user" equalTo:post[@"user"]];
                
                //send push notification to query
                [self sendNotification:post kind:NOTIFICATION_KIND_VOTE];
            }
        }];
        
    }else{
        if ([cell.voteCountLabel.text intValue]<=0) return;
        
        [voteUsersList removeObject:currentUser.objectId];
        [post setObject:voteUsersList forKey:@"voteUsers"];
        [post setObject:[NSNumber numberWithInt:[post[@"totalActionCount"] intValue]-1] forKey:@"totalActionCount"];
        [post saveEventually];
        
        cell.voteButton.selected = FALSE;
        cell.voteCountLabel.text = [NSString stringWithFormat:@"%d",  voteCount - 1 ];
    }
}

- (void) shareTo{
    NSString *text = @"";
    NSURL *url = [NSURL URLWithString:@"http://themiss.com"];
    UIImage *image = selectedPostCell.postImageView.image;
        
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:@[text, url, image] applicationActivities:nil];
    
    [self.navigationController presentViewController:controller animated:YES completion:nil];
    
    [self increaseShareCount];
}

- (void) increaseShareCount{
    int shareCount = [selectedPostCell.shareCountLabel.text intValue];
    selectedPostCell.shareCountLabel.text = [NSString stringWithFormat:@"%d",  shareCount + 1 ];
    
    int index = [_tableView indexPathForCell:selectedPostCell].row - 6;
    PFObject *postItem = postDataArray[index];
    [postItem setObject:[NSNumber numberWithInt:shareCount + 1] forKey:@"shareCount"];
    [postItem setObject:[NSNumber numberWithInt:[postItem[@"totalActionCount"] intValue]+1] forKey:@"totalActionCount"];
    [postItem saveEventually];
    
    [self sendNotification:postItem kind:NOTIFICATION_KIND_SHARE];
}

- (void) sharePost:(PostTableViewCell *)cell{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:LOGGEDIN]){
        LoginViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        [[SlideNavigationController sharedInstance] pushViewController:vc animated:YES];
        return;
    }
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle: nil delegate:self cancelButtonTitle:LocalizedString(@"cancel") destructiveButtonTitle:nil otherButtonTitles:LocalizedString(@"share_on_facebook"), LocalizedString(@"share_on_whatsapp"), LocalizedString(@"share_to"), nil];
    
    actionSheetCategory = ACTIONSHEET_SHARE;
    int position = [self.tableView indexPathForCell:cell].row;
    PFObject *postItem = postDataArray[position - 6];
    PFFile *shareImageFile = postItem[@"image"];
    shareImageUrl = shareImageFile.url;
    sharePostUserName = _profileUser.username;
    selectedPostCell = cell;
    
    [actionSheet setActionSheetStyle:UIActionSheetStyleDefault];
    [actionSheet showInView:self.view];
}

- (void) commentPost:(PostTableViewCell *)cell{
    CommentViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"CommentViewController"];
    int index = [self.tableView indexPathForCell:cell].row - 6;
    PFObject *post = postDataArray[index];
    vc.profileUser = _profileUser;
    vc.post = post;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void) otherPost:(PostTableViewCell *)cell{
    int index = [self.tableView indexPathForCell:cell].row - 6;
    selectedPost = postDataArray[index];
    UIActionSheet *actionSheet;
    PFUser *postUser = selectedPost[@"user"];
    if (postUser && currentUser && ![postUser.objectId isEqualToString:currentUser.objectId]) {
        actionSheet = [[UIActionSheet alloc] initWithTitle: nil delegate:self cancelButtonTitle:LocalizedString(@"cancel") destructiveButtonTitle:nil otherButtonTitles:LocalizedString(@"report_inappropriate"), nil];
        actionSheetCategory = ACTIONSHEET_REPORT_INAPPROPRIATE;
    }else{
        actionSheet = [[UIActionSheet alloc] initWithTitle: nil delegate:self cancelButtonTitle:LocalizedString(@"cancel") destructiveButtonTitle:nil otherButtonTitles:LocalizedString(@"delete"), nil];
        actionSheetCategory = ACTIONSHEET_REPORT_INAPPROPRIATE;
    }
    
    [actionSheet setActionSheetStyle:UIActionSheetStyleDefault];
    [actionSheet showInView:self.view];
}

#pragma mark - internal methods -

- (void) refresh{
    if (![[AppManager sharedInstance] isFemale:_profileUser]) {
        if (selectedCategory == POST_SELECT && !refreshingPosts) {
            [self refreshVotedPosts];
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        } else if (selectedCategory == FOLLOWER_SELECT && !refreshingFollowers) {
            [self refreshMaleFollowers];
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        }
    }else{
        
        if (selectedCategory == POST_SELECT && !refreshingPosts) {
            [self refreshSelfPosts];
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        } else if (selectedCategory == FOLLOWER_SELECT && !refreshingFollowers) {
            [self refreshFollowers];
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        }
    }
}

- (void) refreshSelfPosts{
    if (refreshingPosts) {
        return;
    }
    
    refreshingPosts = TRUE;
    _refreshActivityIndicator.hidden = FALSE;
    [_refreshActivityIndicator startAnimating];
    _refreshButton.hidden = TRUE;
    
    postDataArray = [[NSMutableArray alloc] init];
    votesOfMonth = 0;
    votesOfYear = 0;
    sharesOfMonth = 0;
    sharesOfYear = 0;
    
    //get votes array
    PFQuery *query = [PFQuery queryWithClassName:@"Post"];
    [query whereKey:@"user" equalTo:_profileUser];
    [query whereKey:@"createdAt" greaterThanOrEqualTo:[Utils getFirstDayOfYear]];
    [query setLimit:PARSE_QUERY_MAX_LIMIT_COUNT];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            
            //get photos and votes of year
//            photosOfYear = objects.count;
            
            for (int i=0;i<objects.count;i++){
                if (objects[i][@"voteUsers"]) {
                    votesOfYear += [objects[i][@"voteUsers"] count];
                }
                sharesOfYear += [objects[i][@"shareCount"] integerValue];
            }
            
            //get photos and votes of month
            
            for (int i=0; i<objects.count; i++) {
                PFObject *post = objects[i];
                if (post) {
                    NSDateComponents *components1 = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:post.createdAt];
                    if (components1.month == selectedMonth) {
                        [postDataArray addObject:post];
                        if (post[@"voteUsers"]) {
                            votesOfMonth += [post[@"voteUsers"] count];
                        }
                        sharesOfMonth += [post[@"shareCount"] integerValue];
                    }
                }
            }
        }
        
        refreshingPosts = FALSE;
        _refreshActivityIndicator.hidden = TRUE;
        [_refreshActivityIndicator stopAnimating];
        _refreshButton.hidden = FALSE;
        
        [self.tableView reloadData];
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
    }];
    
    //get members and ranking
    PFQuery *query1 = [PFQuery queryWithClassName:@"Post"];
    [query1 whereKey:@"createdAt" greaterThanOrEqualTo:[Utils getFirstDayOfMonth]];
    [query1 setLimit:PARSE_QUERY_MAX_LIMIT_COUNT];
    [query1 includeKey:@"user"];
    [query1 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSMutableArray *userList = [NSMutableArray array];
            for (int i=0; i<objects.count; i++) {
                PFUser *user = objects[i][@"user"];
                if (!user) {
                    return;
                }
                NSMutableDictionary *userDic = [[NSMutableDictionary alloc] init];
                int index = [Utils getIndexOfObject:userList user:user];
                if (index<0) {
                    [userDic setObject:user forKey:@"user"];
                    if (objects[i][@"voteUsers"]) {
                        [userDic setObject:[NSNumber numberWithInt:[objects[i][@"voteUsers"] count]]  forKey:@"totalActionCount"];
                    }else{
                        [userDic setObject:@0  forKey:@"totalActionCount"];
                    }
                    [userList addObject:userDic];
                }else{
                    userDic = userList[index];
                    if (objects[i][@"voteUsers"]) {
                        int currentActionCount = [userDic[@"totalActionCount"] intValue] + [objects[i][@"voteUsers"] count];
                        [userDic setObject:[NSNumber numberWithInt:currentActionCount]  forKey:@"totalActionCount"];
                    }
                }
                
            }
            
            //get sorted array by action count
            NSMutableArray *sortedUserList = [NSMutableArray arrayWithArray:[userList sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                NSNumber *first = obj1[@"totalActionCount"];
                NSNumber *second = obj2[@"totalActionCount"];
                return [second compare:first];
            }]];
            
            positionNo = [Utils getIndexOfObject:sortedUserList user:_profileUser]+1;
            positionCount = sortedUserList.count;
            
            [self.tableView reloadData];
        }
    }];

    
}

- (void) refreshVotedPosts{
    if (refreshingPosts) {
        return;
    }
    
    refreshingPosts = TRUE;
    _refreshActivityIndicator.hidden = FALSE;
    [_refreshActivityIndicator startAnimating];
    _refreshButton.hidden = TRUE;
    
    postDataArray = [[NSMutableArray alloc] init];
    
    //get votes array
    PFQuery *query = [PFQuery queryWithClassName:@"Post"];
    [query includeKey:@"user"];
    [query whereKey:@"voteUsers" equalTo:_profileUser.objectId];
    [query whereKey:@"createdAt" greaterThanOrEqualTo:[Utils getFirstDayOfMonth]];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (objects) {
            if (selectedCategory == POST_SELECT) {
                [postDataArray addObjectsFromArray:objects];
                [self.tableView reloadData];
            }
        }
        
        refreshingPosts = FALSE;
        _refreshActivityIndicator.hidden = TRUE;
        [_refreshActivityIndicator stopAnimating];
        _refreshButton.hidden = FALSE;
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }];
}

- (void) setLoginStatus{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:LOGGEDIN]){
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

- (void) displaySelfPosts{
    FemaleCategoryTableViewCell *cell = (FemaleCategoryTableViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];
    cell.selfieView.backgroundColor = UIColorFromRGB(MAIN_RED_COLOR);
    cell.selfieImageView.image = [UIImage imageNamed:@"profile_white_camera_icon.png"];
    cell.selfieLabel.textColor = [UIColor whiteColor];
    cell.selfieCountLabel.textColor = [UIColor whiteColor];
    
    cell.followersView.backgroundColor = [UIColor whiteColor];
    cell.followersImageView.image = [UIImage imageNamed:@"profile_red_follower_icon.png"];
    cell.followersLabel.textColor = UIColorFromRGB(MAIN_RED_COLOR);
    cell.followersCountLabel.textColor = UIColorFromRGB(MAIN_RED_COLOR);
    
    selectedCategory = POST_SELECT;
    
    if (postDataArray && postDataArray.count>0) {
        [self.tableView reloadData];
    }else{
        [self.tableView reloadData];
        [self refreshSelfPosts];
    }
}

- (void) displayVotedPosts{
    MaleCategoryTableViewCell *cell = (MaleCategoryTableViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:5 inSection:0]];
    cell.voteView.backgroundColor = UIColorFromRGB(MAIN_RED_COLOR);
    cell.voteImageView.image = [UIImage imageNamed:@"profile_vote_white_btn.png"];
    cell.voteCountLabel.textColor = [UIColor whiteColor];
    cell.voteLabel.textColor = [UIColor whiteColor];
    
    cell.followerView.backgroundColor = [UIColor whiteColor];
    cell.followerImageView.image = [UIImage imageNamed:@"profile_red_follower_icon.png"];
    cell.followerLabel.textColor = UIColorFromRGB(MAIN_RED_COLOR);
    cell.followerCountLabel.textColor = UIColorFromRGB(MAIN_RED_COLOR);
    
    selectedCategory = POST_SELECT;

    if (postDataArray && postDataArray.count>0) {
        [self.tableView reloadData];
    }else{
        [self.tableView reloadData];
        [self refreshVotedPosts];
    }
}

- (void) displayFollowers{
    FemaleCategoryTableViewCell *cell = (FemaleCategoryTableViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];
    
    cell.selfieView.backgroundColor = [UIColor whiteColor];
    cell.selfieImageView.image = [UIImage imageNamed:@"profile_red_camera_icon.png"];
    cell.selfieLabel.textColor = UIColorFromRGB(MAIN_RED_COLOR);
    cell.selfieCountLabel.textColor = UIColorFromRGB(MAIN_RED_COLOR);
    
    cell.followersView.backgroundColor = UIColorFromRGB(MAIN_RED_COLOR);
    cell.followersImageView.image = [UIImage imageNamed:@"profile_white_follower_icon.png"];
    cell.followersLabel.textColor = [UIColor whiteColor];
    cell.followersCountLabel.textColor = [UIColor whiteColor];
    
    selectedCategory = FOLLOWER_SELECT;
    
    if (followerDataArray && followerDataArray.count>0) {
        [self.tableView reloadData];
    }else{
        [self.tableView reloadData];
        [self refreshFollowers];
    }
    
}

- (void) displayMaleFollowers{
    MaleCategoryTableViewCell *cell = (MaleCategoryTableViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:5 inSection:0]];
    
    cell.voteView.backgroundColor = [UIColor whiteColor];
    cell.voteImageView.image = [UIImage imageNamed:@"unvote_btn.png"];
    cell.voteLabel.textColor = UIColorFromRGB(MAIN_RED_COLOR);
    cell.voteCountLabel.textColor = UIColorFromRGB(MAIN_RED_COLOR);
    
    cell.followerView.backgroundColor = UIColorFromRGB(MAIN_RED_COLOR);
    cell.followerImageView.image = [UIImage imageNamed:@"profile_white_follower_icon.png"];
    cell.followerLabel.textColor = [UIColor whiteColor];
    cell.followerCountLabel.textColor = [UIColor whiteColor];
    
    selectedCategory = FOLLOWER_SELECT;
    
    if (followerDataArray && followerDataArray.count>0) {
        [self.tableView reloadData];
    }else{
        [self.tableView reloadData];
        [self refreshMaleFollowers];
    }
    
}

- (void) refreshFollowers{
    if (refreshingFollowers) {
        return;
    }
    
    refreshingFollowers = TRUE;
    _refreshActivityIndicator.hidden = FALSE;
    [_refreshActivityIndicator startAnimating];
    _refreshButton.hidden = TRUE;
    
    PFQuery *query = [PFQuery queryWithClassName:@"Follower"];
    [query whereKey:@"toUser" equalTo:_profileUser];
    [query includeKey:@"fromUser"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (objects) {
            followerDataArray = [NSMutableArray array];
            for (PFObject *item in objects) {
                if (item[@"fromUser"]) {
                    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
                    [dic setObject:item[@"fromUser"] forKey:@"user"];
                    [dic setObject:@0 forKey:@"totalActionCount"];
                    [followerDataArray addObject:dic];
                }
                
            }
            
            //get members and ranking
            PFQuery *query1 = [PFQuery queryWithClassName:@"Post"];
            [query1 whereKey:@"createdAt" greaterThanOrEqualTo:[Utils getFirstDayOfMonth]];
            [query1 includeKey:@"user"];
            [query1 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (objects) {
             
                    for (int i=0; i<objects.count; i++) {
                        PFUser *user = objects[i][@"user"];
                        if (!user) continue;
                        
                        NSLog(@"%@", user.username);
//                        if ([Utils containUser:followerDataArray user:user]) continue;
                        
                        int index = [Utils getIndexOfObject:followerDataArray user:user];
                        if (index < 0) {
                            
                        }else{
                            NSMutableDictionary *userDic = followerDataArray[index];
                            NSArray *usersArray = objects[i][@"voteUsers"];
                            if (usersArray) {
                                [userDic setObject:[NSNumber numberWithInt:usersArray.count + [userDic[@"totalActionCount"] intValue]] forKey:@"totalActionCount"];
                            }
                        }
                    }
                    
                    //sort user list by action count
                    followerDataArray = [NSMutableArray arrayWithArray:[followerDataArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                        NSNumber *first = obj1[@"totalActionCount"];
                        NSNumber *second = obj2[@"totalActionCount"];
                        return [second compare:first];
                    }]];
                    
//                    if (selectedCategory == FOLLOWER_SELECT) {
                        [self.tableView reloadData];
//                    }

                }
                
                refreshingFollowers = FALSE;
                [_refreshActivityIndicator stopAnimating];
                _refreshActivityIndicator.hidden = TRUE;
                _refreshButton.hidden = FALSE;
            }];
        }
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }];
}

- (void) refreshMaleFollowers{
    if (refreshingFollowers) {
        return;
    }
    
    refreshingFollowers = TRUE;
    _refreshActivityIndicator.hidden = FALSE;
    [_refreshActivityIndicator startAnimating];
    _refreshButton.hidden = TRUE;
    
    PFQuery *query = [PFQuery queryWithClassName:@"Follower"];
    [query whereKey:@"fromUser" equalTo:_profileUser];
    [query includeKey:@"toUser"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (objects) {
            followerDataArray = [NSMutableArray array];
            for (PFObject *item in objects) {
                if (item[@"toUser"]) {
                    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
                    [dic setObject:item[@"toUser"] forKey:@"user"];
                    [dic setObject:@0 forKey:@"totalActionCount"];
                    [followerDataArray addObject:dic];
                }
                
            }
            
            //get members and ranking
            PFQuery *query1 = [PFQuery queryWithClassName:@"Post"];
            [query1 whereKey:@"createdAt" greaterThanOrEqualTo:[Utils getFirstDayOfMonth]];
            [query1 includeKey:@"user"];
            [query1 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (objects) {
                    
                    for (int i=0; i<objects.count; i++) {
                        PFUser *user = objects[i][@"user"];
                        if (!user) continue;
                        
                        NSLog(@"%@", user.username);
                        //                        if ([Utils containUser:followerDataArray user:user]) continue;
                        
                        int index = [Utils getIndexOfObject:followerDataArray user:user];
                        if (index < 0) {
                            
                        }else{
                            NSMutableDictionary *userDic = followerDataArray[index];
                            NSArray *usersArray = objects[i][@"voteUsers"];
                            if (usersArray) {
                                [userDic setObject:[NSNumber numberWithInt:usersArray.count + [userDic[@"totalActionCount"] intValue]] forKey:@"totalActionCount"];
                            }
                        }
                    }
                    
                    //sort user list by action count
                    followerDataArray = [NSMutableArray arrayWithArray:[followerDataArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                        NSNumber *first = obj1[@"totalActionCount"];
                        NSNumber *second = obj2[@"totalActionCount"];
                        return [second compare:first];
                    }]];
                    
                    if (selectedCategory == FOLLOWER_SELECT) {
                        [self.tableView reloadData];
                    }
                    
                }
                
                refreshingFollowers = FALSE;
                [_refreshActivityIndicator stopAnimating];
                _refreshActivityIndicator.hidden = TRUE;
                _refreshButton.hidden = FALSE;
            }];
        }
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }];
}

- (void) reportFlaggedPicture{
    [_refreshActivityIndicator startAnimating];
    _refreshActivityIndicator.hidden = FALSE;
    _refreshButton.hidden = TRUE;
    
    PFObject *flaggedObject = [PFObject objectWithClassName:@"FlagedPicture"];
    [flaggedObject setObject:selectedPost forKey:@"post"];
    [flaggedObject setObject:selectedPost[@"user"] forKey:@"user"];
    [flaggedObject setObject:[NSNumber numberWithBool:TRUE] forKey:@"new"];
    [flaggedObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        _refreshButton.hidden = FALSE;
        [_refreshActivityIndicator stopAnimating];
        _refreshActivityIndicator.hidden = TRUE;
        
        if (succeeded) {
            [MBProgressHUD showSuccess:LocalizedString(@"report_success") toView:self.view];
            
            
            //send notification to admin user
            //                PFQuery *pushQuery = [PFInstallation query];
            //                NSMutableDictionary *pushData = [[NSMutableDictionary alloc] init];
            //                [pushData setObject:@"action" forKey:@"com.ghebb.themiss.VOTE_ACTION"];
            //                PFPush *push = [PFPush push];
            //                push.
        }
    }];
    
}

- (void) addFollower{
    if(!_profileUser || ![[NSUserDefaults standardUserDefaults] boolForKey:LOGGEDIN]) return;
    if(refreshingFollowing) return;
    
    refreshingFollowing = true;
    _refreshActivityIndicator.hidden = FALSE;
    [_refreshActivityIndicator startAnimating];
    _refreshButton.hidden = TRUE;
    
    PFObject *follower = [PFObject objectWithClassName:@"Follower"];
    [follower setObject:currentUser forKey:@"fromUser"];
    [follower setObject:_profileUser forKey:@"toUser"];
    [follower saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
//            [MBProgressHUD showSuccess:@"Followed successfully" toView:self.view];
            refreshingFollowing = FALSE;
            followingStatus = FOLLOWING_STATUS;
            
            [self sendFollowingNotification:currentUser toUser:_profileUser];
            [self refreshFollowers];
        }else{
            [_refreshActivityIndicator stopAnimating];
            _refreshActivityIndicator.hidden = TRUE;
            _refreshButton.hidden = FALSE;
            refreshingFollowing = FALSE;
        }
    }];
    
}

- (void) removeFollower{
    if(!_profileUser || ![[NSUserDefaults standardUserDefaults] boolForKey:LOGGEDIN]) return;
    if(refreshingFollowing) return;
    
    refreshingFollowing = true;
    _refreshActivityIndicator.hidden = FALSE;
    [_refreshActivityIndicator startAnimating];
    _refreshButton.hidden = TRUE;
    
    PFQuery *query = [PFQuery queryWithClassName:@"Follower"];
    [query whereKey:@"fromUser" equalTo:currentUser];
    [query whereKey:@"toUser" equalTo:_profileUser];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error) {
            for (PFObject *obj in objects) {
                [obj deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    refreshingFollowing = FALSE;
                    followingStatus = FOLLOW_ME_STATUS;
                    [self refreshFollowers];
                }];
            }
        }
    }];
}

- (void) displayFollowStatus{
    if(!_profileUser || ![[NSUserDefaults standardUserDefaults] boolForKey:LOGGEDIN]) return;
    
    if ([_profileUser.objectId isEqualToString:currentUser.objectId]) {
        followingStatus = EDIT_STATUS;
        [self.tableView reloadData];
        return;
    }
    
    PFQuery *query = [PFQuery queryWithClassName:@"Follower"];
    [query whereKey:@"fromUser" equalTo:currentUser];
    [query whereKey:@"toUser" equalTo:_profileUser];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects && objects.count>0) {
            followingStatus = FOLLOWING_STATUS;
        }else{
            followingStatus = FOLLOW_ME_STATUS;
        }
        
        [self.tableView reloadData];
    }];
}

- (void) deletePicture{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"confirm_deleting") message:LocalizedString(@"delete_this_picture") delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [alert show];
}

- (void) arriveNotification{
    [self displayNotificationWithQuery:_messageLabel];
}

-(CGRect) getDescriptionHeightWithText:(NSString*)text width:(float)width{
    CGRect rect = [text boundingRectWithSize:CGSizeMake(width, 2000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12.0f]} context:nil];
    return rect;
}

//- (void) sendNotification{
//    AppDelegate *appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
//    [appDelegate displayNotification:_messageLabel];
//}

#pragma mark - SlideNavigationController Methods -

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
	return YES;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu
{
	return NO;
}

@end
