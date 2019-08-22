//
//  FacebookImagePicker.h
//  FavorExchange
//
//  Created by Akshit on 17/02/14.
//  Copyright (c) 2014 Sujal Bandhara. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FacebookImagePicker : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>

/**
 *  Contains photos list for Facebook album
 */
@property (strong, nonatomic) NSMutableArray *arrayFacebookImagesForAlbum;

/**
 *  Tells that how many images are already selected for Adding in Exchange Card
 */
@property (assign, readwrite) int intAlreadySelectedImagesCount;

/**
 *  Contains Facebook album's name
 */
@property (strong, nonatomic) NSString *strAlbumName;

/**
 *  Contains Facebook album's ID
 */
@property (strong, nonatomic) NSString *strAlbumID;

/**
 *  Contains Photos from Facebook Album
 */
@property (strong, nonatomic) IBOutlet UICollectionView *clnPhotos;


/**
 *  Contains Currently selected Photos from Facebook Album
 */
@property (strong, nonatomic) NSMutableArray *arraySelectedPhotos;

- (IBAction)backAction:(id)sender;

@end
