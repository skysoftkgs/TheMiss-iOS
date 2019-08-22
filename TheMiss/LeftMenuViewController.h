//
//  MenuViewController.h
//  SlideMenu
//
//  Created by Aryan Gh on 4/24/13.
//  Copyright (c) 2013 Aryan Ghassemi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LeftMenuViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchDisplayDelegate, UISearchBarDelegate, SlideNavigationControllerDelegate>
{
    NSMutableArray *menuArray;
    NSMutableArray *allUsersArray;
    NSMutableArray *displayUsersArray;
    PFUser *currentUser;
    BOOL isSearching;
    BOOL userDataLoaded;
    
    CGRect originalTableViewFrame;
}

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UIView *userHeaderView;
@property (weak, nonatomic) IBOutlet UIView *loginHeaderView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;


@property (nonatomic, assign) BOOL slideOutAnimationEnabled;


- (IBAction)loginWithFacebookAction:(id)sender;
- (IBAction)loginWithMailAction:(id)sender;
@end
