//
//  OSDetailViewController.h
//  LepakMamak
//
//  Created by Azad Johari on 9/15/13.
//  Copyright (c) 2013 Wan Muzaffar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "OSHeaderView.h"
#import "OSCache.h"
#import "OSUtility.h"
#import <MobileCoreServices/MobileCoreServices.h> 
#import "OSEditPhotoViewController.h"
#import "KIImagePager.h"
#import "OSBaseTextCell.h"

@interface OSDetailViewController : PFQueryTableViewController<UITextFieldDelegate, OSHeaderViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, strong) PFObject *restaurant;
@property (weak, nonatomic) IBOutlet KIImagePager *imagePager;

- (IBAction)cameraButtonPressed:(id)sender;

@end
