//
//  LLMap.h
//  LocusLabsSDK
//
//  Created by Samuel Ziegler on 6/17/14.
//  Copyright (c) 2014 LocusLabs. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LLJavaScriptObject.h"

@class LLLatLng;
@class LLPosition;
@class LLInternalMapView;

@interface LLMap : LLJavaScriptObject

@property (nonatomic, strong) NSNumber *radius;
@property (nonatomic, strong) LLLatLng *center;
@property (nonatomic, strong) LLPosition *centerPosition;
@property (nonatomic, strong) NSNumber *heading;
@property (nonatomic,readonly) NSString *venueId;
@property (nonatomic,readonly) NSString *buildingId;
@property (nonatomic, strong) NSString *floorId;
@property (nonatomic, strong) LLInternalMapView *mapView;

- (void)setHeadingFromPosition:(LLPosition*)position waypoints:(NSArray*)waypoints;
- (void)resetHeading;

- (NSNumber *)findDistanceFromClosestWaypointSegment:(LLLatLng *)latLng waypoints:(NSArray*) waypoints;

@end