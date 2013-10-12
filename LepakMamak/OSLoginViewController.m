//
//  OSLoginViewController.m
//  LepakMamak
//
//  Created by Azad Johari on 9/21/13.
//  Copyright (c) 2013 Wan Muzaffar. All rights reserved.
//

#import "OSLoginViewController.h"

@interface OSLoginViewController ()

@end

@implementation OSLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
