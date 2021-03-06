//
//  OSConstants.m
//  LepakMamak
//
//  Created by Azad Johari on 9/15/13.
//  Copyright (c) 2013 Wan Muzaffar. All rights reserved.
//

#import "OSConstants.h"


NSString *const kOSUserDefaultsCacheFacebookFriendsKey                     = @"my.celikit.LepakMamak.userDefaults.cache.facebookFriends";

NSString *const  kOSActivityClassName = @"Restaurant";

NSString *const kOSActivityClassKey = @"Activity";
NSString *const kOSPhotoClassKey=@"Photo";

//Type values
NSString *const kOSActivityTypeComment = @"comment";
NSString *const kOSActivityTypeLike = @"like";
NSString *const kOSActivityTypeFav = @"favourite";

NSString *const kOSActivityTypeKey        = @"type";
NSString *const kOSPActivityContentKey= @"content";
NSString *const kOSPActivityFromUserKey=@"fromUser";
NSString *const kOSActivityRestaurantKey=@"restaurant";

NSString *const kOSUserAlreadyAutoFollowedFacebookFriendsKey   = @"userAlreadyAutoFollowedFacebookFriends";

NSString *const kOSUserFacebookIDKey= @"facebookId";
NSString *const kOSUserDisplayNameKey= @"displayName";

NSString *const kOSUserProfilePicMediumKey = @"profilePictureMedium";
NSString *const kOSUserProfilePicSmallKey = @"profilePictureSmall";
NSString *const kOSRestaurantNameKey = @"name";
NSString *const kOSRestaurantAddressKey = @"address";
NSString *const kOSRestaurantWithWifiKey=@"withWifi";
NSString *const kOSRestaurantWithScreenKey=@"withScreen";
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

NSString *const kOSPhotoUserKey = @"user";
NSString *const kOSPhotoPictureKey = @"image";
NSString *const kOSPhotoThumbnailKey=@"thumbnail";
NSString *const kOSPhotoRestaurantKey=@"restaurant";

NSString *const kOSCantViewRestaurant=@"No restaurant within the range. Get closer.";
