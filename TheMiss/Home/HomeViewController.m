//
//  HomeViewController.m
//  TheMiss
//
//  Created by lion on 6/19/14.
//  Copyright (c) 2014 Arsan. All rights reserved.
//

#import "HomeViewController.h"
#import "LeftMenuViewController.h"
#import "LoginViewController.h"
#import "InviteViewController.h"
#import "ProfileViewController.h"
#import "HomeLogoTableViewCell.h"
#import "HomeCategoryTableViewCell.h"
#import "HomeLastPicturesTableViewCell.h"
#import "HomeMissOfMonthTableViewCell.h"
#import "HomeGridTableViewCell.h"
#import "HomeFemaleWinnersTableViewCell.h"
#import "HomeMaleWinnersTableViewCell.h"
#import "AppManager.h"
#import "Constants.h"
#import "Utils.h"
#import "MissOfMonthModel.h"
#import "UIImageView+AFNetworking.h"
#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import "GADBannerView.h"
#import "GADRequest.h"


@interface HomeViewController ()<UITableViewDataSource, UITableViewDelegate, HomeLastPicturesCellDelegate, HomeMissOfMonthCellDelegate, UIActionSheetDelegate, UIAlertViewDelegate, UIDocumentInteractionControllerDelegate, UIGestureRecognizerDelegate>
{
    HomeCategoryTableViewCell *categoryCell;
    
    NSMutableArray *lastPicturesDataArray;
    NSMutableArray *missOfMonthDataArray;
    
    PFUser *currentUser;
    PFObject *post;
    int selectedCategory;
    int actionSheetCategory;
    int displayMode;
    BOOL refreshingLastPictures;
    BOOL refreshingMissOfMonth;
    BOOL refreshingWinner;
    
    NSString *shareImageUrl;
    NSString *sharePostUserName;
    HomeLastPicturesTableViewCell *selectedLastPicturesCell;
    HomeMissOfMonthTableViewCell *selectedMissOfMonthCell;
}

@end

@implementation HomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    //initialize data
    selectedCategory = SELECT_HOME_LASTPICTURES;
    displayMode = LIST_MODE;
    currentUser = [PFUser currentUser];
    
    [self setLoginStatus];
    refreshRequired = TRUE;
    
    [self displayNotificationWithQuery:_messageLabel];
}

- (void) viewWillAppear:(BOOL)animated{
    [self displayNotificationWithoutQuery:_messageLabel];
}

- (void) viewDidAppear:(BOOL)animated{
    if (refreshRequired) {
        [self refreshLastPictures];
        refreshRequired = FALSE;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(arriveNotification) name:LOCAL_NOTIFICATION_DISPLAY_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(increaseShareCount) name:LOCAL_NOTIFICATION_INCREASE_SHARE_COUNT object:nil];
}

