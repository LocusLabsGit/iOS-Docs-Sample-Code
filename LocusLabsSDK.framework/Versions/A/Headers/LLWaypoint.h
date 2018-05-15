//
//  LLWaypoint.h
//  LocusLabsSDK
//
//  Created by Samuel Ziegler on 6/12/14.
//  Copyright (c) 2014 LocusLabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LLPosition.h"
/**
 *  A waypoint along a navigation path.
 */
@interface LLWaypoint : LLPosition {
}

/**
 *  The distance, in meters, this waypoint is from the previous one.
 */
@property (strong,nonatomic) NSNumber *distance;

/**
 *  The estimated time, in minutes, to travel from the previous waypoint to this one.
 */
@property (strong,nonatomic) NSNumber *eta;

/**
 *  A boolean flag which is true if this waypoint was specified as a destination.
 */
@property (strong,nonatomic) NSNumber *isDestination;

/**
 *  A boolean flag which is true if this waypoint was specified as a portal.
 */
@property (strong,nonatomic) NSNumber *isPortal;

/**
 *  The portal type.
 */
@property (strong,nonatomic) NSString *portalType;

/**
 *  The details.
 */
@property (strong,nonatomic) NSString *details;

/**
 *  The action.
 */
@property (strong,nonatomic) NSString *action;

/**
 *  The difference between levels from the previous waypoint to this one.
 */
@property (strong,nonatomic) NSNumber *levelDifference;

/**
 *  A specific path to use to get to the next waypoint.
 */
@property (strong,nonatomic) NSArray *curvePath;

/**
 * Does the waypoint go through a "securityCheckpoint".
 */
@property (strong,nonatomic) NSNumber *securityCheckpoint;

/**
 * LatLng
 */
@property (strong,nonatomic) LLLatLng *latLng;

/**
 *  The floorId.
 */
@property (strong,nonatomic) NSString *floorId;

@end