//
//  LLIconSequence.h
//  LocusLabsSDK
//
//  Created by Glenn Dierkes on 12/20/14.
//  Copyright (c) 2014 LocusLabs. All rights reserved.
//

#import "LLSymbol.h"

@interface LLIconSequence : NSObject

@property (nonatomic) bool fixedRotation;
@property (nonatomic, strong) LLSymbol* icon;
@property (nonatomic, strong) NSString* repeat;
@property (nonatomic, strong) NSString* offset;

- (NSDictionary*)asJSON;

@end