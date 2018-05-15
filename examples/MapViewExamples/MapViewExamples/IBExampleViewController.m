//
//  IBExampleViewController.m
//  MapViewExamples
//
//  Copyright © 2016 LocusLabs. All rights reserved.
//
//	README:
//	This example starts with storyboard representing the root view and a MapView already embedded via an IBOutlet.
//	There are constraints attached to the MapView defining its position and size, in the storyboard.
//		
//	At its most basic, the delegate of the MapLoader but implement the mapLoaderReady: and mapLoaderClosed:
//	methods. The former is called when the map is fully rendered and the latter is called when the user navigates
//	back with the button in the upper left corner of the MapView.

#import "IBExampleViewController.h"
#import <LocusLabsSDK/LocusLabsSDK.h>
#import "LocusLabsMapLoader.h"

@interface IBExampleViewController () <LocusLabsMapLoaderDelegate>

@property (nonatomic) IBOutlet LLMapView *mapView;
@property (nonatomic) LocusLabsMapLoader *mapLoader;

@end

@implementation IBExampleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.mapLoader = [[LocusLabsMapLoader alloc] initWithVenueId:@"lax" andMapView:self.mapView];
	self.mapLoader.delegate = self;
	[self.mapLoader loadMap];
}

- (void)mapLoaderReady:(LocusLabsMapLoader *)loader
{
	NSLog(@"Load complete");
}

- (void)mapLoaderClosed:(LocusLabsMapLoader *)loader
{
	
}

@end