//
//  LLMapView.h
//  LocusLabsSDK
//
//  Created by Samuel Ziegler on 6/12/14.
//  Copyright (c) 2014 LocusLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LLMapViewDelegate.h"
#import "LLPosition.h"
#import "LLMapTips.h"
#import "LLSearch.h"

@class LLMap;
@class LLInternalMapView;
@class LLJavaScriptBridge;
@class LLFloorView;
@class LLPOI;
@class LLFlight;
@class LLPositionManager;
@class LLAirport;
@class LLTheme;

/**
 *  UIView for displaying LocusLabs floor maps.
 */
@interface LLMapView : UIView <LLSearchDelegate>


/**
 *  The map to render.
 */
@property (strong,nonatomic) LLMap *map;
@property (strong,nonatomic) LLJavaScriptBridge *javaScriptBridge;
@property (strong,nonatomic) LLInternalMapView *mapView;
@property (strong,nonatomic) UILabel *backLabel;

/**
 * Optional background image to display behind the search bar
 */
@property (strong,nonatomic) UIImage *searchBarBackgroundImage;

@property (nonatomic, getter=shouldShowAirportsNav) BOOL showAirportsNav;
@property (nonatomic, getter=shouldShowMyPositionNav) BOOL showMyPositionNav;

// Hide me!
@property (strong,nonatomic) LLPositionManager *positionManager;

/**
 *  A delegate object to receive map events.
 */
@property (weak,nonatomic) id<LLMapViewDelegate> delegate;

/**
 *  Set the visibile radius around the center point.
 */
@property (nonatomic, strong) NSNumber *mapRadius;

/**
 *  Set the center point of the map view.
 */
@property (nonatomic, strong) LLLatLng *mapCenter;

/**
 * Set the user's current departing flight
 */
@property (strong,nonatomic) LLFlight *departingFlight;

/**
 * Display information about specific flights
 */
@property (strong,nonatomic) NSArray *flights;

/**
 * Should the LocusLabs UI include 20 extra pixels at the top to appear behind the status bar? Default: NO
 */
@property (nonatomic) BOOL shouldAllowSpaceForStatusBar;

/**
 * A disclaimer to presented to the user before showing them the result of the navigation.
 */
@property (strong,nonatomic) NSString *navigationDisclaimer;
@property (atomic) BOOL showNavButton;

/**
 * Allows the back button on the Search Header to be removed.
 * This makes the search bar itself bigger.
 */
@property (nonatomic) BOOL showBackButton;

/**
 * Changes the POI window behavior to omit any missing information fields rather than printing "Unknown".
 * Deprecated. This value no longer affects anything and missing fields are always omitted.
 */
@property (nonatomic) BOOL hideMissingPOIInfo DEPRECATED_ATTRIBUTE;

/**
 * The airport associated with this map.
 */
@property (readonly,nonatomic) LLAirport *airport;

/**
 *  A LLMapView is created to render a map within the given frame.
 *
 *  @param frame the view frame
 *
 *  @return self
 */
- (id)initWithFrame:(CGRect)frame;

/**
 * Zoom to and display the header popup view for the given POI.  The
 * map will switch levels if necessary.
 * This function does nothing if a bad or non-existent POI is given.
 *
 * @param poiId The id of the POI to show.
 */
- (void)showPoiByPoiId:(NSString *)poiId;

/**
 * Zoom to and display the header popup view for the given POI.  The
 * map will switch levels if necessary.
  *
 * @param poi The POI object to show.
 */
- (void)showPoi:(LLPOI *)poi;

- (void)didTapMarker:(LLMarker *)marker;

- (void)didBeginDraggingMarker:(LLMarker *)marker;
- (void)didEndDraggingMarker:(LLMarker *)marker;
- (void)didDragMarker:(LLMarker *)marker;

- (LLFloorView*)getFloorViewForId:(NSString*)floorId;

- (void)mapViewReady;

- (void)levelSelected:(NSString*)levelName;
- (LLFloorView*)getFloorViewForCurrentLevel;
- (void)addUserPOI:(LLPOI*)poi userLabel:(NSString*)label;
- (void)removeUserPOI:(LLPOI*)poi;
- (BOOL)processTransform;
- (void)navigateFromStart:(LLPosition*)start end:(LLPosition*)end;
- (NSString*)getBuildingIdFromLatLng:(LLLatLng*)latLng;
- (NSString*)getFloorIdFromCLFloor:(NSNumber*)clFloor andLatLng:(LLLatLng*)latLng;
- (NSString*)getFloorIdFromMapFloorAndLatLng:(LLLatLng*)latLng;
- (void)showLatLngs:(NSArray*)latlngs;

/**
 * Programmatically open the navigation dialog passing in (optional) start and end positions
 */
-(void)openNavigationViewWithStart:(LLPosition*)navStart andEnd:(LLPosition*)navEnd;

/**
 * Programmatically cancel the user initiated navigation.
 */
- (void)cancelUserNavigation;

/**
 * Programmatically cancel user initiated search.
 */
- (void)cancelUserSearch;

- (void)initializeInternalMapView:(LLInternalMapView*)internalMapView;
- (void)initializeAirport:(LLAirport*)airport;

- (void)teardown;

- (NSArray*)fromLatLng:(LLLatLng*)latLng;
- (LLLatLng*)toLatLng:(NSArray*)utmXY;

/**
 * Set the background color of the entire search bar
 */
- (void)setSearchBarBackgroundColor:(UIColor*)backgroundColor;

/**
 * Set the color of the cancel button in the search bar
 */
- (void)setSearchBarCancelButtonColor:(UIColor*)cancelButtonColor;

/**
 * Change the back button's text
 */
- (void)setBackButtonText:(NSString*)backButtonText;

/**
 * Triggers the reload of places from the venue data, which in turn causes the LLMapViewDelegate willPresentPlaces method to be called again
 */
- (void)refreshPlaces;


/**
 * Get/set the color of the back button text.
 */
@property (nonatomic, strong) UIColor *backButtonTextColor;

- (void) runMemoryTests;

/**
 * Toggles the use of positioning to display the user's current position on the map.  Default is FALSE.
 */
@property (nonatomic) BOOL positioningEnabled;
@property (nonatomic) BOOL shouldShowClosestBeacon;

/**
 * Hide/show the search bar.  Default is NO.
 */
@property (nonatomic) BOOL searchBarHidden;

/**
 * Loading map state in search bar.  Default is YES.
 */
@property (nonatomic) BOOL isLoadingMap;

/**
 * Loading directions state in search bar.
 */
@property (nonatomic) BOOL isLoadingDirections;

/**
 * Directions would be loaded state in search bar.
 */
@property (nonatomic) BOOL willInitializeDirections;


/*
 * Hide/show the bottom bar.  Default is NO.
 */
@property (nonatomic) BOOL bottomBarHidden;

@property (retain,nonatomic) UINavigationController *mapTipsNavigationController;
@property (nonatomic) LLMapTipsPopupMethod mapTipsPopupMethod;

/**
 * Get or set the theme used by this LLMapView.
 */
@property (strong,nonatomic) LLTheme *theme;

@end
