//
//  MasterViewController.h
//  NavigationControllerExample
//
//  Created by Jeff Goldberg on 3/4/5.
//  Copyright (c) 205 LocusLabs. All rights reserved.
//

#import <LocusLabsSDK/LocusLabsSDK.h>

@interface MasterViewController : UITableViewController @end

@interface MasterViewController(AirportDatabaseDelegate) <LLAirportDatabaseDelegate> @end