- (void) viewDidDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:LOCAL_NOTIFICATION_DISPLAY_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:LOCAL_NOTIFICATION_INCREASE_SHARE_COUNT object:nil];
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
    if (selectedCategory == SELECT_HOME_LASTPICTURES) { //if "Last Pictures" button is selected
        if (displayMode == LIST_MODE) {
            return [lastPicturesDataArray count] + 2;
        }else{
            return ceil([lastPicturesDataArray count]/3.0f) + 2;
        }
        
    }else if (selectedCategory == SELECT_HOME_MISSOFMONTH){ //if "Miss of Month" button is selected
        if (displayMode == LIST_MODE) {
            return [missOfMonthDataArray count] + 2;
        }else{
            return ceil([missOfMonthDataArray count]/3.0f) + 2;
        }
        
    }else{  //if "The Winners" button is selected
        return 3;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.row == 0) {   //logo cell
        if ([[NSUserDefaults standardUserDefaults] boolForKey:LOGGEDIN] || [AppManager sharedInstance].headerHidden) {
            return 0;
        } else{
            return 320;
        }
    }else if(indexPath.row == 1){   //category cell
        if (selectedCategory == SELECT_HOME_WINNERS) {
            return 50;
        }else{
            return 140;
        }
    }else{  //post cell
        if (selectedCategory == SELECT_HOME_WINNERS) {
            return 520;
        }else{
            if (displayMode == LIST_MODE) {
                if((indexPath.row - 2) % 5 == 4)
                    return 500;
                else
                    return 450;
                
            }
            else{
                return 107;
            }

        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //init tap gesture to go to profile page when clicking username, post image, profile image.
    UITapGestureRecognizer *tapGestureRecognizer1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showProfile:)];
    tapGestureRecognizer1.numberOfTapsRequired =1;
    tapGestureRecognizer1.delegate = self;
    
    UITapGestureRecognizer *tapGestureRecognizer2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showProfile:)];
    tapGestureRecognizer2.numberOfTapsRequired =1;
    tapGestureRecognizer2.delegate = self;
    
    UITapGestureRecognizer *tapGestureRecognizer3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showProfile:)];
    tapGestureRecognizer3.numberOfTapsRequired =1;
    tapGestureRecognizer3.delegate = self;
    
    if (indexPath.row == 0) {   //display logo view
        static NSString *HomeLogoCellIdentifier = @"HomeLogoCell";
        HomeLogoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:HomeLogoCellIdentifier];
        if (!cell) {
            cell = [[HomeLogoTableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:HomeLogoCellIdentifier];
        }
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:LOGGEDIN] || [AppManager sharedInstance].headerHidden) {
            cell.contentView.hidden = TRUE;
        } else {
            cell.contentView.hidden = FALSE;
        }
        
        return cell;
        
    }else if (indexPath.row == 1) {     //display category view
        static NSString *HomeCategoryCellIdentifier = @"HomeCategoryCell";
        HomeCategoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:HomeCategoryCellIdentifier];
        if (!cell) {
            cell = [[HomeCategoryTableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:HomeCategoryCellIdentifier];
        }
        
        
        [cell selectButton:selectedCategory];
        [cell selectMode:displayMode];
    
        return cell;
        
    }else {         //display post view
        static NSString *lastPicturesCellIdentifier = @"HomeLastPicturesCell";
        static NSString *missOfMonthCellIdentifier = @"HomeMissOfMonthCell";
        static NSString *gridCellIdentifier = @"HomeGridCell";
        
        if (selectedCategory == SELECT_HOME_LASTPICTURES) {
            
            if (displayMode == LIST_MODE) {
                HomeLastPicturesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:lastPicturesCellIdentifier];
                if (!cell) {
                    cell = [[HomeLastPicturesTableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:lastPicturesCellIdentifier];
                }
                
                PFObject *lastPicturesItem = lastPicturesDataArray[indexPath.row - 2];
                
                cell.postImageView.image = nil;
                
                //display post image
                PFFile *postImageFile = (PFFile*) lastPicturesItem[@"image"];
                if (postImageFile) {
                    [cell.postImageView setImageWithURL:[NSURL URLWithString:postImageFile.url]];
//                    [cell.postImageView setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
//                        [cell.progressView setProgress:totalBytesRead * 100 / totalBytesExpectedToRead animated:YES];
//                    }];
                }else{
                    cell.postImageView.backgroundColor = [UIColor darkGrayColor];
                }
                
                //display past time since post
                NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
                NSDateComponents *components = [calendar components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:[lastPicturesItem createdAt] toDate:[NSDate date] options:0];
                
                NSString *language = currentUser[@"language"];
                if (language && [[language uppercaseString] isEqualToString:@"ITALIAN"] ) {
                     cell.postTimeLabel.text = [NSString stringWithFormat:@"%ig %ih %im", components.day, components.hour, components.minute];
                }else{
                     cell.postTimeLabel.text = [NSString stringWithFormat:@"%id %ih %im", components.day, components.hour, components.minute];
                }
               
                
                PFUser *user = lastPicturesItem[@"user"];
                if (user) {
                    //display username
                    cell.userNameLabel.text = user.username;
                    
                    //display profile image
                    PFFile *profileImageFile = (PFFile*) user[@"profileImage"];
                    if (profileImageFile) {
                        [cell.profileImageView setImageWithURL:[NSURL URLWithString:profileImageFile.url]];
                    }else{
                        cell.profileImageView.image = [UIImage imageNamed:@"user_female_64"];
                    }
                    
                    [Utils setRoundView:cell.profileImageView borderColor:[UIColor clearColor]];
                }
                
                NSMutableArray *voteUsersList = [NSMutableArray array];
                if (lastPicturesItem[@"voteUsers"]) {
                    [voteUsersList addObjectsFromArray:lastPicturesItem[@"voteUsers"]];
                }
                
                //display vote count
                cell.voteCountLabel.text = [NSString stringWithFormat:@"%d", [voteUsersList count]];
                
                //display voted status
                if ([voteUsersList containsObject:currentUser.objectId]) {
                    cell.voteButton.selected = TRUE;

                }else{
                    cell.voteButton.selected = FALSE;
                }
                
                //display share count
                cell.shareCountLabel.text = [NSString stringWithFormat:@"%d", [lastPicturesItem[@"shareCount"] intValue]];
                
                cell.delegate = self;
                
                //apply tap event to go to profile page.
                [cell.userNameLabel addGestureRecognizer:tapGestureRecognizer1];
                tapGestureRecognizer1.view.tag = indexPath.row - 2;
                cell.userNameLabel.userInteractionEnabled = YES;
                [cell.postImageView addGestureRecognizer:tapGestureRecognizer2];
                tapGestureRecognizer2.view.tag = indexPath.row - 2;
                cell.postImageView.userInteractionEnabled = YES;
                [cell.profileImageView addGestureRecognizer:tapGestureRecognizer3];
                tapGestureRecognizer3.view.tag = indexPath.row - 2;
                cell.profileImageView.userInteractionEnabled = YES;
                
                //add banner view
                if((indexPath.row - 2) % 5 == 4){
                    cell.bannerView.adUnitID = GOOGLE_ADS_ID;
                    cell.bannerView.rootViewController = self;
                    GADRequest *request = [GADRequest request];
                    [cell.bannerView loadRequest:request];
                    cell.bannerView.rootViewController = self;
                    cell.bannerView.hidden = FALSE;
                    
                }else{
                    cell.bannerView.hidden = TRUE;
                }

                
                return cell;

            }else if (displayMode == GRID_MODE) {
                HomeGridTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:gridCellIdentifier];
                if (!cell) {
                    cell = [[HomeGridTableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:gridCellIdentifier];
                }
                
                cell.leftImageView.image = nil;
                cell.middleImageView.image = nil;
                cell.rightImageView.image = nil;
                
                //display left post image
                if((indexPath.row - 2)*3 >=[lastPicturesDataArray count]) return cell;
                PFObject *gridLeftItem = lastPicturesDataArray[(indexPath.row - 2)*3];
                
                PFFile *leftImageFile = (PFFile*) gridLeftItem[@"thumbnail"];
                if (!leftImageFile) {
                    leftImageFile = (PFFile*) gridLeftItem[@"image"];
                }
                [cell.leftImageView setImageWithURL:[NSURL URLWithString:leftImageFile.url]];
                
                //display middle post image
                if((indexPath.row - 2)*3+1 >=[lastPicturesDataArray count]) return cell;
                PFObject *gridMiddleItem = lastPicturesDataArray[(indexPath.row - 2)*3+1];

                PFFile *middleImageFile = (PFFile*) gridMiddleItem[@"thumbnail"];
                if (!middleImageFile){
                    middleImageFile = (PFFile*) gridMiddleItem[@"image"];
                }
                [cell.middleImageView setImageWithURL:[NSURL URLWithString:middleImageFile.url]];

                
                //display right post image
                if((indexPath.row - 2)*3+2 >=[lastPicturesDataArray count]) return cell;
                PFObject *gridRightItem = lastPicturesDataArray[(indexPath.row - 2)*3+2];
                
                PFFile *rightImageFile = (PFFile*) gridRightItem[@"thumbnail"];
                if (!rightImageFile) {
                    rightImageFile = (PFFile*) gridRightItem[@"image"];
                }
                [cell.rightImageView setImageWithURL:[NSURL URLWithString:rightImageFile.url]];
                
                
                //apply tap event to go to profile page.
                [cell.leftImageView addGestureRecognizer:tapGestureRecognizer1];
                tapGestureRecognizer1.view.tag = (indexPath.row - 2)*3;
                cell.leftImageView.userInteractionEnabled = YES;
                [cell.middleImageView addGestureRecognizer:tapGestureRecognizer2];
                tapGestureRecognizer2.view.tag = (indexPath.row - 2)*3+1;
                cell.middleImageView.userInteractionEnabled = YES;
                [cell.rightImageView addGestureRecognizer:tapGestureRecognizer3];
                tapGestureRecognizer3.view.tag = (indexPath.row - 2)*3+2;
                cell.rightImageView.userInteractionEnabled = YES;

                return cell;
            }
            
        }else if (selectedCategory == SELECT_HOME_MISSOFMONTH){
            if (displayMode == LIST_MODE) {
                HomeMissOfMonthTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:missOfMonthCellIdentifier];
                if (!cell) {
                    cell = [[HomeMissOfMonthTableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:missOfMonthCellIdentifier];
                }
                
                MissOfMonthModel *missOfMonthItem = missOfMonthDataArray[indexPath.row - 2];
                PFObject *postObject = missOfMonthItem.post;
                
                cell.postImageView.image = nil;
                
                //display ranking
                cell.rankingLabel.text = [NSString stringWithFormat:@"%d", indexPath.row-1];
                if (indexPath.row -2 <9) {
                    cell.rankingLabel.font = [UIFont boldSystemFontOfSize:45];
                }else if(indexPath.row - 2>=9 && indexPath.row - 2<999){
                    cell.rankingLabel.font = [UIFont boldSystemFontOfSize:30];
                }else{
                    cell.rankingLabel.font = [UIFont boldSystemFontOfSize:20];
                }
                
                //display post image
                PFFile *postImageFile = (PFFile*) postObject[@"image"];
                if (postImageFile) {
                    [cell.postImageView setImageWithURL:[NSURL URLWithString:postImageFile.url]];
                }else{
                    cell.postImageView.backgroundColor = [UIColor darkGrayColor];
                }
         
                PFUser *user = postObject[@"user"];
                if (user) {
                    //display username
                    cell.userNameLabel.text = user.username;
                    
                    //display profile image
                    PFFile *profileImageFile = (PFFile*) user[@"profileImage"];
                    if (profileImageFile) {
                        [cell.profileImageView setImageWithURL:[NSURL URLWithString:profileImageFile.url]];
                    }else{
                        cell.profileImageView.image = [UIImage imageNamed:@"user_female_64"];
                    }
                    [Utils setRoundView:cell.profileImageView borderColor:[UIColor clearColor]];
                }
                
                NSMutableArray *voteUsersList = [NSMutableArray array];
                if (postObject[@"voteUsers"]) {
                    [voteUsersList addObjectsFromArray:postObject[@"voteUsers"]];
                }
                

                //display vote count
                cell.voteCountLabel.text = [NSString stringWithFormat:@"%d", [voteUsersList count]];
                
                //display voted status
                if ([voteUsersList containsObject:currentUser.objectId]) {
                    [cell.voteButton setBackgroundImage:[UIImage imageNamed:@"vote_btn"] forState:UIControlStateNormal];
                }else{
                    [cell.voteButton setBackgroundImage:[UIImage imageNamed:@"unvote_btn"] forState:UIControlStateNormal];
                }
                
                //display share count
                cell.shareCountLabel.text = [NSString stringWithFormat:@"%d", [postObject[@"shareCount"] intValue]];
                
                //display total action count
                cell.allVoteCountLabel.text = [NSString stringWithFormat:@"%d", missOfMonthItem.totalVoteCount];
                
                cell.delegate = self;
                
                //apply tap event to go to profile page.
                [cell.userNameLabel addGestureRecognizer:tapGestureRecognizer1];
                tapGestureRecognizer1.view.tag = indexPath.row - 2;
                cell.userNameLabel.userInteractionEnabled = YES;
                [cell.postImageView addGestureRecognizer:tapGestureRecognizer2];
                tapGestureRecognizer2.view.tag = indexPath.row - 2;
                cell.postImageView.userInteractionEnabled = YES;
                [cell.profileImageView addGestureRecognizer:tapGestureRecognizer3];
                tapGestureRecognizer3.view.tag = indexPath.row - 2;
                cell.profileImageView.userInteractionEnabled = YES;

                //add banner view
                if((indexPath.row - 2) % 5 == 4){
                    cell.bannerView.adUnitID = GOOGLE_ADS_ID;
                    cell.bannerView.rootViewController = self;
                    GADRequest *request = [GADRequest request];
                    [cell.bannerView loadRequest:request];
                    cell.bannerView.rootViewController = self;
                    cell.bannerView.hidden = FALSE;
                    
                }else{
                    cell.bannerView.hidden = TRUE;
                }
                return cell;
                
            }else if (displayMode == GRID_MODE) {
                HomeGridTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:gridCellIdentifier];
                if (!cell) {
                    cell = [[HomeGridTableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:gridCellIdentifier];
                }
                
                cell.leftImageView.image = nil;
                cell.middleImageView.image = nil;
                cell.rightImageView.image = nil;
                
                //display left post image
                if((indexPath.row - 2)*3 >=[missOfMonthDataArray count]) return cell;
                MissOfMonthModel *gridLeftItem = missOfMonthDataArray[(indexPath.row - 2)*3];
                PFObject *leftPostObject = gridLeftItem.post;
                
                PFFile *leftImageFile = (PFFile*) leftPostObject[@"thumbnail"];
                if (!leftImageFile) {
                    leftImageFile = (PFFile*) leftPostObject[@"image"];
                }
                [cell.leftImageView setImageWithURL:[NSURL URLWithString:leftImageFile.url]];
                
                //display middle post image
                if((indexPath.row - 2)*3+1 >=[missOfMonthDataArray count]) return cell;
                MissOfMonthModel *gridMiddleItem = missOfMonthDataArray[(indexPath.row - 2)*3+1];
                PFObject *middlePostObject = gridMiddleItem.post;
                
                PFFile *middleImageFile = (PFFile*) middlePostObject[@"thumbnail"];
                if (!middleImageFile){
                    middleImageFile = (PFFile*) middlePostObject[@"image"];
                }
                [cell.middleImageView setImageWithURL:[NSURL URLWithString:middleImageFile.url]];
                
                //display right post image
                if((indexPath.row - 2)*3+2 >=[missOfMonthDataArray count]) return cell;
                MissOfMonthModel *gridRightItem = missOfMonthDataArray[(indexPath.row - 2)*3+2];
                PFObject *rightPostObject = gridRightItem.post;
                
                PFFile *rightImageFile = (PFFile*) rightPostObject[@"thumbnail"];
                if (!rightImageFile) {
                    rightImageFile = (PFFile*) rightPostObject[@"image"];
                }
                [cell.rightImageView setImageWithURL:[NSURL URLWithString:rightImageFile.url]];
                
                //apply tap event to go to profile page.
                [cell.leftImageView addGestureRecognizer:tapGestureRecognizer1];
                tapGestureRecognizer1.view.tag = (indexPath.row - 2)*3;
                cell.leftImageView.userInteractionEnabled = YES;
                [cell.middleImageView addGestureRecognizer:tapGestureRecognizer2];
                tapGestureRecognizer2.view.tag = (indexPath.row - 2)*3+1;
                cell.middleImageView.userInteractionEnabled = YES;
                [cell.rightImageView addGestureRecognizer:tapGestureRecognizer3];
                tapGestureRecognizer3.view.tag = (indexPath.row - 2)*3+2;
                cell.rightImageView.userInteractionEnabled = YES;

                return cell;
            }
 
        }else{      //winners tab
            if([AppManager sharedInstance].winnerPost){
                HomeMissOfMonthTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomeWinnerCell"];
                if (!cell) {
                    cell = [[HomeMissOfMonthTableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:missOfMonthCellIdentifier];
                }
                
                cell.postImageView.image = nil;
                
                //display post month
                NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                [dateFormat setDateFormat:@"MMM yyyy"];
                cell.winnerMonthLabel.text = [NSString stringWithFormat:@"Miss %@", [dateFormat stringFromDate:[Utils getFirstDayOfPrevMonth]]];
                                
                //display post image
                PFFile *postImageFile = (PFFile*) [AppManager sharedInstance].winnerPost[@"image"];
                if (postImageFile) {
                    [cell.postImageView setImageWithURL:[NSURL URLWithString:postImageFile.url]];
                }else{
                    cell.postImageView.backgroundColor = [UIColor darkGrayColor];
                }
                
                PFUser *user = [AppManager sharedInstance].winnerPost[@"user"];
                if (user) {
                    //display username
                    cell.userNameLabel.text = user.username;
                    
                    //display profile image
                    PFFile *profileImageFile = (PFFile*) user[@"profileImage"];
                    if (profileImageFile) {
                        [cell.profileImageView setImageWithURL:[NSURL URLWithString:profileImageFile.url]];
                    }else{
                        cell.profileImageView.image = [UIImage imageNamed:@"user_female_64"];
                    }
                    [Utils setRoundView:cell.profileImageView borderColor:[UIColor clearColor]];
                }
                
                NSMutableArray *voteUsersList = [NSMutableArray array];
                if ([AppManager sharedInstance].winnerPost[@"voteUsers"]) {
                    [voteUsersList addObjectsFromArray:[AppManager sharedInstance].winnerPost[@"voteUsers"]];
                }
                
                //display vote count
                cell.voteCountLabel.text = [NSString stringWithFormat:@"%d", [voteUsersList count]];
                
                //display voted status
                if ([voteUsersList containsObject:currentUser.objectId]) {
                    [cell.voteButton setBackgroundImage:[UIImage imageNamed:@"vote_btn"] forState:UIControlStateNormal];
                }else{
                    [cell.voteButton setBackgroundImage:[UIImage imageNamed:@"unvote_btn"] forState:UIControlStateNormal];
                }
                
                //display share count
                cell.shareCountLabel.text = [NSString stringWithFormat:@"%d", [[AppManager sharedInstance].winnerPost[@"shareCount"] intValue]];
                
                int totalActionCount = [voteUsersList count] + [[AppManager sharedInstance].winnerPost[@"shareCount"] intValue];
                //display total action count
                cell.allVoteCountLabel.text = [NSString stringWithFormat:@"%d", totalActionCount];
                
                //apply tap event to go to profile page.
                [cell.userNameLabel addGestureRecognizer:tapGestureRecognizer1];
                tapGestureRecognizer1.view.tag = 0;
                cell.userNameLabel.userInteractionEnabled = YES;
                [cell.postImageView addGestureRecognizer:tapGestureRecognizer2];
                tapGestureRecognizer2.view.tag = 1;
                cell.postImageView.userInteractionEnabled = YES;
                [cell.profileImageView addGestureRecognizer:tapGestureRecognizer3];
                tapGestureRecognizer3.view.tag = 2;
                cell.profileImageView.userInteractionEnabled = YES;
                return cell;
                
            }else{
                
                if (currentUser[@"gender"] && [[currentUser[@"gender"] lowercaseString] isEqualToString:@"male"]) {
                    HomeMaleWinnersTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MaleWinnersCell"];
                    if (!cell) {
                        cell = [[HomeMaleWinnersTableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:@"MaleWinnersCell"];
                    }
                    if (![[NSUserDefaults standardUserDefaults] boolForKey:LOGGEDIN]){
                        [cell.maleInviteButton setTitle:LocalizedString(@"SIGNUP") forState:UIControlStateNormal];
                    }else{
                        [cell.maleInviteButton setTitle:LocalizedString(@"INVITE") forState:UIControlStateNormal];
                    }
                    return cell;
                    
                }else{
                    
                    static NSString *HomeFemaleWinnersCellIdentifier = @"FemaleWinnersCell";
                    HomeFemaleWinnersTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:HomeFemaleWinnersCellIdentifier];
                    if (!cell) {
                        cell = [[HomeFemaleWinnersTableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:HomeFemaleWinnersCellIdentifier];
                    }
                    if (![[NSUserDefaults standardUserDefaults] boolForKey:LOGGEDIN]){
                        [cell.femaleInviteButton setTitle:LocalizedString(@"SIGNUP") forState:UIControlStateNormal];
                    }else{
                        [cell.femaleInviteButton setTitle:LocalizedString(@"INVITE") forState:UIControlStateNormal];
                    }
                    return cell;
                }
            }
        }
        
    }

    return nil;
}

#pragma mark - ViewController Methods -

- (IBAction)showLeftMenuAction:(id)sender {
    [self openMenuAction];
}

- (IBAction)displayLastPicturesAction:(id)sender {
    selectedCategory = SELECT_HOME_LASTPICTURES;
    [self reloadData];
}

- (IBAction)displayMissOfMonthAction:(id)sender {
    selectedCategory = SELECT_HOME_MISSOFMONTH;
    [self reloadData];
}

- (IBAction)displayWinnersAction:(id)sender {
    selectedCategory = SELECT_HOME_WINNERS;
    [self reloadData];
}

- (IBAction)loginAction:(id)sender {
    [self loginMenuButtonAction];
}

- (IBAction)listModeAction:(id)sender {
    displayMode = LIST_MODE;
    [self reloadData];
}

- (IBAction)gridModeAction:(id)sender {
    displayMode = GRID_MODE;
    [self reloadData];
}

- (IBAction)plusAction:(id)sender {
    [self plusMenuButtonAction];
}

- (IBAction)refreshAction:(id)sender {
    if (selectedCategory == SELECT_HOME_LASTPICTURES) {
        if (!refreshingLastPictures) {
            [self refreshLastPictures];
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        }
        
    }else if(selectedCategory == SELECT_HOME_MISSOFMONTH){
        if (!refreshingMissOfMonth) {
            [self refreshMissOfMonth];
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        }
    }
}

- (IBAction)messageAction:(id)sender {
    [self messageMenuButtonAction];
}

- (IBAction)signupAction:(id)sender {
    [self goLoginPage];
}

- (IBAction)closeHeaderAction:(id)sender {
    [AppManager sharedInstance].headerHidden = TRUE;
    [self.tableView reloadData];
}

- (IBAction)winnerSignupAction:(id)sender {
    [self goLoginPage];
}

#pragma mark - internal methods -
- (void) reloadData{
    [_postTableView reloadData];
    
    if (selectedCategory == SELECT_HOME_LASTPICTURES) {
        if ([lastPicturesDataArray count]>0) {
            
        }else{
            [self refreshLastPictures];
        }
    }else if(selectedCategory == SELECT_HOME_MISSOFMONTH){
        if ([missOfMonthDataArray count]>0) {
           
        }else{
            [self refreshMissOfMonth];
        }
    } else if (selectedCategory == SELECT_HOME_WINNERS){
        if ([AppManager sharedInstance].winnerPost) {
            
        }else{
            [self getWinnerOfLastMonth];
        }
    }
}

- (void) goLoginPage{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:LOGGEDIN]) {
        InviteViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"InviteViewController"];
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        LoginViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        [self.navigationController pushViewController:vc
                                             animated:YES];
    }
}

