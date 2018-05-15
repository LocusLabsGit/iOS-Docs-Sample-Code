//
//  LocusLabMapLoader.m
//  RecommendedImplementation
//
//  Copyright (c) 2015 LocusLabs. All rights reserved.
//

#import "LocusLabsMapLoader.h"
#import "LocusLabsMapBackgroundDownloader.h"

@interface LocusLabsMapLoader () <LLAirportDatabaseDelegate, LLAirportDelegate, LLMapViewDelegate>

@property (strong, nonatomic) NSString *venueId;

@property (nonatomic, weak) UIView *superview;
@property (nonatomic) LLAirportDatabase *airportDatabase;
@property (nonatomic) NSArray *airports;
@property (nonatomic) LLAirport *airport;
@property (strong, nonatomic) LLMarker *initialMarker;


@end

@implementation LocusLabsMapLoader

- (instancetype)initWithSuperview:(UIView *)superview
{
	self = [super init];
	if ( self )
	{
        _venueId = nil;
		_superview = superview;
    }
    
	return self;
}

- (void)loadMap:(NSString*)venueId showGate:(NSString*)gate
{
    if ( ![self.venueId isEqualToString:venueId] ) {
        _venueId = venueId;

        if ( _mapView != nil ) {
            [_mapView removeFromSuperview];
        }
        
        _mapView = [[LLMapView alloc] initWithFrame:self.superview.bounds];
        _mapView.delegate = self;
        
        if ( [self.delegate respondsToSelector:@selector(mapLoaderInitialized:)] )
        {
            [self.delegate mapLoaderInitialized:self];
        }      
        
        self.airportDatabase = [LLAirportDatabase airportDatabaseWithMapView:self.mapView];
        self.airportDatabase.delegate = self;

        [self.delegate mapLoaderReady:self];
        
        __weak typeof(self) weakSelf = self;
        [self.airportDatabase loadAirportAndMap:venueId initialSearch:gate iconUrl:@"images/pin-plane-takeoff.svg"
                                          block:^(LLAirport *airport, LLMap *map, LLFloor *floor, LLMarker *marker) {
                                              weakSelf.airport = airport;
                                              weakSelf.initialMarker = marker;
                                              [weakSelf initializeMap:floor map:map];
                                          }
         ];
    }
}

- (void)initializeMap:(LLFloor *)floor map:(LLMap *)map {
    _mapView.navigationDisclaimer = @"Estimated travel times are suggestions only and should not be utilized under certainty.\n\nBy selecting OK, you are acknowledging this and agree not to hold your air carrier or any third party liable for incorrect information.";
    _mapView.delegate = self;
    _mapView.map = map;
    _mapView.positioningEnabled = YES;
    [_mapView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
}

- (void)airportDatabase:(LLAirportDatabase *)airportDatabase airportLoadStatus:(NSString *)venueId percentage:(int)percent
{
	if ( [self.delegate respondsToSelector:@selector(mapLoader:isLoadingWithProgress:)] )
	{
		float progress = (float)percent / 100.0f;
		[self.delegate mapLoader:self isLoadingWithProgress:progress];
	}
}

- (void)mapViewReady:(LLMapView *)mapView
{
	[self resetMap];
	if ( [self.delegate respondsToSelector:@selector(mapLoaderReady:)] )
	{
		[self.delegate mapLoaderReady:self];

        
        // Start a background downloader of the arrival map.
        LocusLabsMapBackgroundDownloader *downloader = [LocusLabsMapBackgroundDownloader mapBackgroundDownloaderWithVenueId:@"lax"];
        [downloader downloadWithCompletionBlock:^(BOOL didDownload, NSError *err) {
            if (err) {
                NSLog(@"An error occurred while downloading the map: %@",err);
            } else {
                if (didDownload) {
                    NSLog(@"The map was downloaded.");
                } else {
                    NSLog(@"The latest version of the map was already on the device.");
                }
            }
        }];
	}
}

- (void)mapViewDidClickBack:(LLMapView *)mapView
{
    [self resetMap];    
	[self.delegate mapLoaderClosed:self];
}

- (void)resetMap
{
    self.mapView.map.center = self.initialMarker.position;
    self.mapView.map.radius = [NSNumber numberWithDouble:50.0];
}

@end