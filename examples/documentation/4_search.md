# Search #

[readme](readme.md)

## Overview ##

Like navigation, the LocusLabs SDK will automatically allow the user to search for POI's using
the built-in UI. It is also possible to do your own custom searches by using the LocusLabs SDK 
as a search engine and then plotting the resulting points yourself.

## Organizing the code ##

Once again we need new delegates in order to listen for events sent by the LocusLabs SDK: 

- LLSearchDelegate
- LLPOIDatabaseDelegate

Here's the new header file:

    #import <LocusLabsSDK/LocusLabsSDK.h>

    @interface MainViewController : UIViewController @end

    @interface MainViewController(AirportDatabaseDelegate) <LLAirportDatabaseDelegate> @end
    @interface MainViewController(FloorDelegate)           <LLFloorDelegate>           @end
    @interface MainViewController(PositionManagerDelegate) <LLPositionManagerDelegate> @end
    @interface MainViewController(MapViewDelegate)         <LLMapViewDelegate>         @end
    @interface MainViewController(AirportDelegate)         <LLAirportDelegate>         @end
    @interface MainViewController(SearchDelegate)          <LLSearchDelegate>          @end
    @interface MainViewController(POIDatabaseDelegate)     <LLPOIDatabaseDelegate>     @end

## Set up for a search ##

To use the LocusLabs SDK as a search engine we call one of the methods on LLSearch:

- search:
- autocomplete:
- proximitySearch:lat:lng:
- proximitySearchWithTerms:floorId:lat:lng:
- searchWithTerms:

In this example we'll just use the vanilla 'search' method.

Because a search is always done on a specific airport, we don't create our own LLSearch object,
but instead retrieve the built-in instance from the airport. In addition to the LLSearch object, 
we will also be using an LLPOIDatabase. LLSearch returns POI ids and a minimal amount of data
for each POI, while LLPOIDatabase contains the bulk of the data for each POI.

Add these properties

    @property (strong, nonatomic) LLSearch *search;
    @property (strong, nonatomic) LLPOIDatabase *poiDatabase;

And then initialize them from the airport in airportDatabase:airportLoaded:

    - (void)airportDatabase:(LLAirportDatabase *)airportDatabase airportLoaded:(LLAirport *)airport
    {
        // Store the loaded airport
        self.airport = airport;
        self.search = [self.airport search];
        self.poiDatabase = [self.airport poiDatabase];

        ...

        self.search.delegate = self;
        self.poiDatabase.delegate = self; 
        self.search.delegate = self;
        self.poiDatabase.delegate = self; 

Make sure to set the delegates for self.search and self.poiDatabase.

## Search ##

To actually perform a search, we have to wait for the map to load, so add this line:

        [self.search search:@"gate:62"];

in mapViewReady:

    - (void)mapViewReady:(LLMapView *)mapView
    {
        // Pan/zoom the map
        self.mapView.mapCenter = [[LLLatLng alloc] initWithLat:@47.445117 lng:@-122.302117];
        self.mapView.mapRadius = @190.0;

        [self.search search:@"gate:62"];
    }

To handle the results, we need to implement the LLSearchDelegate protocol:

    @implementation MainViewController(LLSearchDelegate)

    - (void)search:(LLSearch *)search results:(LLSearchResults *)searchResults
    {
        // Put a red dot on the map for the found objects.
        for (LLSearchResult *searchResult in searchResults.results) {
            LLPosition *p = searchResult.position;
            [self createCircleCenteredAt:p.latLng onFloor:p.floorId withRadius:@10 andColor:[UIColor redColor]];
        }
    }

    @end

This code puts red LLCircle's at each POI returned. In this case, you should see a red circle at Gate 62.

## Collecting POI data ##

As another example, add a search for Starbucks:

        [self.search search:@"Starbucks"];

in mapViewReady:

    - (void)mapViewReady:(LLMapView *)mapView
    {
        // Pan/zoom the map
        self.mapView.mapCenter = [[LLLatLng alloc] initWithLat:@47.445117 lng:@-122.302117];
        self.mapView.mapRadius = @190.0;

        [self.search search:@"gate:62"];
        [self.search search:@"Starbucks"];
    }

and modify search:results to handle results for Starbucks:

in search:results:

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
            [self createCircleCenteredAt:p.latLng onFloor:p.floorId withRadius:@3 andColor:[UIColor redColor]];
        }
    }

The new code makes a call to the LLPOIDatabase to collect more information about any POI's
returned by the search. That means we have to implement LLPOIDatabaseDelegate:

    @implementation MainViewController(LLPOIDatabaseDelegate)

    - (void)poiDatabase:(LLPOIDatabase *)poiDatabase poiLoaded:(LLPOI *)poi
    {
        LLPosition *p = poi.position;
        LLCircle *circle = [self createCircleCenteredAt:p.latLng onFloor:p.floorId withRadius:@10 andColor:[UIColor whiteColor]];
        [circle setStrokeColor:[UIColor orangeColor]];
        [circle setStrokeWidth:3];
    }

    @end

Now when the map loads, in addition to showing a red circle at Gate 62, you should also see five white
circle with an orange stroke at Starbucks (you may have to zoom out a bit to see them.)

Obviously, in this example, though we used the LLPOIDatabase, we didn't actually make use of any of the
additional data provided by the LLPOI.
 