- (void) getWinnerOfLastMonth{
    if (refreshingWinner) {
        return;
    }
    
    refreshingWinner = TRUE;
    _refreshActivityIndicator.hidden = FALSE;
    [_refreshActivityIndicator startAnimating];
    _refreshButton.hidden = TRUE;
    
    PFQuery *innerQuery = [PFUser query];
    [innerQuery whereKey:@"deactive" notEqualTo:[NSNumber numberWithBool:YES]];
    PFQuery *query = [PFQuery queryWithClassName:@"Post"];
    [query whereKey:@"createdAt" greaterThanOrEqualTo:[Utils getFirstDayOfPrevMonth]];
    [query whereKey:@"createdAt" lessThan:[Utils getFirstDayOfMonth]];
    [query orderByDescending:@"totalActionCount"];
    [query setLimit:1];
    [query includeKey:@"user"];
    [query whereKey:@"user" matchesQuery:innerQuery];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {

        _refreshActivityIndicator.hidden = TRUE;
        [_refreshActivityIndicator stopAnimating];
        _refreshButton.hidden = FALSE;
        refreshingWinner = FALSE;
        
        if (objects && objects.count > 0) {
            [AppManager sharedInstance].winnerPost = objects[0];
        }
        
        [self.postTableView reloadData];
        
    }];
}

