//
//  MainViewController.h
//  BasicExample
//
//  Created by Samuel Ziegler on 6/26/14.
//  Copyright (c) 2014 LocusLabs. All rights reserved.
//

#import <LocusLabsSDK/LocusLabsSDK.h>

@interface MainViewController : UIViewController @end

@interface MainViewController(AirportDatabaseDelegate) <LLAirportDatabaseDelegate> @end
@interface MainViewController(FloorDelegate)           <LLFloorDelegate>           @end
@interface MainViewController(PositionManagerDelegate) <LLPositionManagerDelegate> @end

