//
//  OSConstants.m
//  LepakMamak
//
//  Created by Azad Johari on 9/15/13.
//  Copyright (c) 2013 Wan Muzaffar. All rights reserved.
//

#import "OSConstants.h"

NSString *const  kOSActivityClassName = @"Restaurant";

NSString *const kOSActivityClassKey = @"Activity";

//Type values
NSString *const kOSActivityTypeComment = @"comment";
NSString *const kOSActivityTypeLike = @"like";

NSString *const kOSActivityTypeKey        = @"type";
NSString *const kOSPActivityContentKey= @"content";
NSString *const kOSPActivityFromUserKey=@"fromUser";
NSString *const kOSActivityRestaurantKey=@"restaurant";

#pragma mark - Cached Photo Attributes
// keys
NSString *const kOSRestaurantAttributesIsLikedByCurrentUserKey = @"isLikedByCurrentUser";
NSString *const kOSRestaurantAttributesLikeCountKey            = @"likeCount";
NSString *const kOSRestaurantAttributesLikersKey               = @"likers";
NSString *const kOSRestaurantAttributesCommentCountKey         = @"commentCount";
NSString *const kOSRestaurantAttributesCommentersKey           = @"commenters";

NSString * const kOSLocationKey = @"location";
NSString * const kOSFilterDistanceChangeNotification = @"kOSFilterDistanceChangeNotification";
NSString * const kOSLocationChangeNotification = @"kOSLocationChangeNotification";