- (void) refreshLastPictures{
    if (refreshingLastPictures) return;
    
    lastPicturesDataArray = [[NSMutableArray alloc] init];
    [_postTableView reloadData];
    
    refreshingLastPictures = TRUE;
    _refreshActivityIndicator.hidden = FALSE;
    [_refreshActivityIndicator startAnimating];
    _refreshButton.hidden = TRUE;
    
    PFQuery *innerQuery = [PFUser query];
    [innerQuery whereKey:@"deactive" notEqualTo:[NSNumber numberWithBool:YES]];
    PFQuery *query = [PFQuery queryWithClassName:@"Post"];
    [query whereKey:@"createdAt" greaterThanOrEqualTo:[Utils getFirstDayOfMonth]];
    [query orderByDescending:@"createdAt"];
    [query setLimit:PARSE_QUERY_MAX_LIMIT_COUNT];
    [query includeKey:@"user"];
    [query whereKey:@"user" matchesQuery:innerQuery];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        _refreshActivityIndicator.hidden = TRUE;
        [_refreshActivityIndicator stopAnimating];
        _refreshButton.hidden = FALSE;
        refreshingLastPictures = FALSE;
        
        if (objects == nil || [objects count] == 0) {
            return;
        }
        
        if (!error) {
            [lastPicturesDataArray addObjectsFromArray:objects];
//            voteCountArray = [NSMutableArray arrayWithCapacity:[lastPicturesDataArray count]];
            [_postTableView reloadData];
        }
    }];
}

