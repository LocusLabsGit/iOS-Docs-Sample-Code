//
//  LLCurvedPath.h
//  LocusLabsSDK
//
//  Created by Glenn Dierkes on 1/14/15.
//  Copyright (c) 2015 LocusLabs. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LLJavaScriptObject.h"
@class LLMap;
@class LLMapView;

@interface LLCurvedPath : LLJavaScriptObject

@property (nonatomic, strong) NSString* floorId;

/**
 * Add the given curve object to the end of the path
 * A NSDictionary containing a "start", "out", "in" and "end" keys.
 * All of which are of type LLLatLng.  These represent the four points
 * of a Bezier Curve.
 *
 *  @param curve the curve to add
 */
- (void)addCurve:(NSDictionary *)curve;

- (instancetype) initWithMap:(LLMap*)map;
- (instancetype) initWithMapView:(LLMapView*)mapView;
- (LLCurvedPath*)copyToJavaScriptBridge:(LLJavaScriptBridge *)javaScriptBridge;

@end