//
//  OSViewController.h
//  LepakMamak
//
//  Created by Azad Johari on 9/15/13.
//  Copyright (c) 2013 Wan Muzaffar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "OSLoginViewController.h"
#import "OSAppDelegate.h"
#import <CoreLocation/CoreLocation.h>
#import "SWRevealViewController.h"
@interface OSViewController : PFQueryTableViewController<PFLogInViewControllerDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sideBar;

@end