- (void) refreshMissOfMonth{
    if (refreshingMissOfMonth) return;
    
    missOfMonthDataArray = [[NSMutableArray alloc] init];
    [_postTableView reloadData];
    
    refreshingMissOfMonth = TRUE;
    _refreshActivityIndicator.hidden = FALSE;
    [_refreshActivityIndicator startAnimating];
    _refreshButton.hidden = TRUE;
    
    PFQuery *innerQuery = [PFUser query];
    [innerQuery whereKey:@"deactive" notEqualTo:[NSNumber numberWithBool:YES]];
    PFQuery *query = [PFQuery queryWithClassName:@"Post"];
    [query whereKey:@"createdAt" greaterThanOrEqualTo:[Utils getFirstDayOfMonth]];
//    [query orderByDescending:@"totalActionCount"];
    [query orderByDescending:@"createdAt"];
    [query setLimit:PARSE_QUERY_MAX_LIMIT_COUNT];
    [query includeKey:@"user"];
    [query whereKey:@"user" matchesQuery:innerQuery];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        _refreshActivityIndicator.hidden = TRUE;
        [_refreshActivityIndicator stopAnimating];
        _refreshButton.hidden = FALSE;
        refreshingMissOfMonth = FALSE;
        
        if (objects == nil || [objects count] == 0) {
            return;
        }
        
        if (!error) {
            [missOfMonthDataArray removeAllObjects];
            
            for(int i=0;i<objects.count;i++){
                PFObject *postObject = objects[i];
                if (!postObject[@"user"]) {
                    continue;
                }
                
                MissOfMonthModel *model;
                int index = [Utils getIndexOfMissMonth:missOfMonthDataArray object:postObject];
                NSMutableArray *voteUsersArray = postObject[@"voteUsers"];
                
                if(index < 0){
                    model = [[MissOfMonthModel alloc] init];
                    model.post = postObject;
                    if(voteUsersArray)
                        model.totalVoteCount = voteUsersArray.count;
                    else
                        model.totalVoteCount = 0;
                    
                    [missOfMonthDataArray addObject:model];
                
                }else{
                    model = missOfMonthDataArray[index];
                    if(voteUsersArray)
                        model.totalVoteCount = model.totalVoteCount + voteUsersArray.count;
                }
                
            }
            
            //get sorted array by action count
            missOfMonthDataArray = [NSMutableArray arrayWithArray:[missOfMonthDataArray sortedArrayUsingComparator:^NSComparisonResult(MissOfMonthModel *obj1, MissOfMonthModel *obj2) {
                NSNumber *first = [NSNumber numberWithInt:obj1.totalVoteCount];
                NSNumber *second = [NSNumber numberWithInt:obj2.totalVoteCount];
                return [second compare:first];
            }]];

            [_postTableView reloadData];
        }
    }];

}

