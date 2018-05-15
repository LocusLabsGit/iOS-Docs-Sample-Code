//
//  LLNavigationPath.h
//  LocusLabsSDK
//
//  Created by Samuel Ziegler on 6/18/14.
//  Copyright (c) 2014 LocusLabs. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Describes a navigation path between a starting point and one or more destiniations.
 */
@interface LLNavigationPath : NSObject

+ (NSDictionary *)propertyMap;

/**
 *  A series of LLWaypoints which define the path between the destinations.
 */
@property (retain,nonatomic) NSArray *waypoints;

/**
 *  The total distance of the navigation path, in meters.
 */
@property (retain,nonatomic) NSNumber *distance;

/**
 *  The estimated time needed to traverse the path, in minutes.
 */
@property (retain,nonatomic) NSNumber *eta;

@end