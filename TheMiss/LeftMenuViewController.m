//
//  MenuViewController.m
//  SlideMenu
//
//  Created by Aryan Gh on 4/24/13.
//  Copyright (c) 2013 Aryan Ghassemi. All rights reserved.
//

#import "LeftMenuViewController.h"
#import "ProfileViewController.h"
#import "MailLoginViewController.h"
#import "LoginViewController.h"
#import "SlideNavigationContorllerAnimatorFade.h"
#import "SlideNavigationContorllerAnimatorSlide.h"
#import "SlideNavigationContorllerAnimatorScale.h"
#import "SlideNavigationContorllerAnimatorScaleAndFade.h"
#import "SlideNavigationContorllerAnimatorSlideAndFade.h"
#import "UIImageView+AFNetworking.h"
#import "LeftMenuUserTableViewCell.h"
#import "Utils.h"
#import "Constants.h"

@implementation LeftMenuViewController

#pragma mark - UIViewController Methods -

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self.slideOutAnimationEnabled = YES;
	
	return [super initWithCoder:aDecoder];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.tableView.separatorColor = [UIColor lightGrayColor];
    originalTableViewFrame = self.tableView.frame;
	
//	UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"leftMenu.jpg"]];
//	self.tableView.backgroundView = imageView;
	
	self.view.layer.borderWidth = 0.6f;
	self.view.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
//    //load user data
//    if (!allUsersArray) {
//        [self loadUsers];
//    }
    
    //show current user profile
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showProfile)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired =1;
    [_userNameLabel addGestureRecognizer:tap];
    
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showProfile)];
    tap1.numberOfTapsRequired = 1;
    tap1.numberOfTouchesRequired =1;
    [_profileImageView addGestureRecognizer:tap1];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasHidden:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];

    
}

- (void) viewDidUnload{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidHideNotification
                                                  object:nil];
}

- (void) viewWillAppear:(BOOL)animated{
    
    [self loadUsers];
    
    currentUser = [PFUser currentUser];
    
    //display user name and profile image
    if ([[NSUserDefaults standardUserDefaults] boolForKey:LOGGEDIN]) {
        PFFile *profileImageFile = (PFFile*) currentUser[@"profileImage"];
        [Utils setRoundView:_profileImageView borderColor:[UIColor clearColor]];
        if (profileImageFile) {
            [_profileImageView setImageWithURL:[NSURL URLWithString:profileImageFile.url]];
        }else{
            if (currentUser[@"gender"] && [[currentUser[@"gender"] lowercaseString] isEqualToString:@"female"]) {
                _profileImageView.image = [UIImage imageNamed:@"user_female_256"];
            }else{
                _profileImageView.image = [UIImage imageNamed:@"user_male_256"];
            }
            
        }
        _userNameLabel.text = currentUser.username;
        _userHeaderView.hidden = FALSE;
        _loginHeaderView.hidden = TRUE;
        
        menuArray = [[NSMutableArray alloc] initWithObjects:
                     LocalizedString(@"import_pictures"),
                     LocalizedString(@"invite_friends"),
                     LocalizedString(@"settings"),
                     LocalizedString(@"the_contest"),
                     LocalizedString(@"prizes"),
                     LocalizedString(@"tutorial"),
                     LocalizedString(@"rules_and_privacy"),
                     LocalizedString(@"help"),
                     LocalizedString(@"faq"),
                     LocalizedString(@"contacts"),
                     nil];

        
    }else{
        _userHeaderView.hidden = TRUE;
        _loginHeaderView.hidden = FALSE;
        
        menuArray = [[NSMutableArray alloc] initWithObjects:
                     LocalizedString(@"the_contest"),
                     LocalizedString(@"prizes"),
                     LocalizedString(@"tutorial"),
                     LocalizedString(@"rules_and_privacy"),
                     LocalizedString(@"help"),
                     LocalizedString(@"faq"),
                     LocalizedString(@"contacts"),
                     nil];

    }
    
    //if male, remove "Import Pictures"
    if (currentUser && currentUser[@"gender"]) {
        if ([[currentUser[@"gender"] lowercaseString] isEqualToString:@"female"]) {
            
        }else{
            [menuArray removeObject:LocalizedString(@"import_pictures")];
        }
    }
    
    [self.tableView reloadData];
    
}

- (void) filterForSearchText:(NSString*)searchStr{
    displayUsersArray = [[NSMutableArray alloc] init];

    if (!allUsersArray) {
        return;
    }
    
    for (PFUser *user in allUsersArray) {
        NSRange prefixRange = [user.username rangeOfString:searchStr options: NSCaseInsensitiveSearch];
        NSLog(@"%@", user.username);
        
        if (prefixRange.location != NSNotFound) {
            [displayUsersArray addObject:user];
        }
    }
}

#pragma mark - SearchBar delegate Methods -

- (void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    NSLog(@"Text change - %d", isSearching);
    if (searchText.length>0) {
        isSearching = YES;
        [self filterForSearchText:searchText];
    }else{
        isSearching = NO;
    }
    
    [self.tableView reloadData];
}

- (void) searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    NSLog(@"Cancel clicked");
    searchBar.text = @"";
    isSearching = NO;
    [self.tableView reloadData];
    [searchBar resignFirstResponder];
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    NSLog(@"Search Clicked");
    if (searchBar.text.length>0) {
        isSearching = YES;
    }else{
        isSearching = NO;
    }
    [searchBar resignFirstResponder];
}

