//
//  AppDelegate.m
//  LocalizationExample
//
//  Copyright © 2016 LocusLabs. All rights reserved.
//

#import "AppDelegate.h"
#import <LocusLabsSDK/LocusLabsSDK.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[LLLocusLabs setup].accountId = @"A11F4Y6SZRXH4X";
	return YES;
}

@end