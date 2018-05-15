//
//  LocusLabMapLoader.h
//  RecommendedImplementation
//
//  Copyright (c) 2015 LocusLabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LocusLabsSDK/LocusLabsSDK.h>

@class LocusLabsMapLoader;

@protocol LocusLabsMapLoaderDelegate <NSObject>

@required
- (void)mapLoaderReady:(LocusLabsMapLoader*)loader;
- (void)mapLoaderClosed:(LocusLabsMapLoader*)loader;

@optional
- (NSString*)departingGateForMapLoader:(LocusLabsMapLoader*)loader;
- (void)mapLoaderFinishedDownload:(LocusLabsMapLoader*)loader;
- (void)mapLoader:(LocusLabsMapLoader*)loader isLoadingWithProgress:(float)progress;
- (void)mapLoader:(LocusLabsMapLoader*)loader failedWithError:(NSError*)error;

@end

@interface LocusLabsMapLoader : NSObject

- (instancetype)initWithVenueId:(NSString*)venueId andSuperview:(UIView*)superview;
- (instancetype)initWithVenueId:(NSString *)venueId andMapView:(LLMapView*)mapView;
- (void)loadMap;
- (void)resetMap;

@property (nonatomic, weak) id<LocusLabsMapLoaderDelegate> delegate;
@property (nonatomic, readonly) NSString *venueId;
@property (nonatomic, readonly) LLMapView *mapView;

@end