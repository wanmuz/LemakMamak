//
//  OSUtility.m
//  LepakMamak
//
//  Created by Azad Johari on 9/16/13.
//  Copyright (c) 2013 Wan Muzaffar. All rights reserved.
//

#import "OSUtility.h"
#import "OSCache.h"
#import "UIImage+ResizeAdditions.h"
#import "OSConstants.h"
@implementation OSUtility
static OSUtility *_sharedInstance = nil;
+(OSUtility*)sharedInstance{
    if (!_sharedInstance) {
        _sharedInstance = [[OSUtility alloc] init];
    }
    return _sharedInstance;
}

#pragma mark Fav Restaurants
-(void)favRestaurantsInBackground:(id)restaurant block:(void (^)(BOOL succeeded, NSError *error)) completionBlock{
    PFQuery *queryExistingFavs = [PFQuery queryWithClassName:kOSActivityClassKey];
    [queryExistingFavs whereKey:kOSActivityRestaurantKey containedIn:restaurant];
    [queryExistingFavs whereKey:kOSActivityTypeKey equalTo:kOSActivityTypeFav];
    [queryExistingFavs whereKey:kOSPActivityFromUserKey equalTo:[PFUser currentUser]];
    [queryExistingFavs setCachePolicy:kPFCachePolicyNetworkOnly];
    [queryExistingFavs findObjectsInBackgroundWithBlock:^(NSArray* activities, NSError *error){
        if (!error){
            for (PFObject *activity in activities){
                [activity delete];
            }
        }
        
      //  PFObject *favActivity = [
    }
     ];
}
#pragma mark Like Photos
-(void)likeRestaurantInBackground:(id)restaurant block:(void (^)(BOOL succeeded, NSError *error)) completionBlock{
    PFQuery *queryExistingLikes = [PFQuery queryWithClassName:kOSActivityClassKey];
    [queryExistingLikes whereKey:kOSActivityRestaurantKey equalTo:restaurant];
    [queryExistingLikes whereKey:kOSActivityTypeKey equalTo:kOSActivityTypeLike];
    [queryExistingLikes whereKey:kOSPActivityFromUserKey equalTo:[PFUser currentUser]];
    [queryExistingLikes setCachePolicy:kPFCachePolicyNetworkOnly];
    [queryExistingLikes findObjectsInBackgroundWithBlock:^(NSArray* activities, NSError *error) {
        if (!error){
            for (PFObject *activity in activities){
                [activity delete];
            }
        }
        
    
        //Create new like
        
        PFObject *likeActivity = [PFObject objectWithClassName:kOSActivityClassKey];
        [likeActivity setObject:kOSActivityTypeLike forKey:kOSActivityTypeKey];
        [likeActivity setObject:[PFUser currentUser] forKey:kOSPActivityFromUserKey];
        [likeActivity setObject:restaurant forKey:kOSActivityRestaurantKey];
        
        PFACL *likeACL = [PFACL ACLWithUser:[PFUser currentUser]];
        [likeACL setPublicReadAccess:YES];
        likeActivity.ACL = likeACL;
        
        [likeActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError* error) {
            if (completionBlock){
                completionBlock(succeeded, error);
            }
            PFQuery *query  = [self queryForActivitiesOnRestaurant:restaurant cachePolicy:kPFCachePolicyNetworkOnly];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
                if(!error){
                    NSMutableArray *likers = [NSMutableArray array];
                    NSMutableArray *commenters = [NSMutableArray array];
                    
                    BOOL isLikedByCurrentUser = NO;
                    for (PFObject *activity in objects){
                        if ([[activity objectForKey:kOSActivityTypeKey] isEqual:kOSActivityTypeLike] && [activity objectForKey:kOSPActivityFromUserKey]){
                            [likers addObject:[activity objectForKey:kOSPActivityFromUserKey]];
                        }
                        else if([[activity objectForKey:kOSActivityTypeKey ] isEqual:kOSActivityTypeComment] && [activity objectForKey:kOSPActivityFromUserKey]){
                            [commenters addObject:[activity objectForKey:kOSPActivityFromUserKey]];
                        }
                        
                        if ([[[activity objectForKey:kOSPActivityFromUserKey] objectId] isEqual:[[PFUser currentUser] objectId] ]){
                            if ([[activity objectForKey:kOSActivityTypeKey] isEqual:kOSActivityTypeLike]) {
                                isLikedByCurrentUser = YES;
                            }
                        }
                    }
                   [[OSCache sharedCache] setAttributesForRestaurant:restaurant likers:likers commenters:commenters likedByCurrentUser:isLikedByCurrentUser];
                }
            }];
        }];
    }];
}

