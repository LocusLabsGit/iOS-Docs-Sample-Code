//
//  LLNavPoint.h
//  LocusLabsSDK
//
//  Created by Samuel Ziegler on 6/12/14.
//  Copyright (c) 2014 LocusLabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "LLOverlay.h"

@class LLLatLng;

@interface LLNavPoint : LLOverlay

@property (nonatomic,strong) LLLatLng *position;

/**
 *  The heading angle
 */
@property (nonatomic, strong) NSNumber *heading;

/**
 *  The error radius
 */
@property (nonatomic, strong) NSNumber *errorRadius;

@end