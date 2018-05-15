//
//  LLAirportInfo.h
//  LocusLabsSDK
//
//  Created by Samuel Ziegler on 6/12/14.
//  Copyright (c) 2014 LocusLabs. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  The basic information about an airport as returned by the LLAirportDatabase listAirports: method.
 */
@interface LLAirportInfo : NSObject

/**
 *  The airport's venue identifier.  This is used to create an instance of the LLAirport class via the LLAirportDatabase loadAirport: method.
 */
@property (retain,nonatomic) NSString *venueId;

/**
 *  The localized name of this airport.
 */
@property (retain,nonatomic) NSString *name;

/**
 *  The airport code
 */
@property (retain,nonatomic) NSString *airportCode;

/**
 *	The airport's locale identifier
 */
@property (nonatomic) NSString *locale;

@end
