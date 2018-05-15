//
//  LLNavLine.h
//  LocusLabsSDK
//
//  Created by Glenn Dierkes on 12/21/14.
//  Copyright (c) 2014 LocusLabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LLPolyline.h"
#import "LLSymbol.h"

@interface LLNavLine : LLPolyline

/**
 *  The number of symbols shown on this nav line. (Defaults to 10)
 */
@property (nonatomic, strong) NSNumber *numberOfSymbols;

/**
 *  The time between animation intervals for the nav line.
 *	Default is 250.  Minimum is 100.
 */
@property (nonatomic, strong) NSNumber *intervalTime;

@end