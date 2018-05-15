# Track the user's position #

[readme](readme.md)

The LocusLabs SDK uses iBeacon technology to be able to locate a user's phone. LLPositionManager 
manages the user's position and calls its delegate whenever the user's position has changed--or the
signal from the beacons has been lost. 

In addition, LLPositionManager operates in two modes--passive and active. "Active" mode is more
effective at recognizing position changes, but also more power hungry, so it should only be
turned on when the phone is within range of beacons.

## Organizing the Code ##

We need to add another delegate to our MainViewController for the LLPositionManager to notify;
notice the new (last) line in the header file:

    #import <LocusLabsSDK/LocusLabsSDK.h>

    @interface MainViewController : UIViewController @end

    @interface MainViewController(AirportDatabaseDelegate) <LLAirportDatabaseDelegate> @end
    @interface MainViewController(FloorDelegate)           <LLFloorDelegate>           @end
    @interface MainViewController(PositionManagerDelegate) <LLPositionManagerDelegate> @end

In MainViewController.m, we also need a new property for our position manager, and another
for the "navPoint" which we'll come back to:

    @property (strong, nonatomic) LLPositionManager *positionManager;
    @property (strong, nonatomic) LLNavPoint *navPoint;

## Initializing the Position Manager ##

Since the Position Manager depends on beacon data for a specific airport, we can't initialize our
positionManager until we have loaded the airport. Add a call to startTrackingUserPosition at the 
bottom of airportDatabase:airportLoaded: to initialize the positionManager in "passive" mode:


    - (void)airportDatabase:(LLAirportDatabase *)airportDatabase airportLoaded:(LLAirport *)airport
    {
        ...

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

## Adding the Delegate Methods ##

Now we have to implement the delegate methods the positionManager will call. These are:

- positionManager:positioningAvailable:
- positionManager:positionChanged:

### positioningAvailable ###

positionManager:positioningAvailable: indicates that positioning will actuallly take place (which might fail, if, for 
instance, the user doesn't have their bluetooth turned on). Here we just log what happened:


    - (void)positionManager:(LLPositionManager *)positionManager positioningAvailable:(BOOL)positioningAvailable
    {
        if (positioningAvailable) {
            NSLog(@"Positioning is now available");
        } else {
            NSLog(@"Positioning is now unavailable");
        }
    }

### positionChanged ###

positionManager:positionChanged: is called whenever the user's position changes. If the position can no longer
be determined (if, for instance, the user leaves the airport) the reported position will be nil.

In this example, we use an LLNavPoint to track the position of the user. LLNavPoint is an Overlay that shows
on the map as a pulsing blue dot; changing its position will cause it to animate from the old position to the new.

In addition, we're turning on activePositioning if we're near the airport and showing the "venue" (aka airport) id.


    - (void)positionManager:(LLPositionManager *)positionManager positionChanged:(LLPosition *)position
    {
        // can't find the user
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



