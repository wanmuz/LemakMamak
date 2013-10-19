//
//  OSCache.m
//  LepakMamak
//
//  Created by Azad Johari on 9/17/13.
//  Copyright (c) 2013 Wan Muzaffar. All rights reserved.
//

#import "OSCache.h"
@interface OSCache()
@property (nonatomic, strong) NSCache *cache;
@end
@implementation OSCache
+ (id)sharedCache {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (id)init {
    self = [super init];
    if (self) {
        self.cache = [[NSCache alloc] init];
    }
    return self;
}

- (void)setAttributesForRestaurant:(PFObject *)restaurant likers:(NSArray *)likers commenters:(NSArray *)commenters likedByCurrentUser:(BOOL)likedByCurrentUser{
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:likedByCurrentUser],kOSRestaurantAttributesIsLikedByCurrentUserKey, [NSNumber numberWithInt:[likers count]], kOSRestaurantAttributesLikeCountKey, likers, kOSRestaurantAttributesLikersKey, [NSNumber numberWithInt:[commenters count]], kOSRestaurantAttributesCommentCountKey, commenters, kOSRestaurantAttributesCommentersKey, nil];
    [self setAttributes:attributes forRestaurant:restaurant];
}

#pragma mark - ()

- (void)setAttributes:(NSDictionary *)attributes forRestaurant:(PFObject *)restaurant {
    NSString *key = [self keyForRestaurant:restaurant];
    [self.cache setObject:attributes forKey:key];
}
-(NSDictionary*)attributesForRestaurant:(PFObject*)restaurant{
    NSString *key = [self keyForRestaurant:restaurant];
    return [self.cache objectForKey:key];
}
- (NSString *)keyForRestaurant:(PFObject *)restaurant {
    return [NSString stringWithFormat:@"restaurant_%@", [restaurant objectId]];
}


-(NSNumber *)likeCountForRestaurant:(PFObject*)restaurant{
    NSDictionary *attributes = [self attributesForRestaurant:restaurant];
    if (attributes){
        return [attributes objectForKey:kOSRestaurantAttributesLikeCountKey];
    }
    return [NSNumber numberWithInt:0];
}
-(NSNumber *)commentCountForRestaurant:(PFObject*)restaurant{
    NSDictionary *attributes = [self attributesForRestaurant:restaurant];
    if (attributes){
        return [attributes objectForKey:kOSRestaurantAttributesCommentersKey];
    }
    return [NSNumber numberWithInt:0];
}

-(void)incrementLikerCountForRestaurant:(PFObject*)restaurant{
    NSNumber *likerCount = [NSNumber numberWithInt:[[self likeCountForRestaurant:restaurant] intValue] +1];
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForRestaurant:restaurant]];
    [attributes setObject:likerCount forKey:kOSRestaurantAttributesLikeCountKey];
    [self setAttributes:attributes forRestaurant:restaurant];
}
-(void)decrementLikerCountForRestaurant:(PFObject*)restaurant{
    NSNumber *likerCount = [NSNumber numberWithInt:[[self likeCountForRestaurant:restaurant] intValue] -1];
    if ([likerCount intValue] < 0) {
        return;
    }
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForRestaurant:restaurant]];
    [attributes setObject:likerCount forKey:kOSRestaurantAttributesLikeCountKey];
    [self setAttributes:attributes forRestaurant:restaurant];
}
-(void)setRestaurantIsLikedByCurrentUser:(PFObject *)restaurant liked:(BOOL)liked{
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForRestaurant:restaurant]];
    [attributes setObject:[NSNumber numberWithBool:liked] forKey:kOSRestaurantAttributesIsLikedByCurrentUserKey];
    [self setAttributes:attributes forRestaurant:restaurant];
}
-(BOOL)isRestaurantLikedByCurrentUser:(PFObject*)restaurant{
    NSDictionary *attributes = [self attributesForRestaurant:restaurant];
    if (attributes){
        return [[attributes objectForKey:kOSRestaurantAttributesIsLikedByCurrentUserKey] boolValue] ;
    }
    return NO;
}
-(void)setFacebookFriends:(NSArray *)friends{
    NSString *key = kOSUserDefaultsCacheFacebookFriendsKey;
    [self.cache setObject:friends forKey:key];
    [[NSUserDefaults standardUserDefaults]setObject:friends forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
-(NSArray *)facebookFriends{
    NSString *key = kOSUserDefaultsCacheFacebookFriendsKey;
    if ([self.cache objectForKey:key]){
        return [self.cache objectForKey:key];
    }
    NSArray *friends = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if(friends){
        [self.cache setObject:friends forKey:key];
    }
    return friends;
}
@end
