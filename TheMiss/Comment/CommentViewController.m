//
//  CommentViewController.m
//  TheMiss
//
//  Created by lion on 7/12/14.
//  Copyright (c) 2014 Arsan. All rights reserved.
//

#import "CommentViewController.h"
#import "LoginViewController.h"
#import "CommentPostTableViewCell.h"
#import "CommentTableViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "YFInputBar.h"
#import "Utils.h"
#import "Constants.h"

@interface CommentViewController ()<UITableViewDataSource, UITableViewDelegate, YFInputBarDelegate, UIActionSheetDelegate, UIDocumentInteractionControllerDelegate>
{
    NSMutableArray *commentDataArray;
    PFUser *currentUser;
    BOOL refreshingComment;
    int commentCount;
    int voteCount;
    int shareCount;
    BOOL isVoted;
    
    NSString *shareImageUrl;
}

@end

@implementation CommentViewController

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
    [self initInputBar];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnTableView:)];
    [_tableView addGestureRecognizer:tap];
    
    //init values
    currentUser = [PFUser currentUser];
   
    if(_post[@"voteUsers"]){
        NSMutableArray *voteUsersList = _post[@"voteUsers"];
        voteCount = voteUsersList.count;
    }else{
        voteCount = 0;
    }
    
    shareCount = [_post[@"shareCount"] intValue];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:LOGGEDIN] && [_post[@"voteUsers"] containsObject:currentUser.objectId]) {
        isVoted = TRUE;
    }else{
        isVoted = FALSE;
    }
    
    [self refreshComment];
}

- (void) viewWillAppear:(BOOL)animated{
    [self displayNotificationWithoutQuery:_messageLabel];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(arriveNotification) name:LOCAL_NOTIFICATION_DISPLAY_NOTIFICATION object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:LOCAL_NOTIFICATION_DISPLAY_NOTIFICATION object:nil];
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

#pragma mark - internal methods -

-(void)initInputBar{
    YFInputBar *inputBar = [[YFInputBar alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY([UIScreen mainScreen].bounds)-50, 320, 50)];
    
    inputBar.backgroundColor = UIColorFromRGB(0x8f8f8f);
    
    inputBar.delegate = self;
    inputBar.clearInputWhenSend = YES;
    inputBar.resignFirstResponderWhenSend = YES;
    
    [self.view addSubview:inputBar];
    
    //if not logged in, hide inputbar
    if (![[NSUserDefaults standardUserDefaults] boolForKey:LOGGEDIN]) {
        inputBar.hidden = TRUE;
        self.tableView.frame = CGRectMake(0, 64, 320, self.view.frame.size.height - 64);
    }
    
    [self refreshComment];
}

- (void)refreshComment{
    if (refreshingComment) {
        return;
    }
    refreshingComment = TRUE;
    _activityIndicator.hidden = FALSE;
    [_activityIndicator startAnimating];
    _refreshButton.hidden = TRUE;
    
    PFQuery *query = [PFQuery queryWithClassName:@"Comment"];
    [query whereKey:@"post" equalTo:_post];
    [query includeKey:@"commenter"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects) {
            commentDataArray = [NSMutableArray array];
            [commentDataArray addObjectsFromArray:objects];
            
            commentCount = [commentDataArray count];
            
            [self.tableView reloadData];
        }
        
        refreshingComment = FALSE;
        _activityIndicator.hidden = TRUE;
        [_activityIndicator stopAnimating];
        _refreshButton.hidden = FALSE;
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

- (void) arriveNotification{
    [self displayNotificationWithQuery:_messageLabel];
}

- (void) shareTo{
    NSString *text = @"";
    NSURL *url = [NSURL URLWithString:@"http://themiss.com"];
    CommentPostTableViewCell *cell = (CommentPostTableViewCell*)[self.tableView cellForRowAtIndexPath:0];
    UIImage *image = cell.postImageView.image;
    
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:@[text, url, image] applicationActivities:nil];
    
    [self.navigationController presentViewController:controller animated:YES completion:nil];
    
    [self increaseShareCount];
}

