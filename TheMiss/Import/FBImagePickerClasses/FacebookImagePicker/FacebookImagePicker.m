//
//  FacebookImagePicker.m
//  FavorExchange
//
//  Created by Akshit on 17/02/14.
//  Copyright (c) 2014 Sujal Bandhara. All rights reserved.
//

#import "FacebookImagePicker.h"
#import "FacebookImageCell.h"
#import "UIImageView+AFNetworking.h"
#import "ImportViewController.h"
#import "ImportInsideTableViewController.h"

#define LIMIT_PHOTO_COUNT 50

@interface FacebookImagePicker ()
{
    int currentPage;
    BOOL loadingMore;
    BOOL hasMorePhotos;
}
@end

@implementation FacebookImagePicker

@synthesize arrayFacebookImagesForAlbum;

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
    
    currentPage = 0;
    hasMorePhotos = TRUE;
    self.arrayFacebookImagesForAlbum = [NSMutableArray array];
    
    [self loadMorePhotos];
    
    [self setTitle:self.strAlbumName];
    
    [self.clnPhotos registerClass:[FacebookImageCell class] forCellWithReuseIdentifier:@"FacebookImageCell"];
    
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    
    layout.minimumInteritemSpacing = 0;
    layout.itemSize = CGSizeMake(80, 80);
    layout.minimumLineSpacing = 0;
    
    [self.clnPhotos setCollectionViewLayout:layout animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionView datasource & delegate methods

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FacebookImageCell *objCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FacebookImageCell" forIndexPath:indexPath];
    
    [objCell.imageView setImageWithURL:[NSURL URLWithString:self.arrayFacebookImagesForAlbum[indexPath.item][@"source"]]];
    
    if (indexPath.row == self.arrayFacebookImagesForAlbum.count - 1) {
        if (!loadingMore && hasMorePhotos && currentPage > 0) {
            [self loadMorePhotos];
        }
    }
    
    return objCell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.arrayFacebookImagesForAlbum.count;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    FacebookImageCell *cell = (FacebookImageCell*)[collectionView cellForItemAtIndexPath:indexPath];
    
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

- (void) loadMorePhotos{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    loadingMore = TRUE;
    
    NSDictionary *params = @{@"offset":[NSString stringWithFormat:@"%d",currentPage*LIMIT_PHOTO_COUNT],
                             @"limit":[NSString stringWithFormat:@"%d", LIMIT_PHOTO_COUNT]};
    
    [FBRequestConnection startWithGraphPath:[self.strAlbumID stringByAppendingString:@"/photos"]
                                 parameters:params
                                 HTTPMethod:@"GET"
                          completionHandler:^(
                                              FBRequestConnection *connection, id result, NSError *error)
     {
         NSLog(@"%@",result);
         loadingMore = FALSE;
         [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
         currentPage++;
         
         NSArray *morePhotoArray = result[@"data"];
         if (morePhotoArray && morePhotoArray.count > 0) {
             [self.arrayFacebookImagesForAlbum addObjectsFromArray:morePhotoArray];
         }
         
         if (morePhotoArray && morePhotoArray.count  == LIMIT_PHOTO_COUNT) {
             hasMorePhotos = TRUE;
         }else{
             hasMorePhotos = FALSE;
         }
         
         if (self.arrayFacebookImagesForAlbum.count == 0)
         {
             NSLog(@"Either the user does not have any photos in selected album or something bad happen.");
             
         }
         else
         {
             [self.clnPhotos reloadData];
         }
     }];

}

@end
