//
// Created by Jeff Goldberg on 3/23/15.
// Copyright (c) 2015 LocusLabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LLFunctional: NSObject

+ (void)each:(NSArray*)array usingBlock:(void (^)(id))block;
+ (void)eachWithIndex:(NSArray*)array usingBlock:(void (^)(id, NSUInteger index))block;
+ (NSArray*)collect:(NSArray*)array usingBlock:(id (^)(id))block;
+ (NSArray*)collectDictionary:(NSDictionary*)dictionary usingBlock:(id (^)(id key, id value))block;
+ (NSInteger)reduce:(NSArray*)array initialValue:(NSInteger)initial usingBlock:(NSInteger (^)(NSInteger memo, id item))block;
+ (id)findIn:(NSArray*)array usingBlock:(BOOL (^)(id item))block;
+ (NSArray*)filter:(NSArray*)array usingBlock:(BOOL (^)(id item))block;
+ (id)findInDictionary:(NSDictionary*)dictionary usingBlock:(BOOL (^)(id item))block;
+ (NSArray*)pluck:(NSArray*)array propertyName:(NSString*)propertyName;
+ (NSArray*)pluckFromDictionaryValues:(NSDictionary*)dictionary propertyName:(NSString*)propertyName;

@end