- (void) increaseShareCount{
    CommentPostTableViewCell *cell = (CommentPostTableViewCell*)[self.tableView cellForRowAtIndexPath:0];
    cell.shareCountLabel.text = [NSString stringWithFormat:@"%d",  shareCount + 1 ];
    
    [_post setObject:[NSNumber numberWithInt:shareCount + 1] forKey:@"shareCount"];
    [_post setObject:[NSNumber numberWithInt:[_post[@"totalActionCount"] intValue]+1] forKey:@"totalActionCount"];
    [_post saveEventually];
    
    [self sendNotification:_post kind:NOTIFICATION_KIND_SHARE];
}

#pragma mark - UITableView Delegate Methods -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return commentDataArray.count + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    switch (indexPath.row) {
        case 0:
            return 430;
            break;
            
        default:
            return 60;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {   //display post view
        static NSString *CommentPostCellIdentifier = @"CommentPostCell";
        CommentPostTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CommentPostCellIdentifier];
        
        PFFile* imageFile = _post[@"image"];
        if (imageFile) {
            NSString *postImage = imageFile.url;
            [cell.postImageView setImageWithURL:[NSURL URLWithString:postImage]];
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
        cell.dateLabel.text = [[dateFormat stringFromDate:_post.createdAt] capitalizedString];
        
        cell.userNameLabel.text = _profileUser.username;
        
        PFFile *profileImageFile = _profileUser[@"profileImage"];
        if (profileImageFile) {
            [cell.profileImageView setImageWithURL:[NSURL URLWithString:profileImageFile.url]];
        }
        
        cell.shareCountLabel.text = [NSString stringWithFormat:@"%d", shareCount];
        cell.voteCountLabel.text = [NSString stringWithFormat:@"%d", voteCount];
        cell.commentCountLabel.text = [NSString stringWithFormat:@"%d", commentCount];
        
        //display comment status
        if ([[NSUserDefaults standardUserDefaults] boolForKey:LOGGEDIN] && _profileUser){
            if ([_post[@"commentUsers"] containsObject:currentUser.objectId]) {
                cell.commentButton.selected = TRUE;
            }else{
                cell.commentButton.selected = FALSE;
            }
        }
        
        //display vote status
        if ([[NSUserDefaults standardUserDefaults] boolForKey:LOGGEDIN] && _profileUser){
            if (isVoted) {
                cell.voteButton.selected = TRUE;
            }else{
                cell.voteButton.selected = FALSE;
            }
        }
        
        return cell;
        
    }else if (indexPath.row >= 1){
        static NSString *CommentCellIdentifier = @"CommentCell";
        CommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CommentCellIdentifier];
        
        PFObject *commentObject = commentDataArray[indexPath.row - 1];
        
        PFUser *commenter = commentObject[@"commenter"];
        PFFile *profileImageFile = commenter[@"profileImage"];
        if (profileImageFile) {
            [cell.profileImageView setImageWithURL:[NSURL URLWithString:profileImageFile.url]];
        }else{
            cell.profileImageView.image = [UIImage imageNamed:@"user_female_256.png"];
        }
        [Utils setRoundView:cell.profileImageView borderColor:[UIColor clearColor]];
        
        cell.userNameLabel.text = [NSString stringWithFormat:@"%@  %@", commenter.username, commentObject[@"comment"]];
        
        //display comment date
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"dd MMM HH:mm"];
        cell.commentLabel.text = [df stringFromDate:commentObject.createdAt];
        
        return cell;
    }
    
    return nil;
}

#pragma mark - YFInputBarDelegate Methods

