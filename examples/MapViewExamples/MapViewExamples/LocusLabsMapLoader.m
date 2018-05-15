//
//  LocusLabMapLoader.m
//  RecommendedImplementation
//
//  Copyright (c) 2015 LocusLabs. All rights reserved.
//

#import "LocusLabsMapLoader.h"
#import "LocusLabsMapBackgroundDownloader.h"
#import "LocusLabsMapPack.h"

@interface LocusLabsMapLoader () <LLAirportDatabaseDelegate, LLBuildingDelegate, LLAirportDelegate, LLPositionManagerDelegate, LLFloorDelegate, LLSearchDelegate, LLPOIDatabaseDelegate, LLMapViewDelegate>

@property (nonatomic, weak) UIView *superview;
@property (nonatomic) LLAirportDatabase *airportDatabase;
@property (nonatomic) NSArray *airports;
@property (nonatomic) LLAirport *airport;
@property (nonatomic) NSArray *buildings;
@property (nonatomic) LLBuilding *building;
@property (nonatomic) NSArray *floors;
@property (nonatomic) LLFloor *floor;
@property (nonatomic) NSArray *waypointCircles;
@property (nonatomic) NSArray *poiMarkers;
@property (nonatomic) LLPositionManager *positionManager;
@property (nonatomic) LLPolyline *navigationPath;
@property (nonatomic) LLNavPoint *navPoint;
@property (nonatomic) LLSearch *search;
@property (nonatomic) LLPOIDatabase *poiDatabase;
@property (nonatomic) LLMarker *gateMarker;
@property (nonatomic) LLFloorView *gateFloorView;
@property (nonatomic) LocusLabsMapBackgroundDownloader *mapBackgroundDownloader;

@end

@implementation LocusLabsMapLoader

- (instancetype)initWithVenueId:(NSString *)venueId andSuperview:(UIView *)superview
{
	self = [super init];
	if ( self )
	{
		_venueId = venueId;
		_superview = superview;
	}
	return self;
}

- (instancetype)initWithVenueId:(NSString *)venueId andMapView:(LLMapView *)mapView
{
	_mapView = mapView;
	return [self initWithVenueId:venueId andSuperview:_mapView.superview];
}

- (void)loadMap
{
	self.mapBackgroundDownloader = [LocusLabsMapBackgroundDownloader mapBackgroundDownloaderWithVenueId:self.venueId];
	
	// Install the map pack we are shipping with this app.  Map Packs are optional.  They allow you to ship a snapshot of your maps so that your users have them available to them even if they don't have a network connection when they first run the app.  Contact support@locuslabs.com to get a map pack for your account.
	[LocusLabsMapPack mapPackInstallWithCompletionBlock:^void (BOOL didInstall, NSError *err) {
		if (err) {
			NSLog(@"An error occurred while installing the map pack: %@",err);
		} else {
			if (didInstall) {
				NSLog(@"The map pack was installed.");
			} else {
				NSLog(@"The installed maps are up to date, no need to install the map pack.");
			}
		}
		
		[self.mapBackgroundDownloader downloadWithCompletionBlock:^(BOOL didDownload, NSError *err) {
			if (err) {
				NSLog(@"An error occurred while downloading the map: %@",err);
			} else {
				if (didDownload) {
					NSLog(@"The map was downloaded.");
				} else {
					NSLog(@"The latest version of the map was already on the device.");
				}
			}
			dispatch_async(dispatch_get_main_queue(), ^{
				self.airportDatabase = [LLAirportDatabase airportDatabase];
				self.airportDatabase.delegate = self;
				[self.airportDatabase listAirports];
			});
		}];
	}];
}

- (void)airportDatabase:(LLAirportDatabase *)airportDatabase airportList:(NSArray *)airportList
{
	self.airports = airportList;
	[self.airportDatabase loadAirport:self.venueId];
}

- (void)airportDatabase:(LLAirportDatabase *)airportDatabase airportLoaded:(LLAirport *)theAirport
{
	self.airport = theAirport;
	self.airport.delegate = self;
	[self.airport listBuildings];
	if ( [self.delegate respondsToSelector:@selector(mapLoaderFinishedDownload:)] )
	{
		[self.delegate mapLoaderFinishedDownload:self];
	}
}

- (void)airportDatabase:(LLAirportDatabase *)airportDatabase airportLoadFailed:(NSString *)venueId code:(LLDownloaderError)errorCode message:(NSString *)message
{
	if ( [self.delegate respondsToSelector:@selector(mapLoader:failedWithError:)] )
	{
		NSError *error = [NSError errorWithDomain:@"com.locuslabs.sdk" code:errorCode userInfo:@{NSLocalizedDescriptionKey : message}];
		[self.delegate mapLoader:self failedWithError:error];
	}
}

- (void)airportDatabase:(LLAirportDatabase *)airportDatabase airportLoadStatus:(NSString *)venueId percentage:(int)percent
{
	if ( [self.delegate respondsToSelector:@selector(mapLoader:isLoadingWithProgress:)] )
	{
		float progress = (float)percent / 100.0f;
		[self.delegate mapLoader:self isLoadingWithProgress:progress];
	}
}

- (void)airport:(LLAirport *)airport buildingList:(NSArray *)theBuildings
{
	self.buildings = theBuildings;
    if (self.airport.defaultBuildingId) {
        [self.airport loadBuilding:airport.defaultBuildingId];
    } else {
        LLBuildingInfo *buildingInfo = [airport listBuildings][0];
        [self.airport loadBuilding:buildingInfo.buildingId];
    }
}

