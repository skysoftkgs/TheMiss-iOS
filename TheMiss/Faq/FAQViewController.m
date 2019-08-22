//
//  FAQViewController.m
//  TheMiss
//
//  Created by lion on 8/8/14.
//  Copyright (c) 2014 Arsan. All rights reserved.
//

#import "FAQViewController.h"
#import "Utils.h"
#import "Constants.h"

@interface FAQViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    int selectedIndex;
    NSArray *titleArray;
    NSArray *contentArray;
}
@end

@implementation FAQViewController

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
    
    titleArray = [NSArray arrayWithObjects:LocalizedString(@"faq_topic1"),
                                        LocalizedString(@"faq_topic2"),
                                        LocalizedString(@"faq_topic3"),
                                        LocalizedString(@"faq_topic4"),
                                        LocalizedString(@"faq_topic5"),
                                        LocalizedString(@"faq_topic6"),
                                        LocalizedString(@"faq_topic7"), nil];
    
    contentArray = [NSArray arrayWithObjects:LocalizedString(@"faq_content1"),
                                        LocalizedString(@"faq_content2"),
                                        LocalizedString(@"faq_content3"),
                                        LocalizedString(@"faq_content4"),
                                        LocalizedString(@"faq_content5"),
                                        LocalizedString(@"faq_content6"),
                                        LocalizedString(@"faq_content7"), nil];
    
    selectedIndex = -1;
    
    [self setLoginStatus];
    [self.tableView reloadData];
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

- (void)viewWillDisappear:(BOOL)animated{
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

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)loginAction:(id)sender {
    [self loginMenuButtonAction];
}

- (IBAction)messageAction:(id)sender {
    [self messageMenuButtonAction];
}

- (IBAction)plusAction:(id)sender {
    [self plusMenuButtonAction];
}

#pragma mark - UITableView Delegate Methods -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 7;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    NSString *str;
    if (indexPath.row == selectedIndex) {
        str = [NSString stringWithFormat:@"%@\n\n%@", titleArray[indexPath.row], contentArray[indexPath.row]];
        
    }else{
        str = titleArray[indexPath.row];
    }

    return [Utils heightOfTextForString:str andFont:[UIFont systemFontOfSize:14] maxSize:CGSizeMake(self.tableView.frame.size.width - 40, 9000)] + 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *FAQCellIdentifier = @"FAQCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:FAQCellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FAQCellIdentifier];
    }
    
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    
    if (indexPath.row == selectedIndex) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@\n\n%@", titleArray[indexPath.row], contentArray[indexPath.row]];
        cell.contentView.backgroundColor = [UIColor whiteColor];
    }else{
        cell.textLabel.text = titleArray[indexPath.row];
        cell.contentView.backgroundColor = UIColorFromRGB(0xd0d0d0);
    }
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    selectedIndex = indexPath.row;
    [self.tableView reloadData];
}

#pragma mark - internal methods - 

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

- (void) arriveNotification{
    [self displayNotificationWithQuery:_messageLabel];
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
