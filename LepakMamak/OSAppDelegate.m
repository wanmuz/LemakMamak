//
//  OSAppDelegate.m
//  LepakMamak
//
//  Created by Azad Johari on 9/15/13.
//  Copyright (c) 2013 Wan Muzaffar. All rights reserved.
//

#import "OSAppDelegate.h"
#import "OSUtility.h"
@interface OSAppDelegate(){
    BOOL firstLaunch;
    NSMutableData *_data;

}
@end
@implementation OSAppDelegate
@synthesize filterDistance;
@synthesize currentLocation;

-(void)setCurrentLocation:(CLLocation *)aCurrentLocation{
    currentLocation = aCurrentLocation;
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:currentLocation forKey:kOSLocationKey];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kOSLocationChangeNotification object:nil userInfo:userInfo];
    });

}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
       
    // Override point for customization after application launch.
    [Parse setApplicationId:@"0pdsd1YNGJsEIdK1VrIe13TV9KYAjI3HSNImUECf"
                  clientKey:@"pfU85IYKLdWrGzhX1MLmaIwI2pllJCCPuhMecieg"];
    [PFFacebookUtils initializeFacebook];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
   
   

    return YES;
}
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)presentLoginViewController{
    [self presentLoginViewControllerAnimated:YES];
}
-(void)presentLoginViewControllerAnimated:(BOOL)animated{
    OSLoginViewController *loginViewController= [[OSLoginViewController alloc] init];
    [loginViewController setDelegate:self];
    loginViewController.fields= PFLogInFieldsFacebook;
loginViewController.facebookPermissions = @[ @"user_about_me"];
  //present view controller
}
-(void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user{
    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error){
        if (!error){
            [self facebookRequestDidLoad:result];
        }
        else{
            [self facebookRequestDidFailWithError:error];
        }
    }];
}

-(void)facebookRequestDidLoad:(id)result{
    PFUser *user = [PFUser currentUser];
    
NSArray *data = [result objectForKey:@"data"];

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
            firstLaunch = YES;
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
        [self logOut];
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
            [self facebookRequestDidFailWithError:error];
        }
    }];


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
