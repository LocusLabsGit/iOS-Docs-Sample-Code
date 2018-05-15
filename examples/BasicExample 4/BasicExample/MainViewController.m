#import "MainViewController.h"

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
@property (strong, nonatomic) LLPositionManager *positionManager;
@property (strong, nonatomic) LLNavPoint *navPoint;
@property (strong, nonatomic) LLSearch *search;
@property (strong, nonatomic) LLPOIDatabase *poiDatabase;
@property (strong, nonatomic) LLPosition *startPosition;
@property (strong, nonatomic) LLPosition *endPosition;

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
    self.poiDatabase = [self.airport poiDatabase];

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
    self.poiDatabase.delegate = self;

    // Load the map for the floor.  Map is sent via floor:mapLoaded:
    [self.floor loadMap];

    // start tracking the user's position
    [self startTrackingUserPosition];
}

// ---------------------------------------------------------------------------------------------------------------------
// startTrackingUserPosition
//
// Create a positionManager and listen to it (via a delegate); turn on "passive" positioning (which will later
// turn on "active" positioning if the user comes within the range of some beacons)
// ---------------------------------------------------------------------------------------------------------------------
- (void) startTrackingUserPosition {
    self.positionManager = [[LLPositionManager alloc] initWithAirports:@[self.airport]];
    self.positionManager.delegate = self;
    self.positionManager.passivePositioning = TRUE;
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
//  LLPositionManagerDelegate
//
// - positionManager:positionChanged:
// - positionManager:positioningAvailable:
//
// ---------------------------------------------------------------------------------------------------------------------
@implementation MainViewController(LLPositionManagerDelegate)

// ---------------------------------------------------------------------------------------------------------------------
// positionManager:positioningAvailable:
//
// Sent whenever the positionManager's ability to track the user's position changes
// ---------------------------------------------------------------------------------------------------------------------
- (void)positionManager:(LLPositionManager *)positionManager positioningAvailable:(BOOL)positioningAvailable
{
    if (positioningAvailable) {
        NSLog(@"Positioning is now available");
    } else {
        NSLog(@"Positioning is now unavailable");
    }
}

// ---------------------------------------------------------------------------------------------------------------------
// positionManager:positionChanged:
//
// Sent whenever the positionManager detects that the user has moved to a new position--or the user's position
// cannot be determined.
//
// Note: the positionManager doesn't work in the simulator, and will only find a position
// if you happen to actually be in an airport near iBeacons.
// ---------------------------------------------------------------------------------------------------------------------
- (void)positionManager:(LLPositionManager *)positionManager positionChanged:(LLPosition *)position
{
    // the positionManager is unable to locate the user--probably because the user is not
    // near enough to any iBeacon
    if (!position) {
        return;
    }

    // Initialize a LLNavPoint--a blue, pulsating circle on the mapView--that will track the user's position
    if (!self.navPoint) {
        self.navPoint = [[LLNavPoint alloc] init];
        self.navPoint.floorView = [self.mapView getFloorViewForId:position.floorId];
    }

    // Set the navPoint's position
    self.navPoint.position = position.latLng;

    // If we're now near an airport, start active positioning
    if (position.nearAirport) {
        self.positionManager.activePositioning = TRUE;
    }

    // If we're near a venue, show it
    if (position.venueId) {
        NSLog(@"VenueId: %@",position.venueId);
    }
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

    // use the search engine to look for gate 62 and Starbucks
    [self.search search:@"gate:62"];
    [self.search search:@"Starbucks"];
}

// ---------------------------------------------------------------------------------------------------------------------
// create a navigation path from two sample positions at LAX
// ---------------------------------------------------------------------------------------------------------------------
- (void)showSampleNavPath
{
    if (!self.startPosition || !self.endPosition) {
        return;
    }

    [self.airport navigateFrom:self.startPosition to:self.endPosition];
}
@end



// ---------------------------------------------------------------------------------------------------------------------
//  LLAirportDelegate
//
//   - airport:navigationPath:from:toDestinations:
//
// ---------------------------------------------------------------------------------------------------------------------
@implementation MainViewController(LLAirportDelegate)


// ---------------------------------------------------------------------------------------------------------------------
// airport:navigationPath:from:toDestinations:
// ---------------------------------------------------------------------------------------------------------------------
- (void)airport:(LLAirport *)airport navigationPath:(LLNavigationPath *)navigationPath from:(LLPosition *)startPosition toDestinations:(NSArray *)destinations
{
    // Create a LLPolyline from the waypoints and render it on the mapView
    [self createPolylineFromWaypoints:navigationPath.waypoints startingOnFloor:startPosition.floorId];
}

// ---------------------------------------------------------------------------------------------------------------------
// createPolylineFromWaypoints:
//
// Create a "polyline" we can place on a mapView from the passed in LLWaypoint's
// Each LLWaypoint knows its own latLng and floor
// ---------------------------------------------------------------------------------------------------------------------
- (void) createPolylineFromWaypoints:(NSArray*)waypoints startingOnFloor:(NSString*)floorId {

    LLMutablePath *path = [[LLMutablePath alloc] init];
    for (LLWaypoint *waypoint in waypoints) {

        // Add this latLng to the LLPath.
        [path addLatLng:waypoint.latLng];

        // Add a black circle at the destination
        if ([waypoint.isDestination boolValue]) {
            [self createCircleCenteredAt:waypoint.latLng onFloor:waypoint.floorId withRadius:@5 andColor:[UIColor blackColor]];
        }
    }

    // Create a new LLPolyline object and set its path
    LLPolyline *polyline = [[LLPolyline alloc] init];
    [polyline setPath:path];
    polyline.floorView = [self.mapView getFloorViewForId:floorId];
}

// ---------------------------------------------------------------------------------------------------------------------
// createCircleCenteredAt:withRadius:andColor:
// return a new LLCircle we can place on a mapView
// ---------------------------------------------------------------------------------------------------------------------
- (LLCircle*) createCircleCenteredAt:(LLLatLng*)latLng onFloor:(NSString*)floorId withRadius:(NSNumber*)radius andColor:(UIColor*)color {

    LLCircle *circle = [LLCircle circleWithCenter:latLng radius:radius];
    [circle setFillColor:color];
    circle.floorView = [self.mapView getFloorViewForId:floorId];
    return circle;
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
// Process the results of a search (initiated with LLSearch.search). As examples, here, we
//
// - load more information for the POI if the query was for "Starbucks" OR
// - place a red dot on each of the searchReults
// ---------------------------------------------------------------------------------------------------------------------
- (void)search:(LLSearch *)search results:(LLSearchResults *)searchResults
{
    NSString *query = searchResults.query;

    // Get more information about the Starbucks locations from the POI database.
    if ([query isEqualToString:@"Starbucks"]) {
        for (LLSearchResult *searchResult in searchResults.results) {
            if (!self.startPosition) {
                // Use the first Starbucks we find as the start position of navigation
                self.startPosition = searchResult.position;
                [self showSampleNavPath];
            }
            [self.poiDatabase loadPOI:searchResult.poiId];
        }
        return;
    }

    // Put a red dot on the map for the found objects.
    for (LLSearchResult *searchResult in searchResults.results) {
        if (!self.endPosition) {
            self.endPosition = searchResult.position;
            [self showSampleNavPath];
        }
        LLPosition *p = searchResult.position;
        [self createCircleCenteredAt:p.latLng onFloor:p.floorId withRadius:@10 andColor:[UIColor redColor]];
    }
}

@end




// ---------------------------------------------------------------------------------------------------------------------
//  LLPOIDatabaseDelegate
//
// - poiDatabase:poiLoaded:
// ---------------------------------------------------------------------------------------------------------------------
@implementation MainViewController(LLPOIDatabaseDelegate)

// ---------------------------------------------------------------------------------------------------------------------
// poiDatabase:poiLoaded:
//
// Callback for LLPoiDatabase.loadPoi returning data for the POI. Here use the position of the POI to place a circle
// ---------------------------------------------------------------------------------------------------------------------
- (void)poiDatabase:(LLPOIDatabase *)poiDatabase poiLoaded:(LLPOI *)poi
{
    LLPosition *p = poi.position;
    LLCircle *circle = [self createCircleCenteredAt:p.latLng onFloor:p.floorId withRadius:@10 andColor:[UIColor whiteColor]];
    [circle setStrokeColor:[UIColor orangeColor]];
    [circle setStrokeWidth:3];
}

@end