- (void)airport:(LLAirport *)airport buildingLoaded:(LLBuilding *)theBuilding
{
	self.building = theBuilding;
	self.building.delegate = self;
	[self.building listFloors];
}

- (void)building:(LLBuilding *)building floorList:(NSArray *)theFloors
{
	self.floors = theFloors;
    NSString *defaultFloorId = self.building.defaultFloorId;
    if (defaultFloorId) {
        [self.building loadFloor:defaultFloorId];
    } else {
        LLFloorInfo *floorInfo = theFloors[0];
        [self.building loadFloor:floorInfo.floorId];
    }
}

- (void)building:(LLBuilding *)building floorLoaded:(LLFloor *)theFloor
{
	self.floor = theFloor;
	self.floor.delegate = self;
	[self.floor loadMap];
}

- (void)floor:(LLFloor *)floor mapLoaded:(LLMap *)map
{
	if (!_mapView)
	{
		_mapView = [[LLMapView alloc] initWithFrame:self.superview.bounds];
		[_mapView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
	}
	_mapView.navigationDisclaimer = @"Estimated travel times are suggestions only and should not be utilized under certainty.\n\nBy selecting OK, you are acknowledging this and agree not to hold your air carrier or any third party liable for incorrect information.";
	_mapView.delegate = self;
	_mapView.map = map;
	_mapView.positioningEnabled = YES;
	
	self.poiDatabase = [self.airport poiDatabase];
	self.poiDatabase.delegate = self;
}

- (void)mapViewReady:(LLMapView *)mapView
{
	[self resetMap];
	if ( [self.delegate respondsToSelector:@selector(mapLoaderReady:)] )
	{
		[self.delegate mapLoaderReady:self];
	}
}

- (void)search:(LLSearch *)search results:(LLSearchResults *)searchResults
{
	LLLogDebug(@"%@ %@",searchResults.query,searchResults.results);
	
	for (LLSearchResult *searchResult in searchResults.results) {
		[self.poiDatabase loadPOI:searchResult.poiId];
		LLMarker *marker = [[LLMarker alloc] init];
		marker.floorId = searchResult.position.floorId;
		self.gateFloorView = [self.mapView getFloorViewForId:searchResult.position.floorId];
		marker.floorView = self.gateFloorView;
		marker.position = searchResult.position.latLng;
		marker.iconUrl = @"images/pin-plane-takeoff.svg";
		[_mapView levelSelected:marker.floorId];
		
		self.gateMarker = marker;
	}
	
	if ( [searchResults.results count] == 1 ) {
		self.mapView.map.center = [[LLLatLng alloc] initWithLat:[NSNumber numberWithFloat:self.gateMarker.position.lat.floatValue] lng:self.gateMarker.position.lng];
		self.mapView.map.radius = [NSNumber numberWithDouble:50.0];
	}
}

- (void)poiDatabase:(LLPOIDatabase *)poiDatabase poiLoaded:(LLPOI *)poi
{
	//NSLog(@"%@: %@ (%f,%f)",poi.poiId,poi.name,[poi.position.latLng.lat floatValue],[poi.position.latLng.lng floatValue]);
	[self.mapView addUserPOI:poi userLabel:@"Departing Gate"];
}

- (void)airport:(LLAirport *)airport navigationPath:(LLNavigationPath *)theNavigationPath from:(LLPosition *)startPosition toDestinations:(NSArray *)destinations
{
	NSLog(@"Number of waypoints: %lu",(unsigned long)[theNavigationPath.waypoints count]);
	
	LLMutablePath *path = [[LLMutablePath alloc] init];
	NSMutableArray *newWaypointCircles = [NSMutableArray array];
	for (LLWaypoint *waypoint in theNavigationPath.waypoints) {
		[path addLatLng:waypoint.latLng];
		if ([waypoint.isDestination boolValue]) {
			LLCircle *waypointCircle = [LLCircle circleWithCenter:waypoint.latLng radius:[NSNumber numberWithInt:5]];
			waypointCircle.floorView = self.mapView.getFloorViewForCurrentLevel;
			[waypointCircle setFillColor:[UIColor blackColor]];
			[newWaypointCircles addObject:waypointCircle];
		}
	}
	self.waypointCircles = newWaypointCircles;
	
	self.navigationPath = [[LLPolyline alloc] init];
	[self.navigationPath setPath:path];
	self.navigationPath.floorView = self.mapView.getFloorViewForCurrentLevel;
}

- (void)mapViewDidClickBack:(LLMapView *)mapView
{
	[self.delegate mapLoaderClosed:self];
}

- (void)mapView:(LLMapView *)mapView modeChanged:(LLMapViewMode)mode
{
	switch (mode) {
		case LLMapViewModeNavigation:
			self.gateMarker.floorView = nil;
			break;
			
		default:
			self.gateMarker.floorView = self.gateFloorView;
			break;
	}
}

- (void)resetMap
{
	self.search = [self.airport search];
	self.search.delegate = self;
	
	if (self.gateMarker) {
		self.mapView.map.center = [[LLLatLng alloc] initWithLat:[NSNumber numberWithFloat:self.gateMarker.position.lat.floatValue] lng:self.gateMarker.position.lng];
		self.mapView.map.radius = [NSNumber numberWithDouble:50.0];
		return;
	}
	if ( [self.delegate respondsToSelector:@selector(departingGateForMapLoader:)] && [self.delegate departingGateForMapLoader:self] )
	{
		[self.search search:[self.delegate departingGateForMapLoader:self]];
	}
}

@end