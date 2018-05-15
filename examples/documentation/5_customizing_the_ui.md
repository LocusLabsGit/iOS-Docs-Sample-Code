# Customizing the UI #

[readme](readme.md)

## Overview ##

This example shows how to modify the LocusLabs UI to:

- set the text of the "back" button
- change the color of the search bar
- handle the iOS status bar
- set a navigation disclaimer

## Organizing the code ##

In this there are just a few lines to add to the previous example. In the floor:mapLoaded method, add these lines

    - (void)floor:(LLFloor *)floor mapLoaded:(LLMap *)map
    {
        ...
        mapView.delegate = self;

        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        self.mapView.shouldAllowSpaceForStatusBar = true;
        self.mapView.backButtonText = @"Back";
        self.mapView.searchBarBackgroundColor = [UIColor lightGrayColor];

        ...
    }


## Changing the Back Button Text ##

When you put a LocusLabs LLMapView onscreen, there is (usually) a searchbar at the top of the screen which looks like a 
standard iOS title bar, with a "back" button on the left, a search area in the middle and "navigation" button on the right.

The default text for the back button is "Flight" but this can be changed using this line of code:

        self.mapView.backButtonText = @"Back";

## Changing the Color of the Search Bar ##

You can change the color of the entire LocusLabs search bar using this line of code:

        self.mapView.searchBarBackgroundColor = [UIColor lightGrayColor];

## Handling the iOS Status Bar ##

If your UI includes the iOS status bar and you place an LLMapView at the top of the screen, the LocusLabs UI may overlap 
the status bar making it difficult to read. You can get fix this by tellling the LLMapView that it should allow extra
space at the top to allow for the status bar:

        self.mapView.shouldAllowSpaceForStatusBar = true;

This will cause the LocusLabs search bar to become 20 pixels taller, filling the extra space with the appropriate background color.

## Setting a Navigation Disclaimer ##

This allows you to set a custom message which appears in an alert box after the user pushes the "route" button and 
before they are shown the directions.  The purpose is to notify them that navigation times are estimated and do not
guarrenty accurate arrival times.  As part of the alert dialog, they are given the option of either cancling the
navigation or proceeding.

To set a disclaimer, do the following:

        self.mapView.navigationDisclaimer = @"Note: Navigation times are estimates and should not be considered guarrentied arrival time.";