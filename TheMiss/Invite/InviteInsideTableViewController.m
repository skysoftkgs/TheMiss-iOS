//
//  InviteInsideTableViewController.m
//  TheMiss
//
//  Created by lion on 7/12/14.
//  Copyright (c) 2014 Arsan. All rights reserved.
//

#import "InviteInsideTableViewController.h"
#import "InviteViewController.h"
#import "ContactsTableViewController.h"
#import "SettingsViewController.h"
#import "Constants.h"

@interface InviteInsideTableViewController ()

@end

@implementation InviteInsideTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void) viewWillAppear:(BOOL)animated{
    FBSession *session = [FBSession activeSession];
    PFUser *currentUser = [PFUser currentUser];
    
    if (currentUser[@"facebookID"] && session && [session isOpen]) {
        _connectedLabel.text = [NSString stringWithFormat:@"%@ %@", LocalizedString(@"connected_as"), currentUser.username ];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	switch (indexPath.section)
	{
		case 0:    //Facebook
        {
            [self inviteFacebookFriends];
            break;
        }
            
        case 1:    //Whatsapp
        {
            InviteViewController *vc = (InviteViewController*) self.parentViewController;
            [vc shareWithWhatsapp:nil];
            break;
        }
            
        case 2:    //Contacts
        {
            ContactsTableViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ContactsTableViewController"];
            [self.navigationController pushViewController:vc animated:YES];
            
 			break;
        }
            
        case 3:    //Invite with
        {
            [self shareTo];
            break;
        }
    }
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

#pragma mark - internal methods - 

- (void) shareTo{
    NSString *text = LocalizedString(@"invite_message");
    UIImage *image = [UIImage imageNamed:@"app_icon.png"];
    
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:@[text, image] applicationActivities:nil];
    [controller setValue:LocalizedString(@"invite_subject") forKeyPath:@"subject"];
    [self.navigationController presentViewController:controller animated:YES completion:nil];
}

- (void) inviteFacebookFriends{
    PFUser *currentUser = [PFUser currentUser];
    FBSession *session = [FBSession activeSession];
    if (!currentUser[@"facebookID"] || !session || ![session isOpen]) {
        SettingsViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingsViewController"];
        vc.scrollToEnd = TRUE;
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    
    [FBWebDialogs presentRequestsDialogModallyWithSession:[FBSession activeSession]
                                                  message:@"Send Request"
                                                    title:nil
                                               parameters:nil
                                                  handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                      if (error) {
                                                          // Case A: Error launching the dialog or sending request.
                                                          NSLog(@"Error sending request.");
                                                      } else {
                                                          if (result == FBWebDialogResultDialogNotCompleted) {
                                                              // Case B: User clicked the "x" icon
                                                              NSLog(@"User canceled request.");
                                                          } else {
                                                              NSLog(@"Request Sent.");
                                                              
                                                              [MBProgressHUD showSuccess:@"Request Sent." toView:self.view];
                                                          }
                                                      }}];
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

@end
