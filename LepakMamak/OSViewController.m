//
//  OSViewController.m
//  LepakMamak
//
//  Created by Azad Johari on 9/15/13.
//  Copyright (c) 2013 Wan Muzaffar. All rights reserved.
//

#import "OSViewController.h"
#import "OSDetailViewController.h"
@interface OSViewController (){
        NSMutableData *_data;
}

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
    bannerView_ = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    
    // Specify the ad's "unit identifier". This is your AdMob Publisher ID.
    bannerView_.adUnitID = @"a15252cd8b13add";
    
    // Let the runtime know which UIViewController to restore after taking
    // the user wherever the ad goes and add it to the view hierarchy.
    bannerView_.rootViewController = self;
    [self.view addSubview:bannerView_];
    
    // Initiate a generic request to load it with an ad.
    [bannerView_ loadRequest:[GADRequest request]];
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
    
    CALayer * shadow = [self createShadowWithFrame:CGRectMake(0, 0, 320, 5)];
    [self.tableView.layer addSublayer:shadow];
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
    [loginViewController setFields:PFLogInFieldsUsernameAndPassword | PFLogInFieldsTwitter | PFLogInFieldsSignUpButton | PFLogInFieldsDismissButton | PFLogInFieldsFacebook];
    [self presentViewController:loginViewController animated:YES completion:nil];
    
    }

-(void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user{
    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error){
        if (!error){
            [self facebookRequestDidLoad:result];
        }
        else{
            //[self facebookRequestDidFailWithError:error];
        }
    }];
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
    static NSString *CellIdentifier = @"MasterCell";
    
    MasterCell *cell = (MasterCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    
        CALayer* shadow = [self createShadowWithFrame:CGRectMake(0, 67, 320, 5)];
        
        [cell.layer addSublayer:shadow];
    
    
    cell.titleLabel.text = [object objectForKey:@"name"];
    
    cell.textLabel.text = [self getDistanceFromGeoPoint:[object objectForKey:@"location"]];;
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

-(CALayer *)createShadowWithFrame:(CGRect)frame
{
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = frame;
    
    
    UIColor* lightColor = [[UIColor blackColor] colorWithAlphaComponent:0.0];
    UIColor* darkColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    
    gradient.colors = [NSArray arrayWithObjects:(id)darkColor.CGColor, (id)lightColor.CGColor, nil];
    
    return gradient;
}

-(void)facebookRequestDidLoad:(id)result{
    PFUser *user = [PFUser currentUser];
    
    NSArray *data = [result objectForKey:@"data"];
    NSURL *profilePictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", [[PFUser currentUser] objectForKey:kOSUserFacebookIDKey]]];
    NSURLRequest *profilePictureURLRequest = [NSURLRequest requestWithURL:profilePictureURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0f]; // Facebook profile picture cache policy: Expires in 2 weeks
    [NSURLConnection connectionWithRequest:profilePictureURLRequest delegate:self];
    if (data)
    {
        NSMutableArray *facebookIds = [[NSMutableArray alloc] initWithCapacity:[data count]];
        for (NSDictionary *friendData in data){
            if (friendData[@"id"]){
                [facebookIds addObject:friendData[@"id"]];
            }
            
        }
        [[OSCache sharedCache] setFacebookFriends:facebookIds];
        if(user){
            if (![user objectForKey:kOSUserAlreadyAutoFollowedFacebookFriendsKey])
            {
             //   firstLaunch = YES;
                [user setObject:@YES forKey:kOSUserAlreadyAutoFollowedFacebookFriendsKey];
                
                NSError *error = nil;
                
                PFQuery *facebookFriendsQuery = [PFUser query];
                [facebookFriendsQuery whereKey:kOSUserFacebookIDKey containedIn:facebookIds];
                
                PFQuery *query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects: facebookFriendsQuery, nil]];
                
                NSArray *mamakFriends = [query findObjects:&error];
                if (!error) {
                    [mamakFriends enumerateObjectsUsingBlock:^(PFUser *newFriend, NSUInteger idx, BOOL *stop){
                        // PFObject *joinActivity
                    }];
                }
                
            }
            [user saveEventually];
        }
        else{
          //  [self logOut];
        }
    }
    else{
        
        if (user){
            NSString *facebookName = result[@"name"];
            if (facebookName && [facebookName length]!= 0){
                [user setObject:facebookName forKey:kOSUserDisplayNameKey];
            }else{
                [user setObject:@"Someone" forKey:kOSUserDisplayNameKey];
            }
            NSString *facebookId = result[@"id"];
            if (facebookId && [facebookId length] != 0){
                [user setObject:facebookId forKey:kOSUserFacebookIDKey];
            }
            [user saveEventually];
        }
        [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error){
            if (!error){
                [self facebookRequestDidLoad:result];
            }else{
             //   [self facebookRequestDidFailWithError:error];
            }
        }];
        
        
    }
    
}
- (void)facebookRequestDidFailWithError:(NSError *)error {
    NSLog(@"Facebook error: %@", error);
    
    if ([PFUser currentUser]) {
        if ([[error userInfo][@"error"][@"type"] isEqualToString:@"OAuthException"]) {
            NSLog(@"The Facebook token was invalidated. Logging out.");
           // [self logOut];
        }
    }
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    _data =[[NSMutableData alloc] init];
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [_data appendData:data];
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    [[OSUtility sharedInstance] processFacebookProfilePictureData:_data];
}

@end
