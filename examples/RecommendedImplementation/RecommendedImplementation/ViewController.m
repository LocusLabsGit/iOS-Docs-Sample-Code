//
//  ViewController.m
//  RecommendedImplementation
//
//  Copyright (c) 2015 LocusLabs. All rights reserved.
//

#import "ViewController.h"
#import "LocusLabsMapLoader.h"
#import <LocusLabsSDK/LocusLabsSDK.h>

#import "LocusLabsMapPack.h"

@interface ViewController () <LocusLabMapLoaderDelegate>

@property (nonatomic, weak) IBOutlet UIView *navBarView;
@property (nonatomic, weak) IBOutlet UIView *mapPlacement;
@property (nonatomic, weak) IBOutlet UIButton *mapFullscreenButton;
@property (nonatomic) IBOutlet NSLayoutConstraint *mapFullscreenConstraint;
@property (nonatomic) IBOutlet NSLayoutConstraint *mapCompactConstraint;
@property (nonatomic) UIColor *navBarColor;


@property (nonatomic, weak) IBOutlet UILabel *arrivingGateLabel;
@property (nonatomic, weak) IBOutlet UILabel *departingGateLabel;

@property (nonatomic, weak) IBOutlet UIButton *arrivingGateButton;
@property (nonatomic, weak) IBOutlet UIButton *departingGateButton;


@property (nonatomic) LocusLabsMapLoader *mapLoader;

@end

@implementation ViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.navBarColor = self.navBarView.backgroundColor;
	[self setNeedsStatusBarAppearanceUpdate];
	// Install the map pack we are shipping with this app.  Map Packs are optional.  They allow you to ship a snapshot of your maps so that your users have them available to them even if they don't have a network connection when they first run the app.  Contact support@locuslabs.com to get a map pack for your account.
	[LocusLabsMapPack mapPackInstallWithCompletionBlock:^void (BOOL didInstall, NSError *err) {
		if (err) {
			NSLog(@"An error occurred while installing the map pack: %@",err);
		} else {
			if (didInstall) {
				NSLog(@"The map pack was installed.");
			} else {
				NSLog(@"The installed maps are up to date, no need to install the map pack.");
			}
		}
		
		[self setupMap];
	}];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
	return UIStatusBarStyleLightContent;
}

- (void)setupMap
{
   	[self.view addConstraint:self.mapCompactConstraint];
 
	self.mapLoader = [[LocusLabsMapLoader alloc] initWithSuperview:self.mapPlacement];
	self.mapLoader.delegate = self;
    [self.mapLoader loadMap:@"sea" showGate:[@"gate:" stringByAppendingString:self.departingGateLabel.text]];
}

- (IBAction)transitionToFullscreen
{
	[self.view removeConstraint:self.mapCompactConstraint];
	[self.view addConstraint:self.mapFullscreenConstraint];
	self.mapLoader.mapView.userInteractionEnabled = YES;
    self.mapLoader.mapView.shouldAllowSpaceForStatusBar = YES;
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
    self.mapLoader.mapView.shouldAllowSpaceForStatusBar = NO;
	self.mapLoader.mapView.userInteractionEnabled = NO;

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

- (IBAction)arrivingGate
{
    [self.mapLoader loadMap:@"lax" showGate:[@"gate:" stringByAppendingString:self.arrivingGateLabel.text]];
}

- (IBAction)departingGate
{
    [self.mapLoader loadMap:@"sea" showGate:[@"gate:" stringByAppendingString:self.departingGateLabel.text]];
}

#pragma mark LocusLabMapLoaderDelegate

- (void)mapLoaderInitialized:(LocusLabsMapLoader *)loader
{
    [self.mapPlacement insertSubview:self.mapLoader.mapView atIndex:0];
    self.mapFullscreenButton.hidden = NO;
    self.mapLoader.mapView.bottomBarHidden = YES;
    self.mapLoader.mapView.searchBarHidden = YES;
    [self.mapLoader.mapView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    self.mapLoader.mapView.shouldAllowSpaceForStatusBar = NO;
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
