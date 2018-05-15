//
//  LLJavaScriptObject.h
//  LocusLabsSDK
//
//  Created by Samuel Ziegler on 5/23/14.
//  Copyright (c) 2014 LocusLabs. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LLJavaScriptBridge.h"

@interface LLJavaScriptObject : NSObject <LLJavaScriptBridgeObject>

@property (strong,nonatomic) NSString *uuid;
@property (weak,nonatomic) LLJavaScriptBridge *javaScriptBridge;

- (id)initWithJavaScriptBridge:(LLJavaScriptBridge *)javaScriptBridge uuid:(NSString *)uuid;

- (void)javaScriptConstructor;
- (void)javaScriptConstructorWithArgument:(id)argument;
- (void)javaScriptConstructorWithArguments:(NSArray *)arguments;
- (id)javaScriptCall:(NSString *)method;
- (id)javaScriptCall:(NSString *)method withArgument:(id)argument;
- (id)javaScriptCall:(NSString *)method withArguments:(NSArray *)arguments;
- (id)javaScriptValueForKey:(NSString *)key;
- (void)javaScriptSetValue:(id)value forKey:(NSString *)key;

@end