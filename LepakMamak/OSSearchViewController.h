//
//  OSSearchViewController.h
//  LepakMamak
//
//  Created by Azad Johari on 9/22/13.
//  Copyright (c) 2013 Wan Muzaffar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSSearchResultViewController.h"
@interface OSSearchViewController : UIViewController<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *cityField;
@property (weak, nonatomic) IBOutlet UIButton *wifiButton;
- (IBAction)buttonTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *bigScreenButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;


@end
