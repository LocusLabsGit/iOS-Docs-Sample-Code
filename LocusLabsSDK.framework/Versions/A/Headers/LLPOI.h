//
//  LLPOI.h
//  LocusLabsSDK
//
//  Created by Samuel Ziegler on 7/24/14.
//  Copyright (c) 2014 LocusLabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LLPOIDataProtocol.h"

@class LLPosition;
@class LLFlight;

/**
 *  All of the available information about a POI.
 */
@interface LLPOI : NSObject <LLPOIData> {
}

/**
 *  The geographic position of the POI.
 */
@property (strong,nonatomic) LLPosition *position;

/**
 *  The URL associated with this POI.  For example, this may be a company website if the POI is a store.
 */
@property (strong,nonatomic) NSString *url;

/**
 *  The visible value to display for the URL property. This could be the domain name or a proper name. Absence of this property will display the URL as "Web Site".
 */
@property (strong,nonatomic) NSString *urlDisplay;

/**
 *	Additional attributes for the POI.
 */
@property (nonatomic,readonly) NSDictionary *additionalAttributes;

/**
 *  An icon for the POI.
 */
@property (strong,nonatomic) NSString *icon;

/**
 *  Absolute URL of icon
 */
@property (nonatomic,readonly) NSURL *iconUrl;

/**
 *  An image of the POI.
 */
@property (strong,nonatomic) NSString *image;

/**
 *  Additional images of the POI.
 */
@property (strong,nonatomic) NSArray *additionalImages;

/**
 *  Absolute URL of image
 */
@property (nonatomic,readonly) NSURL *imageUrl;

/**
 *	Absolute URLs for all additional images
 */
@property (nonatomic,readonly) NSArray *additionalImageUrls;

/**
 *  An array of NSStrings which are used to classify this POI.
 */
@property (strong,nonatomic) NSArray *tags;

/**
 *  Subset og the tags meant for display.
 */
@property (strong,nonatomic) NSArray *displayTags;

/**
 *  A localized string identifying this POI which can be used for display purposes.
 */
@property (strong,nonatomic) NSString *name;

/**
 *  The category that this POI is apart of.
 */
@property (strong,nonatomic) NSString *category;

/**
 *  A localized description of this POI.
 */
@property (strong,nonatomic) NSString *poiDescription;
@property (assign,nonatomic) BOOL hasDescription;

/**
 *  A phone number for this POI, if applicable.
 */
@property (strong,nonatomic) NSString *phone;

/**
 *  The unique identifier of this POI.
 */
@property (strong,nonatomic) NSString *poiId;

/**
 *  The nearest gate to this POI, if applicable.
 */
@property (strong,nonatomic) NSString *gate;

/**
 *  The operating hours of this POI, if applicable.
 */
@property (strong,nonatomic) NSString *hours;

/**
 *  The operating airport of this POI, if applicable.
 */
@property (strong,nonatomic) NSString *airport;

/**
 *  Radius
 */
@property (strong,nonatomic) NSNumber *radius;

/**
 *  Logo
 */
@property (strong,nonatomic) NSString *logo;

/**
 *  Absolute URL of the logo
 */
@property (nonatomic,readonly) NSURL *logoUrl;

/**
 *  The operating terminal of this POI, if applicable.
 */
@property (strong,nonatomic) NSString *terminal;

/**
 *  An arbitrary userLabel set in LLMapView.addUserPOI
 */
@property (strong,nonatomic) NSString *userLabel;

@property (strong,nonatomic) LLFlight *flight;

/**
 *  Properties used for POI display
 */
@property (strong,nonatomic) NSDictionary *displayProperties;

/**
 An array of NSDictionary objects each of which has a 'days' and 'hours' field that indicates the
 operating hours of the POI for a part of the week
*/
@property (strong,nonatomic) NSArray *operatingHours DEPRECATED_ATTRIBUTE;

/**
 An array of 7 arrays (one for each week day) containing LLOperatingHours objects.
 A POI can be open for a variable number of blocks throughout a day, or none at all if it is closed.
 */
@property (readonly, nonatomic) NSArray *detailedOperatingHours;

/**
 Easy-to-check flag for whether or not this POI has a list of operating hours
 */
@property (readonly, nonatomic) BOOL hasOperatingHours;

/**
 * Indicates if the POI has any navigation directions.
 * If nil then the POI can be navigated to/from.
 * Otherwise if non-nil and true then the POI can NOT be navigated/from.
 */
@property (readonly, nonatomic) NSNumber *noDirections;


- (BOOL)isEqual:(id)object;


@property (nonatomic, readonly) NSUInteger hash;

@end
