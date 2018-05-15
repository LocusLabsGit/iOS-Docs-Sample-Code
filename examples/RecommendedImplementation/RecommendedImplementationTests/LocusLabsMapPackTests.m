//
//  LocusLabsMapPackTests.m
//  RecommendedImplementation
//
//  Created by Sam Ziegler on 7/12/15.
//  Copyright (c) 2015 LocusLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "LocusLabsCache.h"
#import "LocusLabsMapPack.h"
#import "LocusLabsMapPackFinder.h"
#import "LocusLabsSDK/LocusLabsSDK.h"

@interface LocusLabsMapPackTests : XCTestCase

@property (strong,nonatomic) LocusLabsCache *cache;
@property (strong,nonatomic) LocusLabsMapPack *mapPack;

@end

@implementation LocusLabsMapPackTests


+ (LocusLabsCache *)randomCache
{
    NSUUID *uuid = [NSUUID UUID];
    NSString *cacheDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    cacheDirectory = [cacheDirectory stringByAppendingPathComponent:[uuid UUIDString]];
    
    return [[LocusLabsCache alloc] initWithCachePath:cacheDirectory];
}

+ (void)setUp
{
    [LLLocusLabs setup].accountId = @"A11F4Y6SZRXH4X";
}

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.cache = [LocusLabsMapPackTests randomCache];
    [self.cache setup];
    self.mapPack = [[LocusLabsMapPack alloc] initWithPath:[LocusLabsMapPackFinder mapPackFinder].newestMapPackPath cache:self.cache];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    [self.cache tearDown];
}

- (void)testMapPackNewestAvailable
{
    LocusLabsMapPack *mapPack = [LocusLabsMapPack mapPackNewestAvailable];
    XCTAssert(mapPack != nil);
}

- (void)testNewestAvailableVersion
{
    LocusLabsMapPack *mapPack = [LocusLabsMapPack mapPackNewestAvailable];
    XCTAssertEqualObjects(mapPack.version, @"2016-05-04T22:27:31");
}

- (void)testInstalledVersion
{
    XCTAssertNil(self.mapPack.installedVersion);
    [self.mapPack installWithCompletionBlock:^void (BOOL didInstall, NSError *err) {
        XCTAssertEqualObjects(self.mapPack.installedVersion, self.mapPack.version);
    }];
}

- (void)testNeedsInstall
{
    XCTAssert(self.mapPack.needsInstall);
    [self.mapPack installWithCompletionBlock:^void (BOOL didInstall, NSError *err) {
        XCTAssertFalse(self.mapPack.needsInstall);
    }];
}

@end
