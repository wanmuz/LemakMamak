//
//  OSEditPhotoViewController.m
//  LepakMamak
//
//  Created by Azad Johari on 9/27/13.
//  Copyright (c) 2013 Wan Muzaffar. All rights reserved.
//

#import "OSEditPhotoViewController.h"
#import "UIImage+ResizeAdditions.h"

@interface OSEditPhotoViewController ()
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign) UIBackgroundTaskIdentifier fileUploadBackgroundTaskId;
@property (nonatomic, assign) UIBackgroundTaskIdentifier photoPostBackgroundTaskId;
@property (nonatomic, strong) PFFile *photoFile;
@property (nonatomic, strong) PFFile *thumbnailFile;

@end

@implementation OSEditPhotoViewController
@synthesize image;
@synthesize fileUploadBackgroundTaskId;
@synthesize photoPostBackgroundTaskId;
@synthesize photoFile;
@synthesize thumbnailFile;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(id)initWithImage:(UIImage*)aImage{
    self = [super init];
    if(self){
        if(!aImage){
            return nil;
        }
        self.image = aImage;
        self.fileUploadBackgroundTaskId = UIBackgroundTaskInvalid;
        self.photoPostBackgroundTaskId = UIBackgroundTaskInvalid;
    }
    return self;
}
- (void)viewDidLoad
{
    [self shouldUploadImage:self.image];
    [self.confirmButton addTarget:self action:@selector(doneButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)shouldUploadImage:(UIImage *)anImage{
    UIImage *resizedImage = [anImage resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:CGSizeMake(560.0f, 560.0f) interpolationQuality:kCGInterpolationHigh];
    UIImage *thumbnailImage = [anImage thumbnailImage:86.0f transparentBorder:0.0f cornerRadius:10.0f interpolationQuality:kCGInterpolationDefault];
    
    NSData *imageData = UIImageJPEGRepresentation(resizedImage, 0.8f);
    NSData *thumbnailImageData = UIImagePNGRepresentation(thumbnailImage);
    
    if (!imageData || !thumbnailImageData){
        return NO;
    }
    self.photoFile = [PFFile fileWithData:imageData];
    self.thumbnailFile = [PFFile fileWithData:thumbnailImageData];
    self.fileUploadBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
    }];
    [self.photoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
        if (succeeded){
            NSLog(@"Photo uploaded");
            [self.thumbnailFile saveInBackgroundWithBlock:^(BOOL succeded, NSError *error) {
                if (succeeded){
                    NSLog(@"thumbnail uploaded");
                }
                [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
            }];
            
        }else{
            [[UIApplication sharedApplication]endBackgroundTask:self.fileUploadBackgroundTaskId];
        }
    }];
    return YES;
}
-(void)doneButtonAction:(id)sender{
    if (!self.photoFile || !self.thumbnailFile){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Couldn't post your photo" message:nil delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    PFObject *photo = [PFObject objectWithClassName:kOSPhotoClassKey];
    [photo setObject:[PFUser currentUser] forKey:kOSPhotoUserKey ];
    [photo setObject:self.photoFile forKey:kOSPhotoPictureKey];
    [photo setObject:self.thumbnailFile forKey:kOSPhotoThumbnailKey];
    [photo setObject:self.restaurant forKey:kOSPhotoRestaurantKey];
    
    PFACL *photoACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [photoACL setPublicReadAccess:YES];
    photo.ACL = photoACL;
    
    self.photoPostBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.photoPostBackgroundTaskId];
    }];
    
    [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
        if (succeeded){
             NSLog(@"Photo uploaded");
        }
     else {
         NSLog(@"Photo failed to save: %@", error);
         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Couldn't post your photo" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
         [alert show];
     }
     [[UIApplication sharedApplication] endBackgroundTask:self.photoPostBackgroundTaskId];
     }];
    
    [self.navigationController popViewControllerAnimated:YES];


}
@end
