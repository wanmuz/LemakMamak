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
@property (nonatomic, assign) BOOL mapPannedSinceLocationUpdate;
@property (nonatomic, assign) BOOL mapPinsPlaced;
@property(nonatomic, strong) NSMutableArray *allRestaurants;
@property (nonatomic, copy) NSString *className;
-(void)queryForAllRestaurantsNearLocation:(CLLocation*)currentLocation withNearbyDistance:(CLLocationAccuracy)nearbyDistance;
@end

@implementation OSViewController
@synthesize _locationManager = locationManager;
@synthesize mapView;

@synthesize mapPannedSinceLocationUpdate;
@synthesize allRestaurants;
@synthesize mapPinsPlaced;
-(id)init{
    self = [super init];
    if (self){
        self.className = kOSRestaurantNameKey;
        allRestaurants = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    
   
    _sideBar.tintColor = [UIColor colorWithWhite:0.96 alpha:0.2f];
    _sideBar.target= self.revealViewController;
    _sideBar.action = @selector(revealToggle:);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDidChange:) name:kOSLocationChangeNotification object:nil];
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    self.mapPannedSinceLocationUpdate = NO;
     [self startStandardUpdates];
    OSAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    CLLocation *currentLocation = appDelegate.currentLocation;

    self.mapView.region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(currentLocation.coordinate.latitude, currentLocation.coordinate.longitude), MKCoordinateSpanMake(0.008516, 0.021801));
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}
-(void)viewDidUnload{
    [super viewDidUnload];
    self.mapPinsPlaced=NO;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kOSLocationChangeNotification object:nil];
    [locationManager stopUpdatingLocation];
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
   [[NSNotificationCenter defaultCenter] removeObserver:self name:kOSLocationChangeNotification object:nil];
    [locationManager stopUpdatingLocation];
    self.mapPinsPlaced =NO;
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
-(void)locationDidChange:(NSNotification *)note {
    OSAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    if(!self.mapPannedSinceLocationUpdate){
        MKCoordinateRegion newRegion = MKCoordinateRegionMakeWithDistance(appDelegate.currentLocation.coordinate, 50000, 50000);
        BOOL oldMapPannedValue = self.mapPannedSinceLocationUpdate;
        [mapView setRegion:newRegion animated:YES];
    }
    [self queryForAllRestaurantsNearLocation:appDelegate.currentLocation withNearbyDistance:25000];
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
-(void)queryForAllRestaurantsNearLocation:(CLLocation*)currentLocation withNearbyDistance:(CLLocationAccuracy)nearbyDistance{
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];

    if (currentLocation == nil){
        NSLog(@"%s got a nil location!", __PRETTY_FUNCTION__);
    }
    if ([self.allRestaurants count]==0){
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:currentLocation.coordinate.latitude longitude:currentLocation.coordinate.longitude];
    [query whereKey:kOSLocationKey nearGeoPoint:point withinKilometers:25];
    [query includeKey:kOSPActivityFromUserKey];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error){
            NSLog(@"error in geo query!");
        }else{
            NSMutableArray *newRestaurants = [[NSMutableArray alloc] init];
            NSMutableArray *allNewRestaurants = [[NSMutableArray alloc] init];
            
            for (PFObject *object in objects){
                OSWRestaurant *newRestaurant = [[OSWRestaurant alloc] initWithPFObject:object];
                [allNewRestaurants addObject:newRestaurant];
                BOOL found = NO;
                for (OSWRestaurant *currentRestaurant in allRestaurants){
                    if ([newRestaurant equalToRestaurant:currentRestaurant]){
                        found = YES;
                    }
                }
                if (!found){
                    [newRestaurants addObject:newRestaurant];
                }
            }
            
            NSMutableArray *restaurantsToRemove = [[NSMutableArray alloc] init];
            for (OSWRestaurant *currentRestaurant in allRestaurants){
                BOOL found = NO;
                
                for (OSWRestaurant *allNewRestaurant in allNewRestaurants){
                    if ([currentRestaurant equalToRestaurant:allNewRestaurant]){
                        found = YES;
                    }
                }
                if (!found){
                    [restaurantsToRemove addObject:currentRestaurant];
                }
            }
            NSMutableArray *tempArray = [[NSMutableArray alloc]initWithCapacity:[newRestaurants count]];
            for (OSWRestaurant *newRestaurant in newRestaurants){
              
                CLLocation *objectLocation = [[CLLocation alloc] initWithLatitude:newRestaurant.coordinate.latitude longitude:newRestaurant.coordinate.longitude];
                OSWRestaurant *tempObject = [[OSWRestaurant alloc] initWithCoordinate:objectLocation.coordinate andTitle:newRestaurant.title andSubtitle:newRestaurant.subtitle];
               CLLocationDistance distanceFromCurrent = [currentLocation distanceFromLocation:objectLocation];
                [tempObject setTitleAndSubtitleOutsideDistance:(distanceFromCurrent > nearbyDistance ? YES: NO)];

              //  CLLocationDistance distanceFromCurrent = [currentLocation distanceFromLocation:objectLocation];
            //    [newRestaurant setTitleAndSubtitleOutsideDistance:(distanceFromCurrent > nearbyDistance ? YES: NO)];
            //    newRestaurant.animatesDrop = mapPinsPlaced;
                [tempArray addObject:tempObject];
                            }
            
            [mapView removeAnnotations:restaurantsToRemove];
           [mapView addAnnotations:tempArray];
            [allRestaurants addObjectsFromArray:newRestaurants];
            [allRestaurants removeObjectsInArray:restaurantsToRemove];
            self.mapPinsPlaced = YES;
        }
    }];
}
#pragma mark MapView Delegate

-(MKAnnotationView*)mapView:(MKMapView *)aMapView viewForAnnotation:(id<MKAnnotation>)annotation{
    if ([annotation isKindOfClass:[MKUserLocation class]])
    {
        return nil;
    }
static NSString *pinIdentifier = @"CustomPinAnnotation";
    
    if ([annotation isKindOfClass:[OSWRestaurant class]]){
        MKPinAnnotationView *pinView = (MKPinAnnotationView*)[aMapView dequeueReusableAnnotationViewWithIdentifier:pinIdentifier];
        if (!pinView){
            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pinIdentifier];
        }else{
            pinView.annotation = annotation;
        }
        pinView.pinColor = [(OSWRestaurant*)annotation pinColor];
        pinView.animatesDrop = [((OSWRestaurant*)annotation) animatesDrop];
        pinView.canShowCallout = YES;
        return pinView;
    }
    return nil;
}
@end
