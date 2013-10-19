//
//  OSSearchViewController.m
//  LepakMamak
//
//  Created by Azad Johari on 9/22/13.
//  Copyright (c) 2013 Wan Muzaffar. All rights reserved.
//

#import "OSSearchViewController.h"
#import "SWRevealViewController.h"
@interface OSSearchViewController (){
    BOOL *wifiEnabled;
    BOOL *screenExist;
}

@end

@implementation OSSearchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{ bannerView_ = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    
    // Specify the ad's "unit identifier". This is your AdMob Publisher ID.
    bannerView_.adUnitID = @"a15252cd8b13add";
    
    // Let the runtime know which UIViewController to restore after taking
    // the user wherever the ad goes and add it to the view hierarchy.
    bannerView_.rootViewController = self;
    [self.view addSubview:bannerView_];
    
    // Initiate a generic request to load it with an ad.
    [bannerView_ loadRequest:[GADRequest request]];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
    wifiEnabled = NO;
    screenExist = NO;
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
    _sidebarButton.tintColor = [UIColor colorWithWhite:0.96f alpha:0.2f];
  
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    _nameField.delegate=self;
    _cityField.delegate=self;
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}
- (BOOL)textFieldShouldReturn:(UITextField *)textfield
{
    [_nameField resignFirstResponder];
    [_cityField resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    OSSearchResultViewController *detailVC = [segue destinationViewController];
    detailVC.name = self.nameField.text;
    detailVC.address = self.cityField.text;
    detailVC.withWifi = wifiEnabled;
    detailVC.screenExist = screenExist;
}
- (IBAction)buttonTapped:(id)sender {
    if([sender tag] == 0){
        if (wifiEnabled){
            wifiEnabled =NO;
            [_wifiButton setImage:[UIImage imageNamed:@"cb_mono_off.png"] forState:UIControlStateNormal];
        }else{
            wifiEnabled =YES;
            [_wifiButton setImage:[UIImage imageNamed:@"cb_mono_on.png"] forState:UIControlStateNormal];
        }
        
    }else if([sender tag] == 1){
        if (screenExist){
            screenExist = NO;
            [_bigScreenButton setImage:[UIImage imageNamed:@"cb_mono_off.png"] forState:UIControlStateNormal];
        }else{
            screenExist = YES;
            [_bigScreenButton setImage:[UIImage imageNamed:@"cb_mono_on.png"] forState:UIControlStateNormal];
        }
    }
}
@end
