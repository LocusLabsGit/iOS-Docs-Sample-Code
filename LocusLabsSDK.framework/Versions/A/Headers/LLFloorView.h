//
//  LLFloorView.h
//  LocusLabsSDK
//
//  Created by Glenn Dierkes on 9/12/14.
//  Copyright (c) 2014 LocusLabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LLJavaScriptObject.h"
#import "LLMapView.h"

@interface LLFloorView : LLJavaScriptObject

@property (weak,nonatomic) LLMapView* mapView;
@property (strong,nonatomic) NSString *floorId;

@end