//
//  OSSearchResultViewController.h
//  LepakMamak
//
//  Created by Azad Johari on 9/23/13.
//  Copyright (c) 2013 Wan Muzaffar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "OSConstants.h"
@interface OSSearchResultViewController : PFQueryTableViewController

@property (nonatomic, strong) PFObject *restaurant;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *address;
@property (nonatomic) BOOL *withWifi;
@property (nonatomic) BOOL *screenExist;
@end
