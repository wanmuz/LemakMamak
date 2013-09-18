//
//  OSCache.h
//  LepakMamak
//
//  Created by Azad Johari on 9/17/13.
//  Copyright (c) 2013 Wan Muzaffar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "OSConstants.h"
@interface OSCache : NSObject
+(id)sharedCache;
- (void)setAttributesForRestaurant:(PFObject *)restaurant likers:(NSArray *)likers commenters:(NSArray *)commenters likedByCurrentUser:(BOOL)likedByCurrentUser;
-(NSNumber *)likeCountForRestaurant:(PFObject*)restaurant;
-(void)incrementLikerCountForRestaurant:(PFObject*)restaurant;
-(void)decrementLikerCountForRestaurant:(PFObject*)restaurant;
@end
