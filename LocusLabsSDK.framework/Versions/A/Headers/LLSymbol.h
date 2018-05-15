//
//  LLSymbol.h
//  LocusLabsSDK
//
//  Created by Glenn Dierkes on 12/20/14.
//  Copyright (c) 2014 LocusLabs. All rights reserved.
//

#import "LLPoint.h"

@interface LLSymbol : NSObject

@property (nonatomic, strong) LLPoint* anchor;
@property (nonatomic, strong) UIColor* fillColor;
@property (nonatomic) int fillOpacity;
@property (nonatomic) int rotation;
@property (nonatomic, strong) NSString* path;
@property (nonatomic, strong) UIColor* strokeColor;
@property (nonatomic) int strokeOpacity;
@property (nonatomic) int strokeWeight;
@property (nonatomic) int scale;

- (NSDictionary*)asJSON;

@end