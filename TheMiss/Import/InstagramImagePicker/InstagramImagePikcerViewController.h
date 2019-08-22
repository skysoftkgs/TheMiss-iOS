//
//  InstagramImagePikcerViewController.h
//  TheMiss
//
//  Created by lion on 6/27/14.
//  Copyright (c) 2014 Arsan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InstagramImagePikcerViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) IBOutlet UICollectionView *clnPhotos;
- (IBAction)backAction:(id)sender;
@end
