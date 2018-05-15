#import "MainViewController.h"

// ---------------------------------------------------------------------------------------------------------------------
//
// This example shows you how to dynamically change the markers associated with specific POIs, overriding the default
// LocusLabs POI markers.
//
// The example creates a list of all of the restrooms and starbucks in LAX and replaces the POI markers which appear when
// they appear in search results or when you tap on them.
//
// To try out the example, run the app and search for 'coffee' or try tapping on a restroom.
//
// ---------------------------------------------------------------------------------------------------------------------

// ---------------------------------------------------------------------------------------------------------------------
// MainViewController
//
//  - viewDidLoad
// ---------------------------------------------------------------------------------------------------------------------
@interface MainViewController ()

@property (strong, nonatomic) LLAirportDatabase *airportDatabase;
@property (strong, nonatomic) LLAirport *airport;
@property (strong, nonatomic) LLFloor *floor;
@property (strong, nonatomic) LLMapView *mapView;
@property (strong, nonatomic) LLSearch *search;
@property (strong, nonatomic) NSMutableSet *starbucksPOIs;
@property (strong, nonatomic) NSMutableSet *restroomPOIs;

@end

@implementation MainViewController


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
    
    self.starbucksPOIs = [NSMutableSet set];
    self.restroomPOIs = [NSMutableSet set];
}

@end


// ---------------------------------------------------------------------------------------------------------------------
//  LLAirportDatabaseDelegate
//
// - airportDatabase:airportList:
// - airportDatabase:airportLoaded:
//
// ---------------------------------------------------------------------------------------------------------------------
@implementation MainViewController(LLAirportDatabaseDelegate)

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
    self.search = [self.airport search];

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
    self.airport.delegate = self;
    self.search.delegate = self;

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
@implementation MainViewController(FloorDelegate)


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
    self.mapView.searchBarBackgroundColor = [UIColor lightGrayColor];
    self.mapView.navigationDisclaimer = @"Note: Navigation times are estimates and should not be considered guarrentied arrival time.";


    // add the mapView as a subview
    [self.view addSubview:mapView];

    // "constrain" the mapView to fill the entire screen
    [mapView setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSDictionary *views = NSDictionaryOfVariableBindings(mapView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[mapView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[mapView]|" options:0 metrics:nil views:views]];
}

@end


// ---------------------------------------------------------------------------------------------------------------------
// LLMapViewDelegate
//
// - mapViewReady:
//
// ---------------------------------------------------------------------------------------------------------------------
@implementation MainViewController(LLMapViewDelegate)

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

    // use the search engine find all of the restrooms and Starbucks
    [self.search search:@"restroom"];
    [self.search search:@"Starbucks"];
}

// ---------------------------------------------------------------------------------------------------------------------
// mapView:markerIconUrlForPOI:type:
//
// Used to override the default POI marker icons.
//
// For Starbucks, we will be using one icon for the selected icon and another for the unselected icon.
//
// For restrooms, we will be using the same icon for both.
//
// ---------------------------------------------------------------------------------------------------------------------
- (NSString *)mapView:(LLMapView *)mapView markerIconUrlForPOI:(NSString *)poiId type:(LLMapViewMarkerType)type
{
    NSString *iconUrl = nil;
    
    // Is this a Starbucks POI?
    if ([self.starbucksPOIs containsObject:poiId]) {
        // It is, so use the appropriate icon based on the marker type.
        switch (type) {
            case LLMapViewMarkerTypeSelected:
                iconUrl = [[NSBundle mainBundle] pathForResource:@"starbucks-selected.png" ofType:nil];
                break;
                
            case LLMapViewMarkerTypeUnselected:
                iconUrl = [[NSBundle mainBundle] pathForResource:@"starbucks-unselected.png" ofType:nil];
                break;
        }
    }
    
    // Is this a restroom POI?
    if ([self.restroomPOIs containsObject:poiId]) {
        // Always use restroom.png
        iconUrl = [[NSBundle mainBundle] pathForResource:@"restroom.png" ofType:nil];
    }
    
    return iconUrl;
}

// ---------------------------------------------------------------------------------------------------------------------
// mapView:markerIconUrlForPOI:type:
//
// Changes the anchor point of the marker.  For the restroom icon, the anchor point should be in the center.
//
// ---------------------------------------------------------------------------------------------------------------------
- (LLPoint *)mapView:(LLMapView *)mapView markerAnchorForPOI:(NSString *)poiId type:(LLMapViewMarkerType)type
{
    LLPoint *point = nil;
    
    // Is this a restroom POI?
    if ([self.restroomPOIs containsObject:poiId]) {
        // Set the anchor to the center of the image, which is 50x50.
        point = [[LLPoint alloc] initWithX:@(25) Y:@(25)];
    }
    
    return point;
}

@end


// ---------------------------------------------------------------------------------------------------------------------
//  LLSearchDelegate
//
// -- search:results connecting the dots.
//
// ---------------------------------------------------------------------------------------------------------------------
@implementation MainViewController(LLSearchDelegate)

// ---------------------------------------------------------------------------------------------------------------------
// search:results:
//
// Process the results of a search (initiated with LLSearch.search).
//
// ---------------------------------------------------------------------------------------------------------------------
- (void)search:(LLSearch *)search results:(LLSearchResults *)searchResults
{
    NSString *query = searchResults.query;
    
    // Add all of the Starbucks POI IDs to a set
    if ([query isEqualToString:@"Starbucks"]) {
        for (LLSearchResult *result in searchResults.results) {
            [self.starbucksPOIs addObject:result.poiId];
        }
    }
    
    // Add all of the Starbucks POI IDs to a set
    if ([query isEqualToString:@"restroom"]) {
        for (LLSearchResult *result in searchResults.results) {
            [self.restroomPOIs addObject:result.poiId];
        }
    }
}

@end
