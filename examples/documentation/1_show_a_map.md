# Show a LocusLabs map #

[readme](readme.md)

## Overview ##

This example shows how to place a fully-fuctional LocusLabs map in a full-size window.

Using this example, end-users will be able to use all of the LocusLabs functionality,
including panning, zooming, switching floors, searching, navigating and so on, but 
without any additional features.

The example shows a UIViewController (named MainViewController1):

- initializing the LocusLabs SDK
- selecting an airport 
- selecting a building in that airport
- selecting a floor in that building
- showing the map for that floor by adding a subview to the UIViewController's view

## Organizing the code ##

The LocusLabs SDK uses delegates to communicate messages back to the calling application.

In this case the MainViewController is:

- LLAirportDatabaseDelegate
- LLFloorDelegate

The code is organized in a slightly unusual way, which emphasizes the code related to each 
delegate by putting the code for that delegate into its own category. Here's the header:


    #import <LocusLabsSDK/LocusLabsSDK.h>

    @interface MainViewController : UIViewController @end

    @interface MainViewController(AirportDatabaseDelegate) <LLAirportDatabaseDelegate> @end
    @interface MainViewController(FloorDelegate)           <LLFloorDelegate>           @end

### Enabling Location Services ###

Though we won't use it in this example, your app will have to request Location Services
from the user. To do this you have to set a missing "Customer Target Property" that is now
required as part of iOS 8.  

To enable location services:

- Open up the Basic Example in Xcode
- Select the Project at the top left of the screen.
- Select "BasicExample" in the Targets section.
- Select the "Info" tab.
- Open up the "Custom iOS Target Properties"
- Highlight one of the properties and press the "+".
- Replace the Key with "NSLocationAlwaysUsageDescription"
- Replace the Value with "For navigation".

Now build and the App should prompt the user for permission to use Location Services.  
At this point, which allow the app to recognize beacons.



## Initializing and loading the list of airports ##

Whenever data may need to be downloaded to the device, the LocusLabs SDK works asynchronously.
Loading the list of airports the user is allowed to view is asynchronous.

In viewDidLoad, we initialize the SDK, initialize a LLAirportDatabase and then asynchronously 
request the list of airports.  By setting the airportDatabase's delegate to self, we guarantee
we'll receive the airportDatabase:airportList: message later.


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

## Loading an airport ##

Once the SDK returns a list of airports, we can load a specific airport--once again asynchronously. In this
case, we're arbitrarily loading the Los Angeles ("lax") airport. 


    - (void)airportDatabase:(LLAirportDatabase *)airportDatabase airportList:(NSArray *)airportList
    {
        [self.airportDatabase loadAirport:@"lax"];
    }


## Loading a floor ##

Once the SDK returns the airport, we can pick a building and floor and then asynchronously request the
map for that floor. We must set the floor's delegate in order to later be notified that the map has loaded.


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

        // Set all the delegates
        self.floor.delegate = self;

        // Load the map for the floor.  Map is sent via floor:mapLoaded:
        [self.floor loadMap];
    }

## Showing the map ##

Finally, when we receive the map, we can create an LLMapView and place it inside the view controller's view.
Make sure to specify the mapView's map property from the passed in map.


    - (void)floor:(LLFloor *)floor mapLoaded:(LLMap *)map
    {
        // Create and initialize a new LLMapView and set its map and delegate
        LLMapView *mapView = [[LLMapView alloc] init];
        self.mapView = mapView;
        mapView.map = map;

        // add the mapView as a subview
        [self.view addSubview:mapView];

        // "constrain" the mapView to fill the entire screen
        [mapView setTranslatesAutoresizingMaskIntoConstraints:NO];
        NSDictionary *views = NSDictionaryOfVariableBindings(mapView);
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[mapView]|" options:0 metrics:nil views:views]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[mapView]|" options:0 metrics:nil views:views]];
    }





