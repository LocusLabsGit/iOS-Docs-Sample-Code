//
//  ViewController.m
//  UICustomization
//
//  Created by Juan Kruger on 31/01/18.
//  Copyright © 2018 LocusLabs. All rights reserved.
//

#import "ViewController.h"



@interface ViewController ()

@property (nonatomic, strong) LLAirport         *airport;
@property (nonatomic, strong) LLAirportDatabase *airportDatabase;
@property (nonatomic, strong) LLFloor           *floor;
@property (nonatomic, weak)   LLMapView         *mapView;
@property (nonatomic, strong) LLPositionManager           *positionManager;

@end

@implementation ViewController

#pragma mark Lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Initialize the LocusLabs SDK with the accountId provided by LocusLabs
    [LLLocusLabs setup].accountId = @"A1ZLZAASJQ9LT8"; // Collinson - cl positioning
   // [LLLocusLabs setup].accountId = @"A1BYS1VRDHMZE3"; // Sita - beacon positioning
    // Get an instance of the LLAirportDatabase and register as its delegate
    self.airportDatabase = [LLAirportDatabase airportDatabase];
    self.airportDatabase.delegate = self;
    
    // Request a list of airports - the "airportList" delegate method will be called when the list is ready
    [self.airportDatabase listAirports];
    
    [LLConfiguration sharedConfiguration].recommendedPlacesEnabled = YES;
}

#pragma mark Delegates - LLAirportDatabase

- (void)airportDatabase:(LLAirportDatabase *)airportDatabase airportList:(NSArray *)airportList {
    
    [self.airportDatabase loadAirport:@"hkg"];
}

- (void)airportDatabase:(LLAirportDatabase *)airportDatabase airportLoaded:(LLAirport *)airport {
    
    self.airport = airport;
    
    // Get a list of buildings in this airport and load the first one
    LLBuildingInfo *buildingInfo = [self.airport listBuildings][0];
    LLBuilding *building  = [self.airport loadBuilding:buildingInfo.buildingId];
    
    // Get a list of floors for the building and load the first one
    LLFloorInfo *floorInfo = [building listFloors][0];
    self.floor = [building loadFloor:floorInfo.floorId];
    
    // Set the floor delegate and load its map - mapLoaded is called when loading is complete
    self.floor.delegate = self;
    [self.floor loadMap];
    
    self.positionManager = [[LLPositionManager alloc] initWithAirports:@[self.airport]];
    self.positionManager.delegate = self;
    
    // Start with passive positioning to conserve battery
    //self.positionManager.passivePositioning = YES;
}

#pragma mark Delegates - LLFloor

- (void)floor:(LLFloor *)floor mapLoaded:(LLMap *)map {
    
    // Create a new LLMapView, set its map and add it as a subview
    LLMapView *mapView = [[LLMapView alloc] init];
    self.mapView = mapView;
    self.mapView.map = map;
    [self.view addSubview:mapView];
    
    self.mapView.delegate = self;
    self.mapView.positioningEnabled = YES;
    
    
    // Set the mapview's layout constraints
    mapView.translatesAutoresizingMaskIntoConstraints = NO;
    [mapView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor].active = YES;
    [mapView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor].active = YES;
    [mapView.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [mapView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    
    [self.mapView setSearchBarBackgroundColor:[UIColor colorWithRed:252.0/255.0 green:251.0/255.0 blue:248.0/255.0 alpha:1.0]];

    LLThemeBuilder *themeBuilder = [LLThemeBuilder themeBuilderWithTheme:[LLTheme defaultTheme]];
    [themeBuilder setProperty:@"MapView.TopBar.SearchBar.Text.textColor" value:[UIColor lightGrayColor]];
    [themeBuilder setProperty:@"MapView.BottomBar.backgroundColor" value:[UIColor colorWithRed:252.0/255.0 green:251.0/255.0 blue:248.0/255.0 alpha:1.0]];
    [themeBuilder setProperty:@"MapView.BottomBar.Button.Title.textColor" value:[UIColor lightGrayColor]];
    self.mapView.theme = themeBuilder.theme;
}

#pragma mark Delegates - LLMapView

- (void)mapViewReady:(LLMapView *)mapView {
    NSLog(@"READY");
   // [self.mapView performSelector:@selector(refreshPlaces) withObject:nil afterDelay:1.0];
}

- (NSArray *)mapView:(LLMapView *)mapView willPresentPlaces:(NSArray *)places {
    
//    for (LLPlace *place in places) {
//
//
//    }
    NSLog(@"PLACES")    ;
    return places;
}

#pragma mark Delegates - LLPositionManager

- (void)positionManager:(LLPositionManager *)positionManager positioningAvailable:(BOOL)positioningAvailable {
    
    if (positioningAvailable) {
        
        NSLog(@"Positioning available");
    }
    else {
        
        NSLog(@"Positioning not available - determine if bluetooth is active and prompt user if not.");
    }
}

- (void)positionManager:(LLPositionManager *)positionManager positionChanged:(LLPosition *)position {
    
    if (!position) {
        
        NSLog(@"Unable to locate user");
        return;
    }
    
    // If we're near a venue, start active positioning (more battery intensive but provides accurate tracking)
    if (position.venueId) {
        
        self.positionManager.activePositioning = YES;
        NSLog(@"Near venueId: %@", position.venueId);
        
    }
}

@end
