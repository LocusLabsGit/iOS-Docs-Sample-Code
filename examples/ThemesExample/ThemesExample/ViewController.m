//
//  ViewController.m
//  ThemesExample
//
//  Created by Sam Ziegler on 7/19/16.
//  Copyright © 2016 LocusLabs. All rights reserved.
//

#import "ViewController.h"

#import <LocusLabsSDK/LocusLabsSDK.h>

@interface ViewController () <UITableViewDelegate,UITableViewDataSource,LLMapViewDelegate,LLAirportDatabaseDelegate>

@property (strong,nonatomic) NSMutableArray *themes;
@property (strong,nonatomic) NSMutableArray *themeNames;
@property (strong,nonatomic) LLAirportDatabase *airportDatabase;
@property (strong,nonatomic) IBOutlet UITableView *tableView;
@property (strong,nonatomic) IBOutlet LLMapView *mapView;

@end

@implementation ViewController

// Create a theme which just changes the base font
- (LLTheme *)changeBaseFontTheme
{
    LLThemeBuilder *themeBuilder = [LLThemeBuilder themeBuilderWithTheme:[LLTheme defaultTheme]];
    [themeBuilder setProperty:@"fonts.normal" value:[UIFont fontWithName:@"American Typewriter" size:12.0]];
    return themeBuilder.theme;
}

// Change the background color to yellow
- (LLTheme *)yellowBackgroundTheme
{
    LLThemeBuilder *themeBuilder = [LLThemeBuilder themeBuilderWithTheme:[LLTheme defaultTheme]];
    [themeBuilder setProperty:@"colors.background" value:[UIColor yellowColor]];
    return themeBuilder.theme;
}

// Ugly theme
- (LLTheme *)uglyTheme
{
    LLThemeBuilder *themeBuilder = [LLThemeBuilder themeBuilderWithTheme:[LLTheme defaultTheme]];
    [themeBuilder setProperty:@"fonts.normal" value:[UIFont fontWithName:@"Papyrus" size:12.0]];
    [themeBuilder setProperty:@"colors.background" value:[UIColor yellowColor]];
    [themeBuilder setProperty:@"colors.lightGrayBackground" value:[UIColor brownColor]];
    [themeBuilder setProperty:@"colors.text" value:[UIColor blueColor]];
    [themeBuilder setProperty:@"colors.iconTint" value:[UIColor blueColor]];
    [themeBuilder setProperty:@"colors.lightText" value:[UIColor purpleColor]];
    [themeBuilder setProperty:@"colors.veryLightText" value:[UIColor cyanColor]];
    [themeBuilder setProperty:@"colors.lightIconTint" value:[UIColor purpleColor]];
    [themeBuilder setProperty:@"colors.veryLightIconTint" value:[UIColor cyanColor]];
    [themeBuilder setProperty:@"colors.translucentBackground" value:[[UIColor yellowColor] colorWithAlphaComponent:0.6]];
    [themeBuilder setProperty:@"colors.directionsBackground" value:[UIColor brownColor]];
    [themeBuilder setProperty:@"colors.directionsText" value:[UIColor greenColor]];
    [themeBuilder setProperty:@"colors.selectedBackground" value:[UIColor orangeColor]];
    [themeBuilder setProperty:@"colors.suggestedResultBackground" value:[UIColor redColor]];
    [themeBuilder setProperty:@"colors.link" value:[UIColor greenColor]];
    [themeBuilder setProperty:@"colors.keywordText" value:[UIColor redColor]];
    [themeBuilder setProperty:@"colors.keywordBackground" value:[UIColor greenColor]];
    [themeBuilder setProperty:@"colors.otherPlacesText" value:[UIColor redColor]];
    [themeBuilder setProperty:@"colors.otherPlacesBackground" value:[UIColor greenColor]];
    [themeBuilder setProperty:@"colors.placesNearbyText" value:[UIColor greenColor]];
    [themeBuilder setProperty:@"colors.placesNearbyBackground" value:[UIColor redColor]];
    return themeBuilder.theme;
}

// Just bottom bar font and background color
- (LLTheme *)justBottomBarTheme
{
    LLThemeBuilder *themeBuilder = [LLThemeBuilder themeBuilderWithTheme:[LLTheme defaultTheme]];
    [themeBuilder setProperty:@"MapView.BottomBar.backgroundColor" value:[UIColor orangeColor]];
    [themeBuilder setProperty:@"MapView.BottomBar.Button.Title.textColor" value:[UIColor greenColor]];
    return themeBuilder.theme;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    self.themes = [NSMutableArray array];
    self.themeNames = [NSMutableArray array];
    
    // Add in the default theme
    [self.themes addObject:[LLTheme defaultTheme]];
    [self.themeNames addObject:@"Default Theme"];
    
    // Add in other themes
    [self.themes addObject:[self changeBaseFontTheme]];
    [self.themeNames addObject:@"Change Base Font"];
    
    // Add in other themes
    [self.themes addObject:[self yellowBackgroundTheme]];
    [self.themeNames addObject:@"Yellow Background"];
    
    [self.themes addObject:[self uglyTheme]];
    [self.themeNames addObject:@"Ugly Theme"];
    
    [self.themes addObject:[self justBottomBarTheme]];
    [self.themeNames addObject:@"Just Bottom Bar"];
    
    // To this to trick the linker into including the LLMapView symbols
    [LLMapView class];
    
    // Load the map
    self.mapView.delegate = self;
    self.airportDatabase = [LLAirportDatabase airportDatabaseWithMapView:self.mapView];
    self.airportDatabase.delegate = self;

    __weak typeof(self) weakSelf = self;
    [self.airportDatabase loadAirportAndMap:@"sea" block:^(LLAirport *airport, LLMap *map, LLFloor *floor, LLMarker *marker) {
        weakSelf.mapView.map = map;
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)mapViewDidClickBack:(LLMapView *)mapView
{
    self.mapView.hidden = YES;
    self.tableView.hidden = NO;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.themes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"themes"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"themes"];
    }
    
    cell.textLabel.text = self.themeNames[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.mapView.theme = self.themes[indexPath.row];
    self.mapView.hidden = NO;
    self.tableView.hidden = YES;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
