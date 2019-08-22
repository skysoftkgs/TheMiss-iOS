//
//  InstagramImagePikcerViewController.m
//  TheMiss
//
//  Created by lion on 6/27/14.
//  Copyright (c) 2014 Arsan. All rights reserved.
//

#import "InstagramImagePikcerViewController.h"
#import "InstagramImageCell.h"
#import "UIImageView+AFNetworking.h"
#import "ImportViewController.h"
#import "ImportInsideTableViewController.h"
#import "Constants.h"

#define LIMIT_PHOTO_COUNT 25

@interface InstagramImagePikcerViewController ()
{
    NSMutableArray *imageArray;
    NSString *instagramPhotoNextUrl;
}
@end

@implementation InstagramImagePikcerViewController

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
    
    imageArray = [NSMutableArray array];
    [self loadPhotos];
    
    [self.clnPhotos registerClass:[InstagramImageCell class] forCellWithReuseIdentifier:@"InstagramPhotoCell"];
    
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    
    layout.minimumInteritemSpacing = 0;
    layout.itemSize = CGSizeMake(80, 80);
    layout.minimumLineSpacing = 0;
    
    [self.clnPhotos setCollectionViewLayout:layout animated:YES];

}

- (void) viewDidAppear:(BOOL)animated{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionView datasource & delegate methods

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    InstagramImageCell *objCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"InstagramPhotoCell" forIndexPath:indexPath];
    
   
    [objCell.imageView setImageWithURL:[NSURL URLWithString:imageArray[indexPath.item]]];
    
    if (indexPath.row == imageArray.count - 1 && instagramPhotoNextUrl) {
        [self loadPhotos];
    }
    
    return objCell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return imageArray.count;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    InstagramImageCell *cell = (InstagramImageCell*)[collectionView cellForItemAtIndexPath:indexPath];
    
    NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
    for (int i=[allViewControllers count]-1;i>=0;i--) {
        UIViewController *aViewController = allViewControllers[i];
        if ([aViewController isKindOfClass:[ImportViewController class]]) {
            [self.navigationController popToViewController:aViewController animated:YES];
            ImportInsideTableViewController *vc = [aViewController childViewControllers][0];
            [vc uploadImage:cell.imageView.image rate:1.0f];
            break;
        }
    }
}

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)loadPhotos{
    PFUser *currentUser = [PFUser currentUser];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    if(!instagramPhotoNextUrl){
        instagramPhotoNextUrl = [NSString stringWithFormat:@"%@%@%@%@%@%d", @"https://api.instagram.com/v1/users/",  currentUser[@"instagramID"], @"/media/recent?client_id=", INSTAGRAM_CLIENT_ID, @"&count=", LIMIT_PHOTO_COUNT];
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:instagramPhotoNextUrl]];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Instagram photo result:%@", responseObject);
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        if (!responseObject) {
            return;
        }
        
        NSMutableArray *dataArray = responseObject[@"data"];
        if (!dataArray) {
            return;
        }
        
        for (int i=0; i<dataArray.count; i++) {
            NSString *url = dataArray[i][@"images"][@"standard_resolution"][@"url"];
            [imageArray addObject:url];
        }
        
        NSDictionary *pagination = responseObject[@"pagination"];
        if(pagination){
            instagramPhotoNextUrl = pagination[@"next_url"];
        }else{
            instagramPhotoNextUrl = nil;
        }
        
        [self.clnPhotos reloadData];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Instagram photo error:%@", [error localizedDescription]);
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }];
    [operation start];
}

@end