- (void) voteLastPictures:(HomeLastPicturesTableViewCell *)cell{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:LOGGEDIN]){
        LoginViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        [[SlideNavigationController sharedInstance] pushViewController:vc animated:YES];
        return;
    }
    
    int voteCount = [cell.voteCountLabel.text intValue];
    int index = [_postTableView indexPathForCell:cell].row - 2;
    PFObject *lastPicturesItem = lastPicturesDataArray[index];
    
    NSMutableArray *voteUsersList = [NSMutableArray array];
    if (lastPicturesItem[@"voteUsers"]) {
        [voteUsersList addObjectsFromArray:lastPicturesItem[@"voteUsers"]];
    }
    
    if (!cell.voteButton.selected) {
        cell.voteButton.selected = YES;
        cell.voteCountLabel.text = [NSString stringWithFormat:@"%d",  voteCount + 1 ];
        [voteUsersList addObject:currentUser.objectId];
        [lastPicturesItem setObject:voteUsersList forKey:@"voteUsers"];
        [lastPicturesItem setObject:[NSNumber numberWithInt:[lastPicturesItem[@"totalActionCount"] intValue]+1] forKey:@"totalActionCount"];
        [lastPicturesItem saveEventually];
        
        [self sendNotification:lastPicturesItem kind:NOTIFICATION_KIND_VOTE];
        
    }else{
        if ([cell.voteCountLabel.text intValue]<=0) return;
        
        [voteUsersList removeObject:currentUser.objectId];
        [lastPicturesItem setObject:voteUsersList forKey:@"voteUsers"];
        [lastPicturesItem setObject:[NSNumber numberWithInt:[lastPicturesItem[@"totalActionCount"] intValue]-1] forKey:@"totalActionCount"];
        [lastPicturesItem saveEventually];
        
        cell.voteButton.selected = NO;
        cell.voteCountLabel.text = [NSString stringWithFormat:@"%d",  voteCount - 1 ];
    }
    
}

