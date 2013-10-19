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
#import <MapKit/MapKit.h>
#import "OSWRestaurant.h"
#import "GADBannerView.h"
#import "OSMasterCell.h"
#import "OSCache.h"
@interface OSViewController : PFQueryTableViewController<PFLogInViewControllerDelegate, MKMapViewDelegate, CLLocationManagerDelegate, NSURLConnectionDataDelegate>{
     GADBannerView *bannerView_;
}

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sideBar;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end
