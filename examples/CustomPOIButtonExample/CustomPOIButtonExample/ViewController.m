/*
//---------------------------------------------------------------------------
ViewController.m
CustomPOIButtonExample

Copyright (c) 2015 LocusLabs. All rights reserved.

---------------------------------------------------------------------------
READ ME FIRST!

This example demonstrates how to add custom buttons and corresponding
functionality to points of interest in the airport maps.
 
**Use**
 When a user taps on a location in the airport, a special view is displayed
 pertaining to that point of interest (POI). If the containing application
 implements the LLMapViewDelegate protocol, there is a method that is
 called requesting any supplemental buttons to display in that view. The ID
 of the POI the user tapped on is part of the information sent to the
 containing app to act on if relevant.
 
 The example below does two things with this information. It adds one button
 to all POIs regardless of the ID. It also checks the included .plist file in
 the project for any specific POIs to create additional buttons. In this case
 the restaurant in LAX, Ruby's Dinette, is the key POI, as signified by its
 ID (508) being included in the .plist file with associated metadata. Tapping
 on this POI in the map will display an additional button not available to
 other POIs.
 
**Key method**
 Below you'll find the implementation of
 - (NSArray*)mapView:(LLMapView*)mapView additionalViewsForPOI:(NSString*)poi
 
 This method can return either nil or an array of button objects. The buttons
 will display from left to right based on the order of the array.
 We recommend utilizing the LLIconButton class, as shown below, which will
 create a button in the style used in other parts of the SDK.

//---------------------------------------------------------------------------
*/
#import "ViewController.h"

@interface ViewController ()

@property (strong, nonatomic) LLAirportDatabase *airportDatabase;
@property (strong, nonatomic) LLAirport *airport;
@property (strong, nonatomic) LLFloor *floor;
@property (strong, nonatomic) LLMapView *mapView;
@property (strong, nonatomic) LLPositionManager *positionManager;
@property (nonatomic) NSDictionary *poiButtonList;

@end

@implementation ViewController


// ---------------------------------------------------------------------------------------------------------------------
// viewDidLoad
//
// Initialize LocusLabs and then load information about all the airports the user has access to
// ---------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
{
	[super viewDidLoad];
		
	// Initialize the LocusLabs SDK with the accountId provided by LocusLabs.
	[LLLocusLabs setup].accountId = @"A11F4Y6SZRXH4X";
	
	// Create a new LLAirportDatabase object: our top-level entry point into the LocusLabs SDK functionality.
	// Set its delegate: asynchronous calls to LLAirportDatabase are fielded by delegate methods.
	// Initiate a request for the list of airports (to be processed later by LLAirportDatabaseDelegate.airportList)
	self.airportDatabase = [LLAirportDatabase airportDatabase];
	self.airportDatabase.delegate = self;
	[self.airportDatabase listAirports];
	
	self.poiButtonList = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"POIMapping" ofType:@"plist"]];
}