- (void) shareLastPictures:(HomeLastPicturesTableViewCell *)cell{
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:LOGGEDIN]){
        LoginViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        [[SlideNavigationController sharedInstance] pushViewController:vc animated:YES];
        return;
    }
    
    NSLog(@"Select category");
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle: nil delegate:self cancelButtonTitle:LocalizedString(@"cancel") destructiveButtonTitle:nil otherButtonTitles:LocalizedString(@"share_on_facebook"), LocalizedString(@"share_on_whatsapp"), LocalizedString(@"share_to"), nil];
    
    actionSheetCategory = ACTIONSHEET_SHARE;
    int position = [self.postTableView indexPathForCell:cell].row;
    PFObject *sharePost = lastPicturesDataArray[position - 2];
    PFFile *shareImageFile = (PFFile*) sharePost[@"image"];
    shareImageUrl = shareImageFile.url;
    PFUser *user = sharePost[@"user"];
    sharePostUserName = user.username;
    selectedLastPicturesCell = cell;
    
    [actionSheet setActionSheetStyle:UIActionSheetStyleDefault];
    [actionSheet showInView:self.view];
    
}

- (void) voteMissOfMonth:(HomeMissOfMonthTableViewCell *)cell{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:LOGGEDIN]) return;
    
    int voteCount = [cell.voteCountLabel.text intValue];
    int index = [_postTableView indexPathForCell:cell].row - 2;
    MissOfMonthModel *model = missOfMonthDataArray[index];
    PFObject *missOfMonthItem = model.post;
    
    NSMutableArray *voteUsersList = [NSMutableArray array];
    if (missOfMonthItem[@"voteUsers"]) {
        [voteUsersList addObjectsFromArray:missOfMonthItem[@"voteUsers"]];
    }
    
    if (!cell.voteButton.selected) {
        cell.voteButton.selected = YES;
        cell.voteCountLabel.text = [NSString stringWithFormat:@"%d",  voteCount + 1 ];
        [voteUsersList addObject:currentUser.objectId];
        [missOfMonthItem setObject:voteUsersList forKey:@"voteUsers"];
        [missOfMonthItem setObject:[NSNumber numberWithInt:[missOfMonthItem[@"totalActionCount"] intValue]+1] forKey:@"totalActionCount"];
        [missOfMonthItem saveEventually];
        
        //for notification
        PFObject *notification = [PFObject objectWithClassName:@"Notification"];
        [notification setObject:currentUser forKey:@"fromUser"];
        [notification setObject:missOfMonthItem[@"user"] forKey:@"toUser"];
        [notification saveEventually:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                PFQuery *pushQuery = [PFInstallation query];
                [pushQuery whereKey:@"user" equalTo:missOfMonthItem[@"user"]];
                
                //send push notification to query
                [self sendNotification:missOfMonthItem kind:NOTIFICATION_KIND_VOTE];
            }
        }];
        
    }else{
        if ([cell.voteCountLabel.text intValue]<=0) return;
        
        [voteUsersList removeObject:currentUser.objectId];
        [missOfMonthItem setObject:voteUsersList forKey:@"voteUsers"];
        [missOfMonthItem setObject:[NSNumber numberWithInt:[missOfMonthItem[@"totalActionCount"] intValue]-1] forKey:@"totalActionCount"];
        [missOfMonthItem saveEventually];
        
        cell.voteButton.selected = NO;
        cell.voteCountLabel.text = [NSString stringWithFormat:@"%d",  voteCount - 1 ];
    }
    
}

- (void) shareMissOfMonth:(HomeMissOfMonthTableViewCell *)cell{

    if (![[NSUserDefaults standardUserDefaults] boolForKey:LOGGEDIN]){
        LoginViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        [[SlideNavigationController sharedInstance] pushViewController:vc animated:YES];
        return;
    }
    
    NSLog(@"Select category");
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle: nil delegate:self cancelButtonTitle:LocalizedString(@"cancel") destructiveButtonTitle:nil otherButtonTitles:LocalizedString(@"share_on_facebook"), LocalizedString(@"share_on_whatsapp"), LocalizedString(@"share_to"), nil];
    
    actionSheetCategory = ACTIONSHEET_SHARE;
    int position = [self.postTableView indexPathForCell:cell].row;
    MissOfMonthModel *model = missOfMonthDataArray[position - 2];
    PFFile *shareImageFile = (PFFile*) model.post[@"image"];
    shareImageUrl = shareImageFile.url;
    PFUser *user = model.post[@"user"];
    sharePostUserName = user.username;
    selectedMissOfMonthCell = cell;
    
    [actionSheet setActionSheetStyle:UIActionSheetStyleDefault];
    [actionSheet showInView:self.view];
}

- (void)otherActionOfLastPictures:(HomeLastPicturesTableViewCell *)cell{
    int index = [_postTableView indexPathForCell:cell].row - 2;
    post = lastPicturesDataArray[index];
    
    [self otherAction];
}

- (void)otherActionOfMissOfMonth:(HomeMissOfMonthTableViewCell *)cell{
    int index = [_postTableView indexPathForCell:cell].row - 2;
    MissOfMonthModel *model = missOfMonthDataArray[index];
    post = model.post;
    
    [self otherAction];
}

- (void) otherAction{
    UIActionSheet *actionSheet;
    PFUser *postUser = post[@"user"];
    if (postUser && currentUser && ![postUser.objectId isEqualToString:currentUser.objectId]) {
        actionSheet = [[UIActionSheet alloc] initWithTitle: nil delegate:self cancelButtonTitle:LocalizedString(@"cancel") destructiveButtonTitle:nil otherButtonTitles:LocalizedString(@"report_inappropriate"), nil];
        actionSheetCategory = ACTIONSHEET_REPORT_INAPPROPRIATE;
    }else{
        actionSheet = [[UIActionSheet alloc] initWithTitle: nil delegate:self cancelButtonTitle:LocalizedString(@"cancel") destructiveButtonTitle:nil otherButtonTitles:LocalizedString(@"delete"), nil];
        actionSheetCategory =ACTIONSHEET_DELETE;
    }

    [actionSheet setActionSheetStyle:UIActionSheetStyleDefault];
    [actionSheet showInView:self.view];
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
        if ([AppManager sharedInstance].messageCount>0) {
            [_messageLabel setHidden:FALSE];
        }else{
            [_messageLabel setHidden:TRUE];
        }
        
    }else{
        [_plusButton setHidden:TRUE];
        [_messageButton setHidden:TRUE];
        [_loginButton setHidden:FALSE];
        [_messageLabel setHidden:TRUE];
    }
}

