//
//  OSViewController.m
//  LepakMamak
//
//  Created by Azad Johari on 9/15/13.
//  Copyright (c) 2013 Wan Muzaffar. All rights reserved.
//

#import "OSViewController.h"
#import "OSDetailViewController.h"
@interface OSViewController ()

@property (nonatomic, strong) CLLocationManager *_locationManager;
@end

@implementation OSViewController
@synthesize _locationManager = locationManager;
- (void)viewDidLoad
{
    
    [self startStandardUpdates];
    _sideBar.tintColor = [UIColor colorWithWhite:0.96 alpha:0.2f];
    _sideBar.target= self.revealViewController;
    _sideBar.action = @selector(revealToggle:);
    
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (![PFUser currentUser] ){
        [self setLoginPage];
    }
}
-(void)viewWillAppear:(BOOL)animated{
    [locationManager startUpdatingLocation];
    [super viewWillAppear:animated];
}
-(void)viewDidDisappear:(BOOL)animated{
    [locationManager stopUpdatingLocation];
    [super viewDidDisappear:animated];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dealloc{
    [locationManager stopUpdatingLocation];
}

#pragma mark -CLLocationManagerDelegate methods and helpers
-(void) startStandardUpdates{
    if (nil == locationManager){
        locationManager = [[CLLocationManager alloc] init];
        
    }
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [locationManager startUpdatingLocation];
    CLLocation *currentLocation = locationManager.location;
    if(currentLocation){
        OSAppDelegate *appDelagate = [[UIApplication sharedApplication] delegate];
        appDelagate.currentLocation = currentLocation;
    }
}
-(void)setLoginPage{
    OSLoginViewController *loginViewController = [[OSLoginViewController alloc] init];
    [loginViewController setDelegate:self];
    [loginViewController setFacebookPermissions:[NSArray arrayWithObjects:@"friends_about_me", nil]];
    [loginViewController setFields:PFLogInFieldsUsernameAndPassword | PFLogInFieldsTwitter | PFLogInFieldsSignUpButton | PFLogInFieldsDismissButton];
    [self presentViewController:loginViewController animated:YES completion:nil];
    
    }

#pragma mark - Parse

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
    // This method is called every time objects are loaded from Parse via the PFQuery
}

- (void)objectsWillLoad {
    [super objectsWillLoad];
    
    // This method is called before a PFQuery is fired to get more objects
}
//
//
//-(PFQuery*)queryForTable{
//    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
//    if ([self.objects count] == 0){
//        query.cachePolicy= kPFCachePolicyCacheThenNetwork;
//    }
//    [query orderByAscending:@"name"];
//    return query;
//}

-(PFQuery*)queryForTable{
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
       if ([self.objects count] == 0){
           query.cachePolicy= kPFCachePolicyCacheThenNetwork;
       }
    OSAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    CLLocation *currentLocation = appDelegate.currentLocation;
    PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:currentLocation.coordinate.latitude longitude:currentLocation.coordinate.longitude];
    [query whereKey:kOSLocationKey nearGeoPoint:point withinKilometers:25];
    [query includeKey:kOSPActivityFromUserKey];
    return query;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *CellIdentifier = @"restaurantCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell
    cell.textLabel.text = [object objectForKey:@"name"];
    
    cell.detailTextLabel.text = [self getDistanceFromGeoPoint:[object objectForKey:@"location"]];;
    //object.tag = indexPath.row;
    return cell;
}
-(NSString*)getDistanceFromGeoPoint:(PFGeoPoint*)geoPoint{
    OSAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    CLLocation *currentLocation = appDelegate.currentLocation;
    PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:currentLocation.coordinate.latitude longitude:currentLocation.coordinate.longitude];
    double distance = [geoPoint distanceInKilometersTo:point];
    return [NSString stringWithFormat:@"%.2f km",distance ];
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"showDetail"]){
        OSDetailViewController *detailVC = [segue destinationViewController];
           NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        PFObject *restaurant = [self.objects objectAtIndex:indexPath.row];
        [detailVC setRestaurant:restaurant];
    }
}
@end
