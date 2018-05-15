//
//  LLCircle.h
//  LocusLabsSDK
//
//  Created by Samuel Ziegler on 6/12/14.
//  Copyright (c) 2014 LocusLabs. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LLOverlay.h"

@class LLLatLng;

/**
 *  Draws a circle on an a LLMapView.
 */
@interface LLCircle : LLOverlay

/**
 *  Create a circle with the given radius and center.
 *
 *  @param center the center point of the circle
 *  @param radius the radius of the circle
 *
 *  @return the new circle object
 */
+ (LLCircle *)circleWithCenter:(LLLatLng *)center radius:(NSNumber *)radius;

/**
 *  The current center of the circle.
 */
@property (nonatomic, strong) LLLatLng *center;

/**
 *  The current radius of the circle.
 */
@property (nonatomic, strong) NSNumber *radius;

/**
 *  Set the fill color of this circle.
 *
 *  @param color the new fill color
 */
@property (nonatomic, strong) UIColor *fillColor;

/**
 *  Set the stroke with of this circle.
 *
 *  @param width the new stroke width
 */
@property (nonatomic) CGFloat strokeWidth;

/**
 *  Set the stroke color of this circle.
 *
 *  @param color the new stroke color
 */
@property (nonatomic, strong) UIColor *strokeColor;

@end