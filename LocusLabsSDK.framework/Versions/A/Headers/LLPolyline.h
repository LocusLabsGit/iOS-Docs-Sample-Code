//
//  LLPolyline.h
//  LocusLabsSDK
//
//  Created by Samuel Ziegler on 6/12/14.
//  Copyright (c) 2014 LocusLabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LLPolycurve.h"

#define POLYLINE_FORWARD_ARROW  @"m-2,0 l-3,5 l10,-5 l-10,-5 l3,5z"
#define POLYLINE_BACKWARD_ARROW @"m2,0 l3,5 l-10,-5 l10,-5 l-3,5z"

@class LLPath;

/**
 *  Creates multi-segment line with two or more verticies.
 */
@interface LLPolyline : LLPolycurve

/**
 *  Creates a new polyline object which follows the given path.
 *
 *  @param path the path
 *
 *  @return the new polyline
 */
+ (LLPolyline *)polylineWithPath:(LLPath *)path;

/**
 *  The path associated with this LLPolyline
 */
@property (nonatomic, strong) LLPath *path;

@end