-(void)inputBar:(YFInputBar *)inputBar sendBtnPress:(UIButton *)sendBtn withInputString:(NSString *)str
{
    NSLog(@"%@",str);
    if (!str || str.length <=0) {
        return;
    }
    
    [MBProgressHUD showMessag:@"Saving" toView:self.view];
    
    PFObject *commentObject = [PFObject objectWithClassName:@"Comment"];
    commentObject[@"commenter"] = currentUser;
    commentObject[@"post"] = _post;
    commentObject[@"comment"] = str;
    
    [commentObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        //        [_commentButton setUserInteractionEnabled:YES];
        //        _commentTextField.text = @"";
        
        if (succeeded) {
            NSMutableArray *commentUsersList = _post[@"commentUsers"];
            if (!commentUsersList) {
                commentUsersList = [NSMutableArray array];
            }
            
            [commentUsersList addObject:currentUser.objectId];
            [_post setObject:commentUsersList forKey:@"commentUsers"];
            [_post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                    
                    [self refreshComment];
                    [self sendNotification:_post kind:NOTIFICATION_KIND_COMMENT];
                }
            }];
            
        }
    }];
}

-(void) didTapOnTableView:(UIGestureRecognizer*)recognizer{
    [self.view.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [((UIView*)obj) resignFirstResponder];
    }];
}

#pragma mark - ViewController action methods -

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)loginAction:(id)sender {
    [self loginMenuButtonAction];
}

- (IBAction)refreshAction:(id)sender {
    [self refreshComment];
}

- (IBAction)messageAction:(id)sender {
    [self messageMenuButtonAction];
}

- (IBAction)plusAction:(id)sender {
    [self plusMenuButtonAction];
}

- (IBAction)voteAction:(id)sender {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:LOGGEDIN]) return;
    
    NSMutableArray *voteUsersList = [NSMutableArray array];
    
    if (_post[@"voteUsers"]) {
        [voteUsersList addObjectsFromArray:_post[@"voteUsers"]];
    }
    
    if (!isVoted) {
        isVoted = TRUE;
        voteCount++;
        [voteUsersList addObject:currentUser.objectId];
        [_post setObject:voteUsersList forKey:@"voteUsers"];
        [_post setObject:[NSNumber numberWithInt:[_post[@"totalActionCount"] intValue]+1] forKey:@"totalActionCount"];
        [_post saveEventually];
        
        //for notification
        PFObject *notification = [PFObject objectWithClassName:@"Notification"];
        [notification setObject:currentUser forKey:@"fromUser"];
        [notification setObject:_post[@"user"] forKey:@"toUser"];
        [notification saveEventually:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                PFQuery *pushQuery = [PFInstallation query];
                [pushQuery whereKey:@"user" equalTo:_post[@"user"]];
                
                //send push notification to query
                [self sendNotification:_post kind:NOTIFICATION_KIND_VOTE];
            }
        }];
        
    }else{
        if (voteCount<=0) return;
        
        [voteUsersList removeObject:currentUser.objectId];
        [_post setObject:voteUsersList forKey:@"voteUsers"];
        [_post setObject:[NSNumber numberWithInt:[_post[@"totalActionCount"] intValue]-1] forKey:@"totalActionCount"];
        [_post saveEventually];
        
        isVoted = FALSE;
        voteCount--;
    }
    
    [self.tableView reloadData];

}

- (IBAction)shareAction:(id)sender {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:LOGGEDIN]){
        LoginViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        [[SlideNavigationController sharedInstance] pushViewController:vc animated:YES];
        return;
    }
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle: nil delegate:self cancelButtonTitle:LocalizedString(@"cancel") destructiveButtonTitle:nil otherButtonTitles:LocalizedString(@"share_on_facebook"), LocalizedString(@"share_on_whatsapp"), LocalizedString(@"share_to"), nil];
    
    [actionSheet setActionSheetStyle:UIActionSheetStyleDefault];
    [actionSheet showInView:self.view];
}

#pragma mark - UIActionSheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    PFFile *shareImageFile = _post[@"image"];
    shareImageUrl = shareImageFile.url;
    
    if (buttonIndex == 0) {
        NSString *message = [NSString stringWithFormat:@"%@ %@ %@", LocalizedString(@"share_message_first"),
                             _profileUser.username, LocalizedString(@"share_message_end")];
        [self shareWithFacebook:[FBSession activeSession] message:message imageUrl:shareImageUrl userName:_profileUser.username];
        
    } else if (buttonIndex == 1) {
        [self shareWithWhatsapp:shareImageUrl];
    } else if (buttonIndex == 2) {
        [self shareTo];
    }

}

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
