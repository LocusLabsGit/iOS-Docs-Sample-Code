//
//  ViewController.m
//  FlightCard
//
//  Copyright (c) 2016 LocusLabs. All rights reserved.
//

#import "ViewController.h"
#import "LocusLabsMapLoader.h"
#import <LocusLabsSDK/LocusLabsSDK.h>

@interface ViewController () <LocusLabMapLoaderDelegate>

@property (nonatomic, weak) IBOutlet UIView *navBarView;
@property (nonatomic, weak) IBOutlet UIView *mapPlacement;
@property (nonatomic, weak) IBOutlet UIButton *mapFullscreenButton;
@property (nonatomic, weak) IBOutlet UILabel *departingGateLabel;
@property (nonatomic) IBOutlet NSLayoutConstraint *mapFullscreenConstraint;
@property (nonatomic) IBOutlet NSLayoutConstraint *mapCompactConstraint;
@property (nonatomic) UIColor *navBarColor;

@property (nonatomic) LocusLabsMapLoader *mapLoader;

@end

@implementation ViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.navBarColor = self.navBarView.backgroundColor;
	[self setNeedsStatusBarAppearanceUpdate];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
    [self setupMap];    
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
	return UIStatusBarStyleLightContent;
}

- (void)setupMap
{
   	[self.view addConstraint:self.mapCompactConstraint];
 
	self.mapLoader = [[LocusLabsMapLoader alloc] initWithVenueId:@"sea" andSuperview:self.mapPlacement];
	self.mapLoader.delegate = self;
	[self.mapLoader loadMap];
}

- (IBAction)transitionToFullscreen
{
	[self.view removeConstraint:self.mapCompactConstraint];
	[self.view addConstraint:self.mapFullscreenConstraint];
	self.mapLoader.mapView.userInteractionEnabled = YES;
    self.mapLoader.mapView.shouldAllowSpaceForStatusBar = NO;
	self.mapFullscreenButton.hidden = YES;

    [UIView animateWithDuration:0.25 animations:^{
		[self.view layoutIfNeeded];
		self.navBarView.backgroundColor = [LLConfiguration sharedConfiguration].blueBackgroundColor;
		self.mapLoader.mapView.bottomBarHidden = NO;
		self.mapLoader.mapView.searchBarHidden = NO;

	} completion:^(BOOL finished) {
	}];
}

- (void)transitionToCompact
{
	[self.view removeConstraint:self.mapFullscreenConstraint];
	[self.view addConstraint:self.mapCompactConstraint];
	self.mapLoader.mapView.userInteractionEnabled = NO;
    self.mapLoader.mapView.shouldAllowSpaceForStatusBar = NO;

    [UIView animateWithDuration:0.25 animations:^{
		[self.view layoutIfNeeded];
		self.navBarView.backgroundColor = self.navBarColor;
		self.mapLoader.mapView.bottomBarHidden = YES;
		self.mapLoader.mapView.searchBarHidden = YES;
	} completion:^(BOOL finished) {
		self.mapFullscreenButton.hidden = NO;
		self.mapLoader.mapView.map.radius = @(50);
	}];
}

#pragma mark LocusLabMapLoaderDelegate

- (void)mapLoaderInitialized:(LocusLabsMapLoader *)loader
{
	[self.mapPlacement insertSubview:self.mapLoader.mapView atIndex:0];
	self.mapFullscreenButton.hidden = NO;
	self.mapLoader.mapView.bottomBarHidden = YES;
	self.mapLoader.mapView.searchBarHidden = YES;
}

- (void)mapLoaderReady:(LocusLabsMapLoader *)loader
{
	self.mapLoader.mapView.userInteractionEnabled = YES;
}

- (void)mapLoaderClosed:(LocusLabsMapLoader *)loader
{
	// Collapse map
	[self transitionToCompact];
}

- (NSString *)departingGateForMapLoader:(LocusLabsMapLoader *)loader
{
	return [@"gate:" stringByAppendingString:self.departingGateLabel.text];
}

- (void)mapLoader:(LocusLabsMapLoader *)loader isLoadingWithProgress:(float)progress
{
}

- (void)mapLoaderFinishedDownload:(LocusLabsMapLoader *)loader
{
}

- (void)mapLoader:(LocusLabsMapLoader *)loader failedWithError:(NSError *)error
{
	NSLog(@"Map Loader Error: %@", error);
}

@end