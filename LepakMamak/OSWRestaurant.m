//
//  OSWRestaurant.m
//  LepakMamak
//
//  Created by Azad Johari on 10/3/13.
//  Copyright (c) 2013 Wan Muzaffar. All rights reserved.
//

#import "OSWRestaurant.h"
@interface OSWRestaurant()
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSString *subtitle;

@property (nonatomic, strong) PFObject *object;
@property (nonatomic, strong) PFGeoPoint *geopoint;
@property (nonatomic, strong) PFUser *user;
@property (nonatomic, assign) MKPinAnnotationColor pinColor;

@end
@implementation OSWRestaurant

@synthesize  coordinate;
@synthesize title;
@synthesize subtitle;

@synthesize object;
@synthesize geopoint;
@synthesize user;
@synthesize animatesDrop;
@synthesize pinColor;

-(id)initWithCoordinate:(CLLocationCoordinate2D)aCoordinate andTitle:(NSString *)aTitle andSubtitle:(NSString *)aSubtitle{
    self = [super init];
    if (self){
        self.coordinate = aCoordinate;
        self.title = aTitle;
        self.subtitle = aSubtitle;
        self.animatesDrop = NO;
    }
    return self;
}

-(id)initWithPFObject:(PFObject *)anObject{
    self.object= anObject;
    self.geopoint = [anObject objectForKey:kOSLocationKey];
   // self.user = [anObject objectForKey:kOSR]
    [anObject fetchIfNeeded];
    CLLocationCoordinate2D aCoordinate = CLLocationCoordinate2DMake(self.geopoint.latitude, self.geopoint.longitude);
    NSString *aTitle = [anObject objectForKey:kOSRestaurantNameKey];
    NSString *aSubtitle = [anObject objectForKey:kOSRestaurantAddressKey];
    
    return [self initWithCoordinate:aCoordinate andTitle:aTitle andSubtitle:aSubtitle];
}
-(BOOL)equalToRestaurant:(OSWRestaurant *)aRestaurant{
    if (aRestaurant == nil){
        return NO;
    }
    if (aRestaurant.object && self.object){
        return NO;
    }else{
        if ([aRestaurant.title compare:self.title] != NSOrderedSame || [aRestaurant.subtitle compare:self.subtitle] != NSOrderedSame || aRestaurant.coordinate.latitude != self.coordinate.latitude || aRestaurant.coordinate.longitude != self.coordinate.longitude){
            return NO;
        }
        return YES;
    }
}
-(void)setTitleAndSubtitleOutsideDistance:(BOOL)outside{
    if(outside){
        self.subtitle=nil;
        self.title = kOSCantViewRestaurant;
        self.pinColor = MKPinAnnotationColorRed;
    }else{
        self.title = [self.object objectForKey:kOSRestaurantNameKey];
        self.title = [self.object objectForKey:kOSLocationKey];
        self.pinColor = MKPinAnnotationColorGreen;
    }
}
@end
