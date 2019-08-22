//
//  FacebookImagePicker.m
//  FavorExchange
//
//  Created by Akshit on 15/02/14.
//  Copyright (c) 2014 Sujal Bandhara. All rights reserved.
//

#import "FacebookAlbumPicker.h"
#import "FacebookImagePicker.h"
#import "UIImageView+AFNetworking.h"


@interface FacebookAlbumPicker ()

@end

@implementation FacebookAlbumPicker

#pragma mark - UIViewController methods

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
    // Do any additional setup after loading the view from its nib.
    
    [MBProgressHUD showMessag:LocalizedString(@"loading") toView:self.view];
    
//    [FBSession openActiveSessionWithPublishPermissions: [NSArray arrayWithObjects: @"user_photos", nil] defaultAudience: FBSessionDefaultAudienceEveryone allowLoginUI:YES completionHandler: ^(FBSession *session,FBSessionState status,NSError *error)
//     {
//         if (error)
//         {
//             [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//             return;
//             
//             NSLog(@"error");
//         }
//         else
//         {
//             [FBSession setActiveSession:session];
//             NSLog(@"LOGIN SUCCESS");
    
             [FBRequestConnection startWithGraphPath:@"me/albums?fields=id,name,count"
                                          parameters:nil
                                          HTTPMethod:@"GET"
                                   completionHandler:^(
                                                       FBRequestConnection *connection, id result, NSError *error)
              {
                  NSLog(@"%@",result);
                  [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                  
                  self.arrayAlbumDetails = result[@"data"];
                  
                  if (self.arrayAlbumDetails.count == 0)
                  {
                      NSLog(@"Either the user does not have any albums or something bad happen.");
                  }
                  else
                  {
                      [self.tblFacebookAlbumList reloadData];
                  }
              }];
             
//         }
//     }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView datasource & delegate methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath;
{
    return 70;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FacebookAlbumCell *objCell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (!objCell)
    {
        objCell = [[[NSBundle mainBundle] loadNibNamed:@"FacebookAlbumCell" owner:self options:nil] objectAtIndex:0];
    }
    
    
    NSString *strURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?access_token=%@",self.arrayAlbumDetails[indexPath.item][@"id"],[[[FBSession activeSession] accessTokenData] accessToken]];
    NSURL *urlPhoto = [NSURL URLWithString:strURL];
    [objCell.imgAlbumCoverPhoto setImageWithURL:urlPhoto];
    
    [objCell.lblAlbumName setText:self.arrayAlbumDetails[indexPath.item][@"name"]];
    
    [objCell.lblPhotoCountInAlbum setText:[[self.arrayAlbumDetails[indexPath.item][@"count"] description] stringByAppendingString:@" Photos"]];
    
    return objCell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arrayAlbumDetails.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FacebookImagePicker *objFBImagePicker = [[FacebookImagePicker alloc] initWithNibName:@"FacebookImagePicker" bundle:nil];
    objFBImagePicker.strAlbumName = self.arrayAlbumDetails[indexPath.item][@"name"];
    objFBImagePicker.intAlreadySelectedImagesCount = self.intAlreadySelectedImagesCount;
    objFBImagePicker.strAlbumID = [self.arrayAlbumDetails[indexPath.item][@"id"] description];
    [self.navigationController pushViewController:objFBImagePicker animated:YES];
}

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
