//
//  LLJavaScriptFunction.h
//  LocusLabsSDK
//
//  Created by Samuel Ziegler on 5/23/14.
//  Copyright (c) 2014 LocusLabs. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LLJavaScriptBridge.h"

typedef void (^LLJavaScriptBlock)(NSArray *args);

@interface LLJavaScriptFunction : NSObject <LLJavaScriptBridgeObject>

@property (strong,nonatomic) NSString *uuid;
@property (weak,nonatomic) LLJavaScriptBridge *javaScriptBridge;

+ (LLJavaScriptFunction *)javaScriptFunctionWithJavaScriptBridge:(LLJavaScriptBridge *)javaScriptBridge;

/*
 * Create a LLJavaScriptFunction which executes the passed-in block when called from JavaScript.
 *
 * (It does this by creating an instance of a subclass of LLJavaScriptFunction which holds the block and calls
 * it from its execute method.)
 *
 * There are two advantages to this:
 *
 * - there is no need to subclass LLJavaScriptFunction for every callback
 * - it puts the callback code near the place of the call
 *
 * Beware:
 *
 * - the created object must be retained somewhere--so we're retaining everything in a global variable for now
 * - as with all blocks, if you use "self" inside the block, it should be a weak reference to self:
 *
 * Sample code:
 *
 *      __weak typeof(self) weakSelf = self;
 *     LLJavaScriptFunction *callback = [LLJavaScriptFunction bridge:self.javaScriptBridge andBlock:^(NSArray *args) {
 *         ...
 *         if ([weakSelf.delegate respondsToSelector:@selector(airportDatabase:airportList:)]) {
 *             [weakSelf.delegate airportDatabase:weakSelf airportList:airportInfos];
 *         }
 *     }];
 *
 *     [self javaScriptCall:@"listAirports" withArguments:@[callback, venueList]];
 */
+ (LLJavaScriptFunction *)javaScriptFunctionWithBridge:(LLJavaScriptBridge *)javaScriptBridge block:(LLJavaScriptBlock)block;

- (id)initWithJavaScriptBridge:(LLJavaScriptBridge *)javaScriptBridge;
- (void)execute:(NSArray *)args;
- (NSArray *)arguments;

@end