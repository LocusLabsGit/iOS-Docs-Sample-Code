//
//  LLOverlay.h
//  LocusLabsSDK
//
//  Created by Samuel Ziegler on 6/12/14.
//  Copyright (c) 2014 LocusLabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LLJavaScriptObject.h"
#import "LLFloorView.h"

/**
 *  Base class for all objects which will be drawn on a map.
 */
@interface LLOverlay : LLJavaScriptObject {
@protected __weak LLFloorView *_floorView; // so children can access _floorView
}
/**
 *  The floor of the map which this object should be drawn on.  This floorView object is provided by a LLMapView.
 */
@property (weak,nonatomic) LLMap *map;
@property (weak,nonatomic) LLFloorView *floorView;
@property (strong,nonatomic) NSNumber *zIndex;


- (instancetype) initWithMap:(LLMap*)map;


// for use by subclasses
@property (strong,nonatomic) LLOverlay *visibleOverlay; // NOT in shared JavaScripBridge; visible onscreen
- (void)setJavaScriptValues:(id)value forKey:(NSString*)key;
- (void)copySelfToVisibleOverlay;

@end