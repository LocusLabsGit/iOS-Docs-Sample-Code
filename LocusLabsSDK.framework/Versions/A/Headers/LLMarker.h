//
//  LLMarker.h
//  LocusLabsSDK
//
//  Created by Samuel Ziegler on 7/9/14.
//  Copyright (c) 2014 LocusLabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LLOverlay.h"

@class LLPoint;
@class LLMap;
@class LLMapView;

@class LLLatLng;

/**
 *  Used for placing images markers on a map.
 */
@interface LLMarker : LLOverlay {
}

/**
 *  The image coordinates which is centered on the position.
 */
@property (nonatomic,strong) LLPoint *anchor;

/**
 *  The URL of the image icon to use for this marker.
 */
@property (nonatomic,strong) NSString *iconUrl;

/**
 *  The Lat/Lng of this icon on the map.
 */
@property (nonatomic,strong) LLLatLng *position;

/*
 *  The full position of this icon on the map.
 */
@property (nonatomic,strong) LLPosition *positionObject;

@property (strong,nonatomic) id userData;

@property (assign,nonatomic) BOOL draggable;

/**
 *  The FloorId for this marker.
 */
@property (nonatomic,strong) NSString *floorId;

/**
 * The opacity of this marker.
 */
@property (nonatomic,strong) NSNumber *opacity;

/**
 * The highest scale factor that will be applied to the marker based on the zoom level.
 */
@property (nonatomic,strong) NSNumber *maxScale;

/**
 * The smallest scale factor that will be applied to the marker based on the zoom level.
 */
@property (nonatomic,strong) NSNumber *minScale;

@end