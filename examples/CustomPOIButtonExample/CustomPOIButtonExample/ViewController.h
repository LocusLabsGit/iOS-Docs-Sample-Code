//
//  ViewController.h
//  CustomPOIButtonExample
//
//  Copyright (c) 2015 LocusLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LocusLabsSDK/LocusLabsSDK.h>

@interface ViewController : UIViewController @end
@interface ViewController(AirportDatabaseDelegate) <LLAirportDatabaseDelegate> @end
@interface ViewController(FloorDelegate)           <LLFloorDelegate>           @end
@interface ViewController(MapViewDelegate)         <LLMapViewDelegate>         @end