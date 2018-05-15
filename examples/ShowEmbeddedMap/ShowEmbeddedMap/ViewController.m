//
//  ViewController.m
//  ShowEmbeddedMap
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

@end

@implementation ViewController

#pragma mark Lifecycle

- (void)viewDidLoad {

    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:0.90 alpha:1.0];
    
    // Initialize the LocusLabs SDK with the accountId provided by LocusLabs
    [LLLocusLabs setup].accountId = @"A11F4Y6SZRXH4X";
    
    // Get an instance of the LLAirportDatabase and register as its delegate
    self.airportDatabase = [LLAirportDatabase airportDatabase];
    self.airportDatabase.delegate = self;
    
    // Request a list of airports - the "airportList" delegate method will be called when the list is ready
    [self.airportDatabase listAirports];
}

#pragma mark Delegates - LLAirportDatabase

- (void)airportDatabase:(LLAirportDatabase *)airportDatabase airportList:(NSArray *)airportList {
    
    [self.airportDatabase loadAirport:@"lax"];
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
}

#pragma mark Delegates - LLFloor

- (void)floor:(LLFloor *)floor mapLoaded:(LLMap *)map {
    
    // Create a new LLMapView, set its map and add it as a subview
    LLMapView *mapView = [[LLMapView alloc] init];
    self.mapView = mapView;
    self.mapView.map = map;
    [self.view addSubview:mapView];
    
    // Set the mapView's delegate - this will enable us to hide the 2 Recommended Places buttons (bottom right corner of the map)
    self.mapView.delegate = self;
    
    // Set the mapview's layout constraints
    mapView.translatesAutoresizingMaskIntoConstraints = NO;
    [mapView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor].active = YES;
    [mapView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor].active = YES;
    [mapView.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:100].active = YES;
    [mapView.heightAnchor constraintEqualToConstant:220].active = YES;
    
    // Hide selected UI elements - these are likely not required when embedding
    mapView.searchBarHidden = YES;
    mapView.bottomBarHidden = YES;
}

#pragma mark Delegates - LLMapView

- (NSArray *)mapView:(LLMapView *)mapView willPresentPlaces:(NSArray *)places {
    
    // Return an empty array to hide all Recommended Places buttons (bottom right corner of the map)
    return @[];
}

@end
