//
//  LLSecurityWaitTimeMonitor.h
//  LocusLabsSDK
//
//  Created by Glenn Dierkes on 1/22/16.
//  Copyright © 2016 LocusLabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LLAirportDatabase.h"


@interface LLSecurityWaitTimeMonitor : NSObject


+(void)startMonitor;
//+(void)startMonitorFor:(NSString*)venueId;


@end

@interface LLSecurityWaitTimeMonitor(AirportDatabaseDelegate) <LLAirportDatabaseDelegate> @end