// ---------------------------------------------------------------------------------------------------------------------
// buttonForPOI
//
// Implementation for retrieving the button information for a specific POI.
// In this case, loads a plist dictionary of values.
// ---------------------------------------------------------------------------------------------------------------------
- (LLIconButton*)buttonForPOI:(NSString*)poi
{
	if ( self.poiButtonList[poi] )
	{
		NSDictionary *poiData = self.poiButtonList[poi];
		NSString *imageName = poiData[@"imageName"];
		NSString *label = poiData[@"buttonLabel"];
		// Create button and return it
		LLIconButton *iconButton = [LLIconButton topIconButtonWithPadding:9 image:[UIImage imageNamed:imageName] andLabel:label];
		[iconButton addTarget:self action:@selector(customButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
		return iconButton;
	}
	return nil;
}

// ---------------------------------------------------------------------------------------------------------------------
// customButtonTapped
//
// Control event handler for button tap setup above.
// You could alternately use gesture recognizers instead of control events but we recommend them for simplicity.
// ---------------------------------------------------------------------------------------------------------------------
- (void)customButtonTapped:(LLIconButton*)sender
{
	NSLog(@"Custom Button tapped: %@", sender.label);
}

- (void)infoButtonTapped:(LLIconButton*)sender
{
	NSLog(@"Info button tapped");
}

@end

// ---------------------------------------------------------------------------------------------------------------------
// LLMapViewDelegate
//
// - mapViewReady:
//
// ---------------------------------------------------------------------------------------------------------------------
@implementation ViewController(LLMapViewDelegate)

// ---------------------------------------------------------------------------------------------------------------------
// mapViewReady
//
//  The mapView has finished loading asynchronously:
// -- Pan and zoom to an interesting area
// ---------------------------------------------------------------------------------------------------------------------
- (void)mapViewReady:(LLMapView *)mapView
{
	// Pan/zoom the map
	[self.mapView levelSelected:@"lax-default-Departures"];
	self.mapView.mapCenter = [[LLLatLng alloc] initWithLat:@33.941384 lng:@-118.402057];
	self.mapView.mapRadius = @190.0;
}

// ---------------------------------------------------------------------------------------------------------------------
// add custom buttons based on points of interest
// ---------------------------------------------------------------------------------------------------------------------
- (NSArray*)mapView:(LLMapView*)mapView additionalViewsForPOI:(NSString*)poi
{
	// Create button that applies to every POI
	LLIconButton *infoButton = [LLIconButton topIconButtonWithPadding:9 image:[UIImage imageNamed:@"info_icon"] andLabel:@"INFO"];
	[infoButton addTarget:self action:@selector(infoButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
	NSMutableArray *buttons = [NSMutableArray new];
	[buttons addObject:infoButton];
	
	// Check for any custom buttons specific to this POI
	LLIconButton *poiSpecficButton = [self buttonForPOI:poi];
	if ( poiSpecficButton )
	{
		[buttons addObject:poiSpecficButton];
	}
	
	return buttons;
}

@end


// ---------------------------------------------------------------------------------------------------------------------
//  LLAirportDatabaseDelegate
//
// - airportDatabase:airportList:
// - airportDatabase:airportLoaded:
//
// ---------------------------------------------------------------------------------------------------------------------
@implementation ViewController(LLAirportDatabaseDelegate)

// ---------------------------------------------------------------------------------------------------------------------
//  airportDatabase:airportList
//
//  Receive the list of available airports and (arbitrarily) pick one to show
// ---------------------------------------------------------------------------------------------------------------------
- (void)airportDatabase:(LLAirportDatabase *)airportDatabase airportList:(NSArray *)airportList
{
	[self.airportDatabase loadAirport:@"lax"];
}

// ---------------------------------------------------------------------------------------------------------------------
//  airportDatabase:airportLoaded
//
//  Receive the airport loaded via airportDatabase:loadAirport, then:
//
// - select a building from that airport
// - select a floor from that building
// - asynchronously load the map for that floor
// ---------------------------------------------------------------------------------------------------------------------
- (void)airportDatabase:(LLAirportDatabase *)airportDatabase airportLoaded:(LLAirport *)airport
{
	// Store the loaded airport
	self.airport = airport;
	
	// Collect the list of buildingsInfos found in this airport and (arbitrarily) load the first one
	LLBuildingInfo *buildingInfo = [self.airport listBuildings][0];
	LLBuilding *building  = [self.airport loadBuilding:buildingInfo.buildingId];
	
	// Collect the list of floorInfos found in this building and (arbitrarily) load the first one
	LLFloorInfo *floorInfo = [building listFloors][0];
	self.floor = [building loadFloor:floorInfo.floorId];
	
	// Make self the delegate for the floor, so we receive floor:mapLoaded: calls (below)
	// Make self the delegate for the airport, so we receive airport:navigationPath:from:toDestinations: (below)
	// Make self the delegate for the search engine, so we receive search:results: (below)
	// Make self the delegate for theairport, so we receive poiDatabase:poiLoaded: (below)
	self.floor.delegate = self;
	
	// Load the map for the floor.  Map is sent via floor:mapLoaded:
	[self.floor loadMap];
	
}

@end


// ---------------------------------------------------------------------------------------------------------------------
//  LLFloorDelegate
//
// -- floor:mapLoaded:
//
// ---------------------------------------------------------------------------------------------------------------------
@implementation ViewController(FloorDelegate)


// ---------------------------------------------------------------------------------------------------------------------
// floor:mapLoaded
//
// Callback for LLFloor.loadMap:
//
// Create an LLMapView (which is a UIView) and place it on the screen. LLMapView renders the map
// ---------------------------------------------------------------------------------------------------------------------
- (void)floor:(LLFloor *)floor mapLoaded:(LLMap *)map
{
	// Create and initialize a new LLMapView and set its map and delegate
	LLMapView *mapView = [[LLMapView alloc] init];
	self.mapView = mapView;
	mapView.map = map;
	mapView.delegate = self;
	
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
	self.mapView.shouldAllowSpaceForStatusBar = true;
	self.mapView.backButtonText = @"Back";
	self.mapView.navigationDisclaimer = @"Note: Navigation times are estimates and should not be considered guarrentied arrival time.";
	self.mapView.searchBarHidden = YES;
	
	// add the mapView as a subview
	[self.view addSubview:mapView];
	
	// "constrain" the mapView to fill the entire screen
	[mapView setTranslatesAutoresizingMaskIntoConstraints:NO];
	NSDictionary *views = NSDictionaryOfVariableBindings(mapView);
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[mapView]|" options:0 metrics:nil views:views]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[mapView]|" options:0 metrics:nil views:views]];
}

@end