//
//  OSUtility.h
//  LepakMamak
//
//  Created by Azad Johari on 9/16/13.
//  Copyright (c) 2013 Wan Muzaffar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "OSConstants.h"
@interface OSUtility : NSObject
+ (OSUtility*) sharedInstance;
-(void)likeRestaurantInBackground:(id)restaurant block:(void (^)(BOOL succeeded, NSError *error)) completionBlock;
-(void)unlikeRestaurantInBackground:(id)restaurant block:(void (^)(BOOL succeeded, NSError* error)) completionBlock;
-(PFQuery *)queryForActivitiesOnRestaurant:(PFObject*)restaurant cachePolicy:(PFCachePolicy)cachePolicy;
-(void)processFacebookProfilePictureData:(NSData*)newProfilePictureData;
@end
