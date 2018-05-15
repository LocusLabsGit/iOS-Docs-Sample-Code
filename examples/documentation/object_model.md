# Overview of Classes in the LocusLabs iOS SDK#

[readme](readme.md)

## Object Model ##

### Main Objects ###

The LocusLabs API has these main model objects:

name             | description                                                                 | has
---------------- | --------------------------------------------------------------------------- | ---------
AirportDatabasee | Information about all airports the user can access                          | Airports
Airport          | Information related to a specfic airport (aka "<b>venue</b>")               | Buildings
Building         | Information related to an airport building                                  | Floors
Floor            | Information related to a floor of an airport building                       | POI's
POI              | Any "Point of Interest" (eg. gate 12, Starbucks, a restroom)                | Floor
POI Database     | Information about all POI's the user can access                             | POI's
PositionManager  | Tracks and reports changes in the user's current position                   |
Location         | Superclass of Airport, Building, Floor etc. with meta data for the location |
Position         | Georgraphic information including lat/long, floor, name, etc.               |
LatLng           | Latitude/longitude                                                          |
Point            | x, y location on a map                                                      |

### Info Objects ##


These items provide stub information before the related entity is loaded: 


name                           | description
------------------------------ | -------------------------------------------------
AirportInfo                    | Name, venueId, and airportCode for an Airport
BuildingInfo                   | Name and buildingId for a building
FloorInfo                      | Name, number, description and floorId for a Floor


### Search and Navigation #### 


These objects are related to searching and navigation. Searching identifies POI's that match
user-specified criteria; navigation identifies the shortest route between two or more POI's.


name              | description
----------------- | --------------------------------------------------------------------------------
Search            | The POI search engine, accessed using the airport:search: method
SearchResult      | Information about an individual POI found during a search
SearchResults     | A collection of SearchResult's
SearchCategory    | ?
NavigationPath    | A collection of waypoints between two or more POI's
Waypoint          | Information about a location along NavigationPath (latLng, distance, type, etc.)


## Delegates ## 

The LocusLabs SDK uses delegates to communicate messages back to the calling application.


name                    | related events
----------------------- | ---------------------------------------------------------------
AirportDatabaseDelegate | available airportList, airportLoaded, etc.
AirportDelegate         | available buildingList, buildingLoaded, navigationPathFor, etc.
FloorDelegate           | available beaconList, mapLoaded
MapViewDelegate         | didTapMarker, didTapLatLng, didTapPOI
POIDatabaseDelegate     | poiLoaded
PositionManagerDelegate | user positionChanged, user positioningAvailable
SearchDelegate          | available searchResults, etc.




## UI Objects ##

The LocusLabs API uses these UI objects


name      | description
--------- | ----------------------------------------------------------------------------------------------
MapView   | A UIView subclass that shows the map of a selected floor plus any Overlays on the map
Overlay   | Anything drawn on a MapView other than the actual map itself
Marker    | An Overlay that shows an icon on a floor at a given lat/long
Circle    | An Overlay that shows a circle on a floor at a given lat/long
Polycurve | An Overlay that shows a series of connected curves and optionally icons along its path
Polyline  | An Overlay that shows a series of connected straight lines and optionally icons along its path
NavLine   | An Overlay that animates a (curved) navigation path
NavCurve  | An Overlay that animates a (straight) navigation path