- (void) shareTo{
    NSString *text = @"";
    NSURL *url = [NSURL URLWithString:@"http://themiss.com"];
    
    if (selectedCategory == SELECT_HOME_LASTPICTURES) {
        UIImage *image = selectedLastPicturesCell.postImageView.image;
        
        UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:@[text, url, image] applicationActivities:nil];
        
        [self.navigationController presentViewController:controller animated:YES completion:nil];
        
        [self increaseShareCount];
        
    }else if (selectedCategory == SELECT_HOME_MISSOFMONTH) {
        UIImage *image = selectedMissOfMonthCell.postImageView.image;
        
        UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:@[text, url, image] applicationActivities:nil];
        
        [self.navigationController presentViewController:controller animated:YES completion:nil];
        
        [self increaseShareCount];
    }
}

- (void) increaseShareCount{
    if (selectedCategory == SELECT_HOME_LASTPICTURES) {
        int shareCount = [selectedLastPicturesCell.shareCountLabel.text intValue];
        selectedLastPicturesCell.shareCountLabel.text = [NSString stringWithFormat:@"%d",  shareCount + 1 ];
        
        int index = [_postTableView indexPathForCell:selectedLastPicturesCell].row - 2;
        PFObject *lastPicturesItem = lastPicturesDataArray[index];
        [lastPicturesItem setObject:[NSNumber numberWithInt:shareCount + 1] forKey:@"shareCount"];
        [lastPicturesItem setObject:[NSNumber numberWithInt:[lastPicturesItem[@"totalActionCount"] intValue]+1] forKey:@"totalActionCount"];
        [lastPicturesItem saveEventually];
        
        [self sendNotification:lastPicturesItem kind:NOTIFICATION_KIND_SHARE];
        
    }else if (selectedCategory == SELECT_HOME_MISSOFMONTH) {
        int shareCount = [selectedMissOfMonthCell.shareCountLabel.text intValue];
        selectedMissOfMonthCell.shareCountLabel.text = [NSString stringWithFormat:@"%d",  shareCount + 1 ];
        
        int index = [_postTableView indexPathForCell:selectedMissOfMonthCell].row - 2;
        MissOfMonthModel *model = missOfMonthDataArray[index];
        PFObject *missOfMonthItem = model.post;
        [missOfMonthItem setObject:[NSNumber numberWithInt:shareCount + 1] forKey:@"shareCount"];
        [missOfMonthItem setObject:[NSNumber numberWithInt:[missOfMonthItem[@"totalActionCount"] intValue]+1] forKey:@"totalActionCount"];
        [missOfMonthItem saveEventually];
        
        [self sendNotification:missOfMonthItem kind:NOTIFICATION_KIND_SHARE];
    }
}

- (void) reportFlaggedPicture{
    [_refreshActivityIndicator startAnimating];
    _refreshActivityIndicator.hidden = FALSE;
    _refreshButton.hidden = TRUE;
    
    PFObject *flaggedObject = [PFObject objectWithClassName:@"FlagedPicture"];
    [flaggedObject setObject:post forKey:@"post"];
    [flaggedObject setObject:post[@"user"] forKey:@"user"];
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

- (void) deletePicture{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"confirm_deleting") message:LocalizedString(@"delete_this_picture") delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [alert show];
}

- (void) showProfile:(id)sender{
    ProfileViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    UITapGestureRecognizer *tapRecognizer = (UITapGestureRecognizer*)sender;
    int tag = tapRecognizer.view.tag;
    
    
    if (selectedCategory == SELECT_HOME_LASTPICTURES){
        vc.profileUser = lastPicturesDataArray[tag][@"user"];
        
    }else if(selectedCategory == SELECT_HOME_MISSOFMONTH){
        MissOfMonthModel *model = missOfMonthDataArray[tag];
        vc.profileUser = model.post[@"user"];
        
    }else{      //from winner page
        vc.profileUser = [AppManager sharedInstance].winnerPost[@"user"];
    }
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void) arriveNotification{
    [self displayNotificationWithQuery:_messageLabel];
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
        [post deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                if (selectedCategory == SELECT_HOME_LASTPICTURES) {
                    [self refreshLastPictures];
                }else if(selectedCategory == SELECT_HOME_MISSOFMONTH) {
                    [self refreshMissOfMonth];
                }
            }
        }];
    } else {
        
    }
}

//- (void) addBorderToButton:(UIButton *)button color:(UIColor *)color andWidth:(CGFloat) borderWidth{
//    
//    //add top border
//    CALayer *topBorder = [CALayer layer];
//    topBorder.backgroundColor = color.CGColor;
//    topBorder.frame = CGRectMake(0, 0, button.frame.size.width, borderWidth);
//    [button.layer addSublayer:topBorder];
//    
//    //add bottom border
//    CALayer *bottomBorder = [CALayer layer];
//    bottomBorder.backgroundColor = color.CGColor;
//    bottomBorder.frame = CGRectMake(0, button.frame.size.height-borderWidth, button.frame.size.width, borderWidth);
//    [button.layer addSublayer:bottomBorder];
//
//    //add left border
//    CALayer *leftBorder = [CALayer layer];
//    leftBorder.backgroundColor = color.CGColor;
//    leftBorder.frame = CGRectMake(0, 0, borderWidth, button.frame.size.height);
//    [button.layer addSublayer:leftBorder];
//
//    //add right border
//    CALayer *rightBorder = [CALayer layer];
//    rightBorder.backgroundColor = color.CGColor;
//    rightBorder.frame = CGRectMake(0, button.frame.size.width - borderWidth, borderWidth, button.frame.size.height);
//    [button.layer addSublayer:rightBorder];
//
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
