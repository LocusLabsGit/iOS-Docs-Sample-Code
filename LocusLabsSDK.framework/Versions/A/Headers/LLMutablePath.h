//
//  LLMutablePath.h
//  LocusLabsSDK
//
//  Created by Samuel Ziegler on 6/26/14.
//  Copyright (c) 2014 LocusLabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LLPath.h"

@class LLLatLng;

@interface LLMutablePath : LLPath

/**
 *  Add the given LLLatLng to the end of the path
 *
 *  @param latLng the LLLatLng to add
 */
- (void)addLatLng:(LLLatLng *)latLng;

@end