//
//  ViewController.m
//  DirectionsDraw
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
@property (nonatomic, strong) LLNavPoint        *navPoint;

- (LLCircle *)createCircleCenteredAt:(LLLatLng*)latLng onFloor:(NSString*)floorId withRadius:(NSNumber*)radius andColor:(UIColor*)color;
- (void)drawRouteWithWaypoints:(NSArray *)waypoints startFloor:(NSString *)floorID;
- (void)showSampleRoute;

@end

@implementation ViewController

#pragma mark Lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Initialize the LocusLabs SDK with the accountId provided by LocusLabs
    [LLLocusLabs setup].accountId = @"A11F4Y6SZRXH4X";
    
    // Get an instance of the LLAirportDatabase and register as its delegate
    self.airportDatabase = [LLAirportDatabase airportDatabase];
    self.airportDatabase.delegate = self;
    
    // Request a list of airports - the "airportList" delegate method will be called when the list is ready
    [self.airportDatabase listAirports];
}

#pragma mark Custom

- (LLCircle *)createCircleCenteredAt:(LLLatLng*)latLng onFloor:(NSString*)floorId withRadius:(NSNumber*)radius andColor:(UIColor*)color {
    
    LLCircle *circle = [LLCircle circleWithCenter:latLng radius:radius];
    [circle setFillColor:color];
    circle.floorView = [self.mapView getFloorViewForId:floorId];
    
    return circle;
}

- (void)drawRouteWithWaypoints:(NSArray *)waypoints startFloor:(NSString *)floorID {
 
    LLMutablePath *path = [[LLMutablePath alloc] init];
    for (LLWaypoint *waypoint in waypoints) {
        
        [path addLatLng:waypoint.latLng];
        
        // Add a black circle at the destination
        if ([waypoint.isDestination boolValue]) {
            
            [self createCircleCenteredAt:waypoint.latLng onFloor:waypoint.floorId withRadius:@5 andColor:[UIColor blackColor]];
        }
    }
    
    // Create a new LLPolyline object and set its path
    LLPolyline *polyline = [[LLPolyline alloc] init];
    [polyline setPath:path];
    polyline.floorView = [self.mapView getFloorViewForId:floorID];
}

- (void)showSampleRoute {
    
    LLLatLng *point1LatLon = [[LLLatLng alloc] initWithLat:@33.940627 lng:@-118.401892];
    LLLatLng *point2LatLon = [[LLLatLng alloc] initWithLat:@33.9410700 lng:@-118.399598];
    
    LLPosition *point1 = [[LLPosition alloc] initWithFloor:self.floor latLng:point1LatLon];
    LLPosition *point2 = [[LLPosition alloc] initWithFloor:self.floor latLng:point2LatLon];
    
    [self.airport navigateFrom:point1 to:point2];
}

#pragma mark Delegates - LLAirport

- (void)airport:(LLAirport *)airport navigationPath:(LLNavigationPath *)navigationPath from:(LLPosition *)startPosition toDestinations:(NSArray *)destinations  {
    
    [self drawRouteWithWaypoints:navigationPath.waypoints startFloor:startPosition.floorId];
}

#pragma mark Delegates - LLAirportDatabase

- (void)airportDatabase:(LLAirportDatabase *)airportDatabase airportList:(NSArray *)airportList {
    
    [self.airportDatabase loadAirport:@"lax"];
}

- (void)airportDatabase:(LLAirportDatabase *)airportDatabase airportLoaded:(LLAirport *)airport {
    
    self.airport = airport;
    self.airport.delegate = self;
    
    LLBuilding *building  = [self.airport loadBuilding:@"lax-south"];
    self.floor = [building loadFloor:@"lax-south-departures"];
    
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
    
    self.mapView.delegate = self;
    
    // Set the mapview's layout constraints
    mapView.translatesAutoresizingMaskIntoConstraints = NO;
    [mapView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor].active = YES;
    [mapView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor].active = YES;
    [mapView.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [mapView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
}

#pragma mark Delegates - LLMapView

- (void)mapViewReady:(LLMapView *)mapView {
    
    // Pan & zoom the map
    [self.mapView levelSelected:@"lax-south-departures"];
    self.mapView.mapCenter = [[LLLatLng alloc] initWithLat:@33.941384 lng:@-118.402057];
    self.mapView.mapRadius = @190.0;
    
    [self showSampleRoute];
}

@end
