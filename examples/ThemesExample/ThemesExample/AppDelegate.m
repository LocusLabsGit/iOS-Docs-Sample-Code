//
//  AppDelegate.m
//  ThemesExample
//
//  Created by Sam Ziegler on 7/19/16.
//  Copyright © 2016 LocusLabs. All rights reserved.
//

#import "AppDelegate.h"

#import <LocusLabsSDK/LocusLabsSDK.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [LLLocusLabs setup].accountId = @"A11F4Y6SZRXH4X";
    return YES;
}

@end
