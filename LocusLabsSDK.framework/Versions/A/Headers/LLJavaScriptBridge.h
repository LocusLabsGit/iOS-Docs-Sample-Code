//
//  LLJavaScriptBridge.h
//  LocusLabsSDK
//
//  Created by Samuel Ziegler on 5/23/14.
//  Copyright (c) 2014 LocusLabs. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

@protocol LLJavaScriptBridgeObject <NSObject>

- (NSString *)uuid;

@end

@class LLJavaScriptBridge;

@protocol LLJavaScriptBridgeDelegate <NSObject>

- (void)javaScriptBridgeReady:(LLJavaScriptBridge *)javaScriptBridge;

@end

@interface LLJavaScriptBridge : NSObject <UIWebViewDelegate>

@property(nonatomic, strong) NSString *name;
@property (weak,nonatomic) id<LLJavaScriptBridgeDelegate> delegate;
@property (assign) BOOL ready;
@property (assign) BOOL isSharedBridge;

+ (LLJavaScriptBridge *)javaScriptBridgeWithWebView:(UIWebView *)webView;
+ (LLJavaScriptBridge *)sharedJavaScriptBridge;
+ (void)resetSharedJavaScriptBridge;
- (NSString *)toJSON:(id)object;

- (id)runJavaScript:(NSString *)javaScript;
- (void)javaScriptReady;
- (id)javaScriptCall:(NSString *)method;
- (id)javaScriptCall:(NSString *)method withArgument:(id)argument;
- (id)javaScriptCall:(NSString *)method withArguments:(NSArray *)arguments;
- (id)fromJavaScriptObject:(id)object klass:(Class)klass;
- (void)beginSession;
- (void)submitSessionEvent:(NSObject *)event;

- (void)registerJavaScriptBridgeObject:(NSObject<LLJavaScriptBridgeObject> *)object;
- (void)releaseJavaScriptBridgeObject:(NSObject<LLJavaScriptBridgeObject> *)object;
- (NSObject<LLJavaScriptBridgeObject> *)findJavaScriptBridgeObject:(NSString *)uuid;

@end