#pragma mark - UITableView Delegate & Datasrouce -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (isSearching) {
        return displayUsersArray.count;
    }else{
        
        return [menuArray count];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath;
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!isSearching) {
        NSString *menuCellIdentifier = @"leftMenuCell";
    
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:menuCellIdentifier];
        if(cell == nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:menuCellIdentifier];
        }
        
        cell.textLabel.text = menuArray[indexPath.row];
        
        if ([cell.textLabel.text isEqualToString:LocalizedString(@"account")] ||
            [cell.textLabel.text isEqualToString:LocalizedString(@"the_contest")]||
            [cell.textLabel.text isEqualToString:LocalizedString(@"help")]) {
            cell.textLabel.textColor = UIColorFromRGB(MAIN_RED_COLOR);
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }else{
            cell.textLabel.textColor = [UIColor blackColor];
        }
        
        cell.backgroundColor = [UIColor clearColor];
        
        return cell;
        
    }else{
        
        NSString *userCellIdentifier = @"LeftMenuUserCell";
        
        LeftMenuUserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:userCellIdentifier];
        if(cell == nil){
            cell = [[LeftMenuUserTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:userCellIdentifier];
        }
        
        PFUser *user = displayUsersArray[indexPath.row];
        
        cell.userNameLabel.text = user.username;
        if (user[@"gender"] && [user[@"gender"] isEqualToString:@"male"]) {
            cell.userNameLabel.textColor = [UIColor blackColor];
        }else{
            cell.userNameLabel.textColor = UIColorFromRGB(MAIN_RED_COLOR);
        }
        
        PFFile *profileImageFile = user[@"profileImage"];
        if (profileImageFile) {
            [cell.profileImageView setImageWithURL:[NSURL URLWithString:profileImageFile.url]];
        } else{
            cell.profileImageView.image = [UIImage imageNamed:@"user_female_256.png"];
        }
        
        [Utils setRoundView:cell.profileImageView borderColor:[UIColor clearColor]];
        
//        cell.backgroundColor = [UIColor clearColor];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone"
															 bundle: nil];
	
	UIViewController *vc ;
    
    if (!isSearching) {
        if ([menuArray[indexPath.row] isEqualToString:LocalizedString(@"invite_friends")]) {
            vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"InviteViewController"];
            
        } else if ([menuArray[indexPath.row] isEqualToString:LocalizedString(@"import_pictures")]) {
            vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"ImportViewController"];
            
        } else if ([menuArray[indexPath.row] isEqualToString:LocalizedString(@"settings")]) {
            if ([currentUser[@"admin"] intValue] == 1) {
                vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"AdminSettingsViewController"];
            }else{
                vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"SettingsViewController"];
            }
            
        } else if ([menuArray[indexPath.row] isEqualToString:LocalizedString(@"notifications")]) {
            vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"NotificationViewController"];
            
        } else if ([menuArray[indexPath.row] isEqualToString:LocalizedString(@"prizes")]) {
            vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"PrizesViewController"];
            
        } else if ([menuArray[indexPath.row] isEqualToString:LocalizedString(@"tutorial")]) {
            vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"TutorialViewController"];
            
        } else if ([menuArray[indexPath.row] isEqualToString:LocalizedString(@"rules_and_privacy")]) {
            vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"RulesViewController"];
            
        } else if ([menuArray[indexPath.row] isEqualToString:LocalizedString(@"faq")]) {
            vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"FAQViewController"];
            
        } else if ([menuArray[indexPath.row] isEqualToString:LocalizedString(@"contacts")]) {
            vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"ContactsViewController"];
            
        } else
            return;
        
        [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:vc
                                                                 withSlideOutAnimation:self.slideOutAnimationEnabled
                                                                         andCompletion:nil];
    
    } else {

        ProfileViewController *vc1 = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
        vc1.profileUser = displayUsersArray[indexPath.row];
        [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:vc1
                                                                 withSlideOutAnimation:self.slideOutAnimationEnabled
                                                                         andCompletion:nil];
    }
    
    [self.view endEditing:YES];
}

- (IBAction)loginWithFacebookAction:(id)sender {
    [LoginViewController loginWithFacebook:self.view];
}

- (IBAction)loginWithMailAction:(id)sender {
    MailLoginViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MailLoginViewController"];
    [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:vc withSlideOutAnimation:YES andCompletion:nil];
}

#pragma mark - internal methods - 

- (void) loadUsers{
    PFQuery *query = [PFUser query];
    [query orderByAscending:@"username"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            allUsersArray = [[NSMutableArray alloc] init];
            for (PFUser *user in objects) {
                if (user[@"loggedInWay"]) {
                    [allUsersArray addObject:user];
                }
            }
            
            userDataLoaded = TRUE;
        }
    }];
}

- (void) showProfile{
    ProfileViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    vc.profileUser = [PFUser currentUser];
    [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:vc
                                                             withSlideOutAnimation:self.slideOutAnimationEnabled
                                                                     andCompletion:nil];
}

- (void)keyboardWasShown:(NSNotification *)notification
{
    // Get the size of the keyboard.
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    //Given size may not account for screen rotation
    int height = MIN(keyboardSize.height,keyboardSize.width);
    CGRect frame = originalTableViewFrame;
    frame.size.height -= height;
    _tableView.frame = frame;
}

- (void)keyboardWasHidden:(NSNotification *)notification
{
    _tableView.frame = originalTableViewFrame;
}


#pragma mark - SlideNavigationController Methods -

- (void)slideNavigationControllerShouldCloseMenu
{
	_searchBar.text = @"";
    isSearching = NO;
    [self.tableView reloadData];
    [self.view endEditing:YES];
}

@end
