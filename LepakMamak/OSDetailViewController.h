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
@interface OSDetailViewController : PFQueryTableViewController<UITextFieldDelegate, OSHeaderViewDelegate>
@property (nonatomic, strong) PFObject *restaurant;


@end
