//
//  LLAirports.h
//  LocusLabsSDK
//
//  Created by Samuel Ziegler on 6/12/14.
//  Copyright (c) 2014 LocusLabs. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LLAirport.h"
#import "LLJavaScriptObject.h"
#import "LLDownloader.h"

@class LLAirportDatabase;
@class LLJavaScriptFunction;
@class LLMap;
@class LLMapView;
@class LLMarker;

/**
 *  Delegates for LLAirportDatabase should implement this protocol.
 */
@protocol LLAirportDatabaseDelegate <NSObject>

@optional

/**
 *  Called with the data returned by the listAirports: method.
 *
 *  @param airportDatabase the database instance which generated the call
 *  @param airportList     an array of LLAirportInfo instances
 */
- (void)airportDatabase:(LLAirportDatabase *)airportDatabase airportList:(NSArray *)airportList;

/**
 *  Called when no airportList could be returned by listAirports
 *
 *  @param airportDatabase the database instance which generated the call
 *  @param reason the reason for the failure
 */
- (void)airportDatabase: (LLAirportDatabase *)airportDatabase airportListFailed: (NSString *)reason;

/**
 *  Called once an airport has been loaded via the loadAirport: method.
 *
 *  @param airportDatabase the database instance which generated the call
 *  @param airport         the airport
 */
- (void)airportDatabase:(LLAirportDatabase *)airportDatabase airportLoaded:(LLAirport *)airport;

/**
 *  Called once an airport begun downloading maps and other necessary assets.
 *
 *  @param airportDatabase the database instance which generated the call
 *  @param venueId         the venue id for the airport
 */
- (void)airportDatabase:(LLAirportDatabase *)airportDatabase airportLoadStarted:(NSString*)venueId;

/**
 *  Called once an airport has completed downloading maps and other necessary assets.
 *
 *  @param airportDatabase the database instance which generated the call
 *  @param venueId         the venue id for the airport
 */
- (void)airportDatabase:(LLAirportDatabase *)airportDatabase airportLoadCompleted:(NSString*)venueId;

/**
 *  Called during asset downloads to give a progress update.
 *
 *  @param airportDatabase the database instance which generated the call
 *  @param venueId         the venue id for the airport
 *  @param percent         the percent download complete
 */
- (void)airportDatabase:(LLAirportDatabase *)airportDatabase airportLoadStatus:(NSString*)venueId percentage:(int)percent;

/**
 *  Called if an error is encountered while downloading the airport maps.
 *
 *  @param airportDatabase the database instance which generated the call
 *  @param venueId         the venue id for the airport
 *  @param errorCode       the code for the failure
 *  @param message         the message for the failure
 */
- (void)airportDatabase:(LLAirportDatabase *)airportDatabase airportLoadFailed:(NSString*)venueId code:(LLDownloaderError)errorCode message:(NSString*)message;


@end

/**
 *  LLAirportDatabase is the primary entry point for all the LocusLabs airport functionality.  To recieve any of the asynchronously generated data generated by
 *  this class, you must assign a delegate that implements the methods of the LLAirportDatabaseDelegate protocol.
 */
@interface LLAirportDatabase : LLJavaScriptObject<LLDownloaderDelegate>

/**
 *  Delegate for this instance
 */
@property (weak, nonatomic) id<LLAirportDatabaseDelegate> delegate;

/**
 *  Create an instance of LLAirportDatabase
 *
 *  @return the new airport database object
 */
+ (LLAirportDatabase *)airportDatabase;

/**
 *  Create an instance of LLAirportDatabase for a specific MapView
 *
 *  @return the new airport database object
 */
+ (LLAirportDatabase *)airportDatabaseWithMapView:(LLMapView*)mapView;

/**
 *  Retrieve the list of airports available in the LocusLabs airport database.  The result will be returned via the
 *  airportDatabase:airportList: delegate method.
 */
- (void)listAirports;

- (void)listAirportsForLocale:(NSString*)locale;

/**
 *  Load a specific airport.  The result will be returned to the delegate via airportDatabase:airportLoaded:
 *  Only 4 concurrent loadAirports can be handled simultaneously.  Doing more than 4 could result in load failures.
 *
 *  @param venueId identifies the airport to load
 */
- (void)loadAirport:(NSString *)venueId;


/**
 * Has the map data for the specified venueId already been downloaded to the phone?
 *
 * Note: no information is returned about whether the version on the phone is the most up-to-date version
 */
- (bool) isVenueOnPhone:(NSString*)venueId;

typedef NS_ENUM(NSInteger, LLAirportDownloadConstraint) {
    LLAirportDownloadConstraintDownloadViaWifiOrPhone = 0,
    LLAirportDownloadConstraintDownloadOnlyViaWifi,
    LLAirportDownloadConstraintDisallowDownloading
};

@property (nonatomic, assign) LLAirportDownloadConstraint downloadConstraint;

typedef void (^AirportAndMapLoadedBlock) (LLAirport *airport, LLMap *map, LLFloor *floor, LLMarker *marker);

/**
 *  @param venueId identifies the airport to load
 *  @param initialSearch is a search string to zoom into as an initial position
 */
- (void)loadAirportAndMap:(NSString *)venueId initialSearch:(NSString *)initialSearch iconUrl:(NSString*)iconUrl
                    block:(AirportAndMapLoadedBlock)block;

/**
 *  @param venueId identifies the airport to load; zooms to venue's default center and radius
 */
- (void)loadAirportAndMap:(NSString *)venueId block:(AirportAndMapLoadedBlock)block;


// "private" in the sense that our customers shouldn't need to call this directly
- (void) teardown;

@end
