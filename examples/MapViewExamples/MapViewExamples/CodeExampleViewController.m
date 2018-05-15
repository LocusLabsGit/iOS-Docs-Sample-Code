//
//  ViewController.m
//  MapViewExamples
//
//	Copyright © 2016 LocusLabs. All rights reserved.
//
//	README:
//	This example starts with only a blank storyboard representing the root view and instantiates
//	the MapView as a child view.
//	
//	By default, the LocusLabsMapLoader frames the MapView with the same dimensions of the superview.
//
//	At its most basic, the delegate of the MapLoader but implement the mapLoaderReady: and mapLoaderClosed:
//	methods. The former is called when the map is fully rendered and the latter is called when the user navigates
//	back with the button in the upper left corner of the MapView.

#import "CodeExampleViewController.h"
#import <LocusLabsSDK/LocusLabsSDK.h>
#import "LocusLabsMapLoader.h"

@interface CodeExampleViewController () <LocusLabsMapLoaderDelegate>

@property (nonatomic) LocusLabsMapLoader *mapLoader;

@end

@implementation CodeExampleViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.mapLoader = [[LocusLabsMapLoader alloc] initWithVenueId:@"lax" andSuperview:self.view];
	self.mapLoader.delegate = self;
	[self.mapLoader loadMap];
}

- (void)mapLoaderReady:(LocusLabsMapLoader *)loader
{
	[self.view addSubview:loader.mapView];
}

- (void)mapLoaderClosed:(LocusLabsMapLoader *)loader
{
	[loader.mapView removeFromSuperview];
}

@end