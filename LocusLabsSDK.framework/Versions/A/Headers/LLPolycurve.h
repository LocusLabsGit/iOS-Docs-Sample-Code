//
//  LLPolycurve.h
//  LocusLabsSDK
//
//  Created by Glenn Dierkes on 1/12/15.
//  Copyright (c) 2015 LocusLabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LLCurvedPath.h"
#import "LLOverlay.h"

@interface LLPolycurve : LLOverlay

/**
 *  The path associated with this LLPolyline
 */
@property (nonatomic, strong) LLCurvedPath *curvedPath;

/**
 *  The stroke width of this polyline.
 */
@property (nonatomic) CGFloat strokeWidth;

/**
 *  Set the stroke color of this polyline.
 *
 *  @param color the new stroke color
 */
- (void)setStrokeColor:(UIColor *)color;

/**
 *  Set the icons used along this polyline.
 *
 *  @param icons
 */
- (void)setIcons:(NSArray *)icons;

@end