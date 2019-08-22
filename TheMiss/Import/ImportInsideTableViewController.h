//
//  ImportInsideTableViewController.h
//  TheMiss
//
//  Created by lion on 6/24/14.
//  Copyright (c) 2014 Arsan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImportInsideTableViewController : UITableViewController

@property (strong, nonatomic) IBOutlet UILabel *connectedLabel;
- (void) uploadImage:(UIImage *)image rate:(float)compressRate;
@end
