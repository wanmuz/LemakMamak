//
//  OSWRestaurant.h
//  LepakMamak
//
//  Created by Azad Johari on 10/3/13.
//  Copyright (c) 2013 Wan Muzaffar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <Parse/Parse.h>
#import "OSConstants.h"
@interface OSWRestaurant : NSObject<MKAnnotation>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, copy) NSString *subtitle;

@property (nonatomic, readonly, strong) PFObject *object;
@property (nonatomic, readonly, strong) PFGeoPoint *geopoint;
@property (nonatomic, readonly, strong) PFUser *user;
@property (nonatomic, assign) BOOL animatesDrop;
@property (nonatomic, readonly) MKPinAnnotationColor pinColor;

-(id)initWithCoordinate:(CLLocationCoordinate2D)coordinate andTitle:(NSString*)title andSubtitle:(NSString*)subtitle;
-(id)initWithPFObject:(PFObject *)object;
-(BOOL)equalToRestaurant:(OSWRestaurant *)aRestaurant;

- (void)setTitleAndSubtitleOutsideDistance:(BOOL)outside;
@end
