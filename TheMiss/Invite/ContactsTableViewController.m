//
//  ContactsTableViewController.m
//  TheMiss
//
//  Created by lion on 8/6/14.
//  Copyright (c) 2014 Arsan. All rights reserved.
//

#import "ContactsTableViewController.h"
#import "ContactsTableViewCell.h"
#import <AddressBook/AddressBook.h>
#import <AddressBook/ABAddressBook.h>
#import <AddressBook/ABPerson.h>
#import <MessageUI/MessageUI.h>
#import "Utils.h"

@interface ContactsTableViewController ()<MFMessageComposeViewControllerDelegate>
{
    NSArray *contactsList;
}
@end

@implementation ContactsTableViewController

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
    self.navigationController.navigationBarHidden = FALSE;
    
    contactsList = [NSMutableArray array];
    [self loadAddressBook];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return contactsList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ContactsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactsCell" forIndexPath:indexPath];
    
    NSDictionary *contactDic = contactsList[indexPath.row];
    
    [Utils setRoundView:cell.profileImageView borderColor:[UIColor clearColor]];
    cell.profileImageView.image = contactDic[@"photo"];
    cell.nameLabel.text = contactDic[@"fullname"];
    cell.phoneLabel.text = contactDic[@"phone"];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *contactDic = contactsList[indexPath.row];
    
    MFMessageComposeViewController *vc = [[MFMessageComposeViewController alloc] init];
    if ([MFMessageComposeViewController canSendText]) {
        vc.body = LocalizedString(@"invite_message");
        vc.recipients = [NSArray arrayWithObjects:contactDic[@"phone"], nil];
        vc.messageComposeDelegate = self;
        [self presentViewController:vc animated:YES completion:nil];
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - AddressBook loading -

- (void) loadAddressBook
{
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(nil, nil);
    
    __block BOOL accessGranted = NO;
    
    if (ABAddressBookRequestAccessWithCompletion != NULL) { // we're on iOS 6
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            accessGranted = granted;
            dispatch_semaphore_signal(sema);
        });
        
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }else { // we're on iOS 5 or older
        accessGranted = YES;
    }
    if (accessGranted) {
        [self fetchAddressBook];
        [self.tableView reloadData];
    }
    
}

- (void) fetchAddressBook
{
    ABAddressBookRef UsersAddressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    
    //contains details for all the contacts
    CFArrayRef ContactInfoArray = ABAddressBookCopyArrayOfAllPeople(UsersAddressBook);
    
    //get the total number of count of the users contact
    CFIndex numberofPeople = CFArrayGetCount(ContactInfoArray);
    //iterate through each record and add the value in the array
    
    NSMutableArray *contacts = [NSMutableArray array];
    for (int i =0; i<numberofPeople; i++)
    {
        ABRecordRef ref = CFArrayGetValueAtIndex(ContactInfoArray, i);
        ABMultiValueRef firstName = (__bridge ABMultiValueRef)((__bridge NSString*)ABRecordCopyValue(ref, kABPersonFirstNameProperty));
        ABMultiValueRef lastName = (__bridge ABMultiValueRef)((__bridge NSString*)ABRecordCopyValue(ref, kABPersonLastNameProperty));
        ABMultiValueRef phones =(__bridge ABMultiValueRef)((__bridge NSString*)ABRecordCopyValue(ref, kABPersonPhoneProperty));
        
        NSString *tempFirstName = (__bridge NSString *)(firstName);
        NSString *tempLastName = (__bridge NSString *)(lastName);
        UIImage * image;
        
        
        
        //Compose full name
        NSString *fullName = @"";
        
        if (firstName != nil){
            fullName = [fullName stringByAppendingString:tempFirstName];
            
        }
        if (lastName != nil){
            fullName = [fullName stringByAppendingString:@" "];
            fullName = [fullName stringByAppendingString:tempLastName];
        }
        if (firstName == nil && lastName == nil) {
            fullName = @"No Name";
        }
        
        if (ABPersonHasImageData(ref)) {
            image = [UIImage imageWithData:(__bridge NSData *)(ABPersonCopyImageDataWithFormat(ref, kABPersonImageFormatThumbnail))];
        }else{
            image = [UIImage imageNamed:@"user_female_64"];
        }
        
        
        //For Phone number
        BOOL isPhone = NO;
        NSString* phoneNumber;
        for(CFIndex i = 0; i < ABMultiValueGetCount(phones); i++) {
            phoneNumber = (__bridge NSString*)ABMultiValueCopyLabelAtIndex(phones, i);
            if([phoneNumber isEqualToString:(NSString *)kABPersonPhoneMobileLabel])  {
                phoneNumber = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i);
                isPhone = YES;
                break;
            }  else if ([phoneNumber isEqualToString:(NSString*)kABPersonPhoneIPhoneLabel])  {
                phoneNumber = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i);
                isPhone = YES;
                break;
            }
            
        }
        if (isPhone) {
            //            NSMutableDictionary *oneContactInfo = [[NSMutableDictionary alloc] init];
            NSDictionary *oneContactInfo = @{@"fullname": fullName,
                                             @"photo": image,
                                             @"phone": phoneNumber
                                             };
            NSLog(@"contact : %@", oneContactInfo);
            [contacts addObject:oneContactInfo];
        }
    }
    
    contactsList = [contacts sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSString *first = [a[@"fullname"] lowercaseString];
        NSString *second = [b[@"fullname"] lowercaseString];
        return [first compare:second];
    }];
}

#pragma mark - Send message delegate methods -

- (void)messageComposeViewController:
(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result
{
    switch (result)
    {
        case MessageComposeResultCancelled:
            NSLog(@"Cancelled");
            break;
        case MessageComposeResultFailed:
            NSLog(@"Failed");
            break;
        case MessageComposeResultSent:
            break;
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
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
