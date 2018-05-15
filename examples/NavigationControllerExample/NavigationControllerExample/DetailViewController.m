//
//  DetailViewController.m
//  NavigationControllerExample
//
//  Created by Jeff Goldberg on 3/4/15.
//  Copyright (c) 2015 LocusLabs. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()
@property (strong, nonatomic) LLFloor *floor;
@property (strong, nonatomic) LLMapView *mapView;
@property (strong,nonatomic) UIProgressView *progressView;

@end

@implementation DetailViewController

// ---------------------------------------------------------------------------------------------------------------------
// viewWillAppear
//
// Hide the navigation bar!
// ---------------------------------------------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

// ---------------------------------------------------------------------------------------------------------------------
// viewWillDisappear
//
// Display the navigation bar again
// ---------------------------------------------------------------------------------------------------------------------
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.mapView removeFromSuperview];
    self.mapView = nil;
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

// ---------------------------------------------------------------------------------------------------------------------
// preferredStatusBarStyle
//
// Set the status bar text color to white
// ---------------------------------------------------------------------------------------------------------------------
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end


@implementation DetailViewController(FloorDelegate)

// ---------------------------------------------------------------------------------------------------------------------
// floor:mapLoaded
//
// Callback for LLFloor.loadMap:
//
// Create a LLMapView (which is a UIView) and place it on the screen. LLMapView renders the map
// ---------------------------------------------------------------------------------------------------------------------
- (void)floor:(LLFloor *)floor mapLoaded:(LLMap *)map {
    // Create and initialize a new LLMapView and set its map and delegate
    LLMapView *mapView = [[LLMapView alloc] initWithFrame:self.view.bounds];
	[mapView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    self.mapView = mapView;
    mapView.map = map;
    mapView.shouldAllowSpaceForStatusBar = YES;
    mapView.searchBarBackgroundColor = [UIColor lightGrayColor];
    mapView.backButtonText = @"Back";
    mapView.delegate = self;

    // add the mapView as a subview
    [self.view addSubview:mapView];
}
@end

@implementation DetailViewController(MapViewDelegate)

// ---------------------------------------------------------------------------------------------------------------------
//  mapViewDidClickBack
//
//  The user clicked the back button; return to the master view controller
// ---------------------------------------------------------------------------------------------------------------------
- (void)mapViewDidClickBack:(LLMapView *)mapView {
    [self.navigationController popViewControllerAnimated:YES];
}

@end

@implementation DetailViewController(AirportDatabaseDelegate)

// ---------------------------------------------------------------------------------------------------------------------
//  airportDatabase:airportLoadStarted
//
//  An airport will be loaded; since it may take a while to load, we put up a progress bar
// ---------------------------------------------------------------------------------------------------------------------
- (void)airportDatabase:(LLAirportDatabase *)airportDatabase airportLoadStarted:(NSString*)venueId {

    // create a progress bar
    self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    [self.view addSubview:self.progressView];

    self.progressView.translatesAutoresizingMaskIntoConstraints = NO;

    NSDictionary *views = [NSDictionary dictionaryWithObject:self.progressView forKey:@"progressBar"];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(30)-[progressBar]-(30)-|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(250)-[progressBar]-(250)-|" options:0 metrics:nil views:views]];
    self.progressView.progress = 0.0;
}

// ---------------------------------------------------------------------------------------------------------------------
//  airportDatabase:airportLoadStatus:percentage
//
//  Update the progress bar based on the current status of the load
// ---------------------------------------------------------------------------------------------------------------------
- (void)airportDatabase:(LLAirportDatabase *)airportDatabase airportLoadStatus:(NSString*)venueId percentage:(int)percent {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.progressView setProgress:percent/100.0 animated:YES];
    });
}

// ---------------------------------------------------------------------------------------------------------------------
//  airportDatabase:airportLoadCompleted
//
//  Remove the progress bar now that the load is completed
// ---------------------------------------------------------------------------------------------------------------------
- (void)airportDatabase:(LLAirportDatabase *)airportDatabase airportLoadCompleted:(NSString*)venueId {
    [self.progressView removeFromSuperview];
}

// ---------------------------------------------------------------------------------------------------------------------
//  airportDatabase:airportLoadFailed:code:message:
//
//  The load failed: post a message and remove the progress bar
// ---------------------------------------------------------------------------------------------------------------------
- (void)airportDatabase:(LLAirportDatabase *)airportDatabase airportLoadFailed:(NSString*)venueId code:(LLDownloaderError)errorCode message:(NSString*)message {
    [self.progressView removeFromSuperview];
    [[[UIAlertView alloc] initWithTitle:@"Assets" message:@"Unable to download assets." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
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
- (void)airportDatabase:(LLAirportDatabase *)airportDatabase airportLoaded:(LLAirport *)airport {

    // Collect the list of buildingsInfos found in this airport and (arbitrarily) load the first one
    LLBuildingInfo *buildingInfo = [airport listBuildings][0];
    LLBuilding *building  = [airport loadBuilding:buildingInfo.buildingId];

    // Collect the list of floorInfos found in this building and (arbitrarily) load the first one
    LLFloorInfo *floorInfo = [building listFloors][0];
    LLFloor *floor = [building loadFloor:floorInfo.floorId];

    floor.delegate = self;

    // Load the map for the floor.  Map is sent via floor:mapLoaded:
    [floor loadMap];
}


@end
