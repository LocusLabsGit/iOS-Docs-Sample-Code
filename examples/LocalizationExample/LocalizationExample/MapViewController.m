//
//  MapViewController.m
//  LocalizationExample
//
//  Copyright © 2016 LocusLabs. All rights reserved.
//

#import "MapViewController.h"
#import <LocusLabsSDK/LocusLabsSDK.h>
#import "LocusLabsMapLoader.h"

@interface MapViewController () <LocusLabsMapLoaderDelegate>

@property (nonatomic) IBOutlet LLMapView *mapView;
@property (nonatomic) LocusLabsMapLoader *mapLoader;

@end

@implementation MapViewController

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
	[self.navigationController popViewControllerAnimated:YES];
}

@end