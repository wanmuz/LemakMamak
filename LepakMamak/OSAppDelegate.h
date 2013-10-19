//
//  OSAppDelegate.h
//  LepakMamak
//
//  Created by Azad Johari on 9/15/13.
//  Copyright (c) 2013 Wan Muzaffar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <CoreLocation/CoreLocation.h>
#import "OSConstants.h"
#import "OSLoginViewController.h"
#import "OSCache.h"
@interface OSAppDelegate : UIResponder <UIApplicationDelegate, NSURLConnectionDataDelegate, PFLogInViewControllerDelegate>


@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, assign) CLLocationAccuracy filterDistance;

- (void)presentLoginViewController;
- (void)presentLoginViewControllerAnimated:(BOOL)animated;

- (void)logOut;

- (void)facebookRequestDidLoad:(id)result;
- (void)facebookRequestDidFailWithError:(NSError *)error;

@end
