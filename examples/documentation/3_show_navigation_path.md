# Show a custom navigation path #

[readme](readme.md)

## Overview ##

Although the LocusLabs SDK will automatically allow the user to navigate between two points using
the built-in UI, it is also possible to draw your own navigation path by using the LocusLabs SDK 
as a navigation engine and then plotting the resulting points yourself.

## Organizing the code ##

Once again we need new delegates in order to listen for events sent by the LocusLabs SDK: 

- LLAirportDelegate
- LLMapViewDelegate

Here's the new header file:

    #import <LocusLabsSDK/LocusLabsSDK.h>

    @interface MainViewController : UIViewController @end

    @interface MainViewController(AirportDatabaseDelegate) <LLAirportDatabaseDelegate> @end
    @interface MainViewController(FloorDelegate)           <LLFloorDelegate>           @end
    @interface MainViewController(PositionManagerDelegate) <LLPositionManagerDelegate> @end
    @interface MainViewController(MapViewDelegate)         <LLMapViewDelegate>         @end
    @interface MainViewController(AirportDelegate)         <LLAirportDelegate>         @end

## Request a navigation path ##

To use the LocusLabs SDK as a navigation engine, we call: airport navigateFrom:toDestinations:
but before we make that call we wait for the map to load. 

To know when the map has loaded, we need to implement LLMapViewDelegate and listen for mapViewReady.

In this case, we first pan and zoom to a convenient position by setting the mapView's mapCenter
and mapRadius values, which will indirectly cause the map to pan and zoom.

After that we create a dummy navigation request using two hard-coded lat/longs before calling
LLAirport.navigateFrom:toDestinations. 
    

    @implementation MainViewController(LLMapViewDelegate)

    - (void)mapViewReady:(LLMapView *)mapView
    {
        // Pan/zoom the map
        [self.mapView levelSelected:@"Departures"];
        self.mapView.mapCenter = [[LLLatLng alloc] initWithLat:@33.941384 lng:@-118.402057];
        self.mapView.mapRadius = @190.0;

        [self showSampleNavPath];
    }

    - (void)showSampleNavPath
    {
        // Show a Navigation
        LLLatLng *ll1 = [[LLLatLng alloc] initWithLat:@33.940846 lng:@-118.402024];
        LLLatLng *ll2 = [[LLLatLng alloc] initWithLat:@33.940925 lng:@-118.399614];

        LLPosition *p1 = [[LLPosition alloc] initWithFloor:self.floor latLng:ll1];
        LLPosition *p2 = [[LLPosition alloc] initWithFloor:self.floor latLng:ll2];

        p1.floorId =  @"lax-terminal_6-departures";
        p2.floorId =  @"lax-terminal_7-departures";

        [self.airport navigateFrom:p1 toDestinations:@[p1, p2]]; 
    }

    @end

## Be sure to set the delegate! ##

Be careful to set the mapView's delegate after creating it in floor:mapLoaded:

    - (void)floor:(LLFloor *)floor mapLoaded:(LLMap *)map
    {
        ...
        mapView.map = map;
        mapView.delegate = self;

        ...
    }

And the airport's delegate in, for instance, airportDatabase:airportLoaded, which is the first point
at which we have a bona fide airport:

    - (void)airportDatabase:(LLAirportDatabase *)airportDatabase airportLoaded:(LLAirport *)airport
    {
        ...

        self.floor.delegate = self;
        self.airport.delegate = self;

        ...
    }


## Draw the navigation path ##

Finally, we need to do something with the navigation path once it is returned to us. This we
do in LLAirportDelegate.navigationPath:from:toDestinations:

    @implementation MainViewController(LLAirportDelegate)


    - (void)airport:(LLAirport *)airport navigationPath:(LLNavigationPath *)navigationPath from:(LLPosition *)startPosition toDestinations:(NSArray *)destinations
    {
        // Create a LLPolyline from the waypoints and render it on the mapView
        [self createPolylineFromWaypoints:navigationPath.waypoints startingOnFloor:startPosition.floorId];
    }

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

    - (LLCircle*) createCircleCenteredAt:(LLLatLng*)latLng onFloor:(NSString*)floorId withRadius:(NSNumber*)radius andColor:(UIColor*)color {

        LLCircle *circle = [LLCircle circleWithCenter:latLng radius:radius];
        [circle setFillColor:color];
        circle.floorView = [self.mapView getFloorViewForId:floorId];
        return circle;
    }

    @end


In this code, we are receiving the navigationPath returned by the navigation engine in navigationPath:from:toDestinations:

A NavigationPath consists of an array of LLWaypoint's which are points (essentially lat/long + floor) along the path. 
We use the waypoints to create an LLPath, which is an array of lat/longs, and from the LLPath, we create a "polyline" 
that will appear on the map. A polyline is an overlay made up of a connected series of straight lines between lat/longs. 
In createPolylineFromWaypoints:startingOnFloor: we use the lat/long and floor from the waypoints as the lat/longs for the polyline.

In addition, if the waypoint is a "destination" we add a black circle:

            // Add a black circle at the destination
            if ([waypoint.isDestination boolValue]) {
                [self createCircleCenteredAt:waypoint.latLng onFloor:waypoint.floorId withRadius:@5 andColor:[UIColor blackColor]];
            }

An LLCircle is a overlay with a lat/long, a floor, a radius (in meters), a stroke color and a fill color. Setting the 
floorView of an LLCircle causes the map to draw the circle when the appropriate part of the map is in view.  Likewise, 
setting the floorView of an LLPolyline causes the map to draw the line connecting the dots.










