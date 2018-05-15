//
//  ViewController.m
//  RecommendedPlaces
//
//  Created by Juan Kruger on 18/01/18.
//  Copyright © 2018 LocusLabs. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) LLAirport         *airport;
@property (nonatomic, strong) LLAirportDatabase *airportDatabase;
@property (nonatomic, strong) LLFloor           *floor;
@property (nonatomic, strong) LLMapView         *mapView;

@end

@implementation ViewController

#pragma mark Lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Initialize the LocusLabs SDK with the accountId provided by LocusLabs.
    [LLLocusLabs setup].accountId = @"A11F4Y6SZRXH4X";
    
    // Create a new LLAirportDatabase object: our top-level entry point into the LocusLabs SDK functionality.
    self.airportDatabase = [LLAirportDatabase airportDatabase];
    
    // Set its delegate: asynchronous calls to LLAirportDatabase are fielded by delegate methods.
    self.airportDatabase.delegate = self;
    
    // Initiate a request for the list of airports (to be processed later by LLAirportDatabaseDelegate.airportList)
    [self.airportDatabase listAirports];
}

- (void)didReceiveMemoryWarning {
   
    [super didReceiveMemoryWarning];
}

#pragma mark Custom

- (NSArray *)customRecommendedPlaces {
    
    NSMutableArray *customPlaces = [NSMutableArray array];
    
    // Create a custom Recommended Place to show a POI
    LLPlaceUI *ui = [LLPlaceUI defaultUI];
    ui.icon = @"bottombar-icon-nav.png"; // Supply any solid fill png. This one chosen as it is already in the bundle - you can supply your own
    ui.normalIconColor = [UIColor whiteColor];
    ui.selectedIconColor = [UIColor whiteColor];
    ui.marker = @"images/nav-badge-bus.svg"; // This image chosen as it is already in the bundle - you can supply your own
    
    // POI 519 is gate 68A at lax
    LLPlace *customPOIRecommendedPlace = [[LLPlace alloc] initWithBehavior:LLPlaceBehaviorPOI values:@[@"519"] displayName:@"Departure Gate" andUI:ui];
    [customPlaces addObject:customPOIRecommendedPlace];
    
//    // Create a custom Recommended Place to trigger a search
//    LLPlaceUI *uiSearch = [LLPlaceUI defaultUI];
//    uiSearch.icon = @"bottombar-icon-nav.png";
//    uiSearch.normalIconColor = [UIColor whiteColor];
//    uiSearch.selectedIconColor = [UIColor whiteColor];
//    uiSearch.marker = @"images/nav-badge-bus.svg";
//    
//    LLPlace *customSearchRecommendedPlace = [[LLPlace alloc] initWithBehavior:LLPlaceBehaviorSearch values:@[@"magazines"] displayName:@"Magazines" andUI:uiSearch];
//    [customPlaces addObject:customSearchRecommendedPlace];
    
    return customPlaces;
}

#pragma mark Delegates - LLAirportDatabase

- (void)airportDatabase:(LLAirportDatabase *)airportDatabase airportList:(NSArray *)airportList {
    
    [LLConfiguration sharedConfiguration].recommendedPlacesEnabled = YES;
    [self.airportDatabase loadAirport:@"lax"];
}

- (void)airportDatabase:(LLAirportDatabase *)airportDatabase airportLoaded:(LLAirport *)airport {
    
    // Store the loaded airport
    self.airport = airport;
    
    // Collect the list of buildingsInfos found in this airport and (arbitrarily) load the first one
    LLBuildingInfo *buildingInfo = [self.airport listBuildings][0];
    LLBuilding *building  = [self.airport loadBuilding:buildingInfo.buildingId];
    
    // Collect the list of floorInfos found in this building and (arbitrarily) load the first one
    LLFloorInfo *floorInfo = [building listFloors][0];
    self.floor = [building loadFloor:floorInfo.floorId];
    
    // Set all the delegates
    self.floor.delegate = self;
    
    // Load the map for the floor.  Map is sent via floor:mapLoaded:
    [self.floor loadMap];
}

#pragma mark Delegates - LLFloor

- (void)floor:(LLFloor *)floor mapLoaded:(LLMap *)map {
    
    // Create and initialize a new LLMapView and set its map and delegate
    LLMapView *mapView = [[LLMapView alloc] init];
    self.mapView = mapView;
    mapView.map = map;
    
    // Register for mapView delegate calls
    self.mapView.delegate = self;
    
    [self.view addSubview:mapView];
    
    // "constrain" the mapView to fill the entire screen
    [mapView setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSDictionary *views = NSDictionaryOfVariableBindings(mapView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[mapView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[mapView]|" options:0 metrics:nil views:views]];
}

#pragma mark Delegates - LLMapView

- (NSArray *)mapView:(LLMapView *)mapView willPresentPlaces:(NSArray *)places {

    // Show only 1 recommended place
    // return @[places[0]];

    // Show default recommended places
    // return places;

    // Show only the tray button (when tapped - it will open the tray showing all recommended places)
    // return [@[[NSNull null]] arrayByAddingObjectsFromArray:places];

    // Show custom recommended places
    return [self customRecommendedPlaces];
}

- (NSArray<NSString*> *)mapView:(LLMapView *)mapView willPresentSearchSuggestions:(NSArray<NSString*> *)suggestions {
    
    return @[@"Restaurants", @"Bars", @"Pharmacies", @"Baggage"];
}

- (BOOL)mapView:(LLMapView *)mapView didTapPOI:(NSString *)poiId {

    NSLog(@"ccc:%@", poiId);
    return YES;
}



@end