-(void)unlikeRestaurantInBackground:(id)restaurant block:(void (^)(BOOL succeeded, NSError* error)) completionBlock{
    PFQuery *queryExistingLikes = [PFQuery queryWithClassName:kOSActivityClassKey];
    [queryExistingLikes whereKey:kOSActivityRestaurantKey equalTo:restaurant];
    [queryExistingLikes whereKey:kOSActivityTypeKey equalTo:kOSActivityTypeLike];
    [queryExistingLikes whereKey:kOSPActivityFromUserKey equalTo:[PFUser currentUser]];
    [queryExistingLikes setCachePolicy:kPFCachePolicyNetworkOnly];
    [queryExistingLikes findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {
        if (!error){
            for (PFObject *activity in activities){
                [activity delete];
            }
     if (completionBlock){
         completionBlock(YES, nil);
     }
     PFQuery *query =[self queryForActivitiesOnRestaurant:restaurant cachePolicy:kPFCachePolicyNetworkOnly];
     [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError* error){
        if (!error){
            NSMutableArray *likers = [NSMutableArray array];
            NSMutableArray *commenters = [NSMutableArray array];
            
            BOOL isLikedByCurrentUser = NO;
            
            for (PFObject *activity in objects){
                if ([[activity objectForKey:kOSActivityTypeKey] isEqualToString:kOSActivityTypeLike]){
                    [likers addObject:[activity objectForKey:kOSPActivityFromUserKey]];
                } else if ([[activity objectForKey:kOSActivityTypeKey] isEqualToString:kOSActivityTypeComment]){
                    [commenters addObject:[activity objectForKey:kOSPActivityFromUserKey]];
                }
                if ([[[activity objectForKey:kOSPActivityFromUserKey] objectId] isEqualToString:[[PFUser currentUser] objectId]]){
                    if ([[activity objectForKey:kOSActivityTypeKey] isEqualToString:kOSActivityTypeLike]){
                        isLikedByCurrentUser = YES;
                    }
                }
            }
            [[OSCache sharedCache] setAttributesForRestaurant:restaurant likers:likers commenters:commenters likedByCurrentUser:isLikedByCurrentUser];
        }
        
    }];
     } else{
         if (completionBlock){
             completionBlock(NO,error);
         }
     }
     }];
        
}
-(PFQuery *)queryForActivitiesOnRestaurant:(PFObject*)restaurant cachePolicy:(PFCachePolicy)cachePolicy{
    PFQuery *queryLikes = [PFQuery queryWithClassName:kOSActivityClassKey];
    [queryLikes whereKey:kOSActivityRestaurantKey equalTo:restaurant];
    [queryLikes whereKey:kOSActivityTypeKey equalTo:kOSActivityTypeLike];
 
    
    PFQuery *queryComments = [PFQuery queryWithClassName:kOSActivityClassKey];
    [queryComments whereKey:kOSActivityRestaurantKey equalTo:restaurant];
    [queryComments whereKey:kOSActivityTypeKey equalTo:kOSActivityTypeComment];
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:queryLikes,queryComments, nil]];
    [query setCachePolicy:cachePolicy];
    [query includeKey:kOSActivityRestaurantKey];
    [query includeKey:kOSPActivityFromUserKey];
    
    return query;
    
}
-(void)processFacebookProfilePictureData:(NSData*)newProfilePictureData{
    if (newProfilePictureData.length==0){
        return;
    }
    NSURL *cachesDirectoryURL = [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
    
    NSURL *profilePictureCacheURL = [cachesDirectoryURL URLByAppendingPathComponent:@"FacebookProfilePicture.jpg"];
    
    if ([[NSFileManager defaultManager]fileExistsAtPath:[profilePictureCacheURL path]]){
        NSData *oldProfilePictureData = [NSData dataWithContentsOfFile:[profilePictureCacheURL path]];
        if ([oldProfilePictureData isEqualToData:newProfilePictureData]){
            return;
        }
    }
    UIImage *image = [UIImage imageWithData:newProfilePictureData];
    UIImage *mediumImage = [image thumbnailImage:280 transparentBorder:0 cornerRadius:0 interpolationQuality:kCGInterpolationHigh];
    UIImage *smallRoundedImage = [image thumbnailImage:64 transparentBorder:0 cornerRadius:0 interpolationQuality:kCGInterpolationLow];
    
    NSData *mediumImageData = UIImageJPEGRepresentation(mediumImage, 0.5);
    NSData *smallRoundedImageData = UIImagePNGRepresentation(smallRoundedImage);
    
    if (mediumImageData.length > 0 ){
        PFFile *fileMediumImage = [PFFile fileWithData:mediumImageData];
        [fileMediumImage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
            if (!error){
                [[PFUser currentUser] setObject:fileMediumImage forKey:kOSUserProfilePicMediumKey];
                [[PFUser currentUser] saveEventually];
            }
        }];
    }
    if (smallRoundedImageData.length > 0){
        PFFile *fileSmallRoundedImage = [PFFile fileWithData:smallRoundedImageData];
        [fileSmallRoundedImage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
            if (!error){
                [[PFUser currentUser] setObject:fileSmallRoundedImage forKey:kOSUserProfilePicSmallKey];
                [[PFUser currentUser] saveEventually];
            }
        }];
    }
}
@end
