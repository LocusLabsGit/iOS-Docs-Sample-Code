//
//  DetailViewController.h
//  NavigationControllerExample
//
//  Created by Jeff Goldberg on 3/4/15.
//  Copyright (c) 2015 LocusLabs. All rights reserved.
//

#import <LocusLabsSDK/LocusLabsSDK.h>

@interface DetailViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end

@interface DetailViewController(FloorDelegate)           <LLFloorDelegate>           @end
@interface DetailViewController(AirportDatabaseDelegate) <LLAirportDatabaseDelegate> @end
@interface DetailViewController(MapViewDelegate)         <LLMapViewDelegate>         @end



