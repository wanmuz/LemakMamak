//
//  OSEditPhotoViewController.h
//  LepakMamak
//
//  Created by Azad Johari on 9/27/13.
//  Copyright (c) 2013 Wan Muzaffar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "OSConstants.h"
@interface OSEditPhotoViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (nonatomic, strong) PFObject *restaurant;
-(id)initWithImage:(UIImage*)aImage;
@end
