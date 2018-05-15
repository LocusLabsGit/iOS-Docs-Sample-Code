//
//  LLPoint.h
//  LocusLabsSDK
//
//  Created by Samuel Ziegler on 7/9/14.
//  Copyright (c) 2014 LocusLabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LLJavaScriptObject.h"

#define POI_ANCHOR              [[LLPoint alloc] initWithX:[NSNumber numberWithInt:10] Y:[NSNumber numberWithInt:10]]
#define POI_ANCHOR_SELECTED     [[LLPoint alloc] initWithX:[NSNumber numberWithInt:16] Y:[NSNumber numberWithInt:17]]
#define PORTAL_ANCHOR           [[LLPoint alloc] initWithX:[NSNumber numberWithInt:22] Y:[NSNumber numberWithInt:15]]

/**
 *  Describes a point in two dimentional space.
 */
@interface LLPoint : LLJavaScriptObject

/**
 *  The x value of this point.
 */
@property (nonatomic,strong) NSNumber *x;

/**
 *  The y value of this point.
 */
@property (nonatomic,strong) NSNumber *y;

/**
 *  Construct a new LLPoint with the given x and y values.
 *
 *  @param x the x value
 *  @param y the y value
 *
 *  @return the new point instance
 */
- (id)initWithX:(NSNumber *)x Y:(NSNumber *)y;
- (id)initWithX:(NSNumber *)x Y:(NSNumber *)y javaScriptBridge:(LLJavaScriptBridge *)javaScriptBridge uuid:(NSString *)uuid;

/**
 *  Returns true if the two points are equal
 *
 *  @param other the point to compare against
 *
 *  @return true if the points are equal
 */
- (bool)equals:(LLPoint *)other;

@end