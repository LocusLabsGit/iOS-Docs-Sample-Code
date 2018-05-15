# Navigation Controller Example #

[readme](readme.md)

## Overview ##

You may find it helpful to view the explanations for the [Basic Example](readme.md) before this one.

This example shows a simple example of using a UINavigationController with the LocusLabs SDK. It was modified
from the "Master-Detail Application" template in the standard XCode "new project" template.

In this example, we show a list of available airports on the "master" page and the LocusLabs UI on the "detail" page.

In addition this example demonstrates:

- showing a progress bar while the airport loads
- hiding the navigation bar when using the LocusLabsSDK

## Splitting up the Delegates ##

In this case, the MasterViewController and DetailViewController split up the LocusLabs delegation tasks.

In MasterViewController.h, the MasterView implements only the LLAirportDatabaseDelegate:

    #import <LocusLabsSDK/LocusLabsSDK.h>

    @interface MasterViewController : UITableViewController @end

    @interface MasterViewController(AirportDatabaseDelegate) <LLAirportDatabaseDelegate> @end

while the DetailViewController implements the LLFloorDelegate, LLMapViewDelegate and LLAirportDatabaseDelegate


    #import <LocusLabsSDK/LocusLabsSDK.h>

    @interface DetailViewController : UIViewController
    @property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
    @end

    @interface DetailViewController(FloorDelegate)           <LLFloorDelegate>           @end
    @interface DetailViewController(AirportDatabaseDelegate) <LLAirportDatabaseDelegate> @end
    @interface DetailViewController(MapViewDelegate)         <LLMapViewDelegate>         @end

We will transfer the delegate for the airport database from the MasterViewController to the DetailViewController 
after first retrieving the list of airports, so both have to implement LLAirportDatabaseDelegate.

## Getting the List of Airports ##

As in the Basic Example, the MasterViewController sets up the LocusLabs system and requests a list of airports:

    - (void)viewDidLoad {
        [super viewDidLoad];

        // Initialize the LocusLabs SDK with the accountId provided by LocusLabs.
        [LLLocusLabs setup].accountId = @"A11F4Y6SZRXH4X";
        [LLLogger defaultLogger].logLevel = LLLogLevelVerbose;

        // Create a new LLAirportDatabase object: our top-level entry point into the LocusLabs SDK functionality.
        // Set its delegate: asynchronous calls to LLAirportDatabase are fielded by delegate methods.
        // Initiate a request for the list of airports (to be processed later by LLAirportDatabaseDelegate.airportList)
        self.airportDatabase = [LLAirportDatabase airportDatabase];
        self.airportDatabase.delegate = self;
        [self.airportDatabase listAirports];
    }

When the list of airports is returned, we refresh the UITableView that shows the airport list:

    - (void)airportDatabase:(LLAirportDatabase *)airportDatabase airportList:(NSArray *)airportList
    {
        self.airportList = airportList;
        [self.tableView reloadData];
    }

and we use standard UITableViewDelegate calls to refresh the table:

    - (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
        return self.airportList.count;
    }

    - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

        LLAirportInfo *airportInfo = self.airportList[indexPath.row];
        cell.textLabel.text = airportInfo.airportCode;
        return cell;
    }


## Selecting an Airport ##

When the user selects an airport, we transfer the delegate for the airport database to the DetailViewController
load the airport based on the airport code the user selected, and seque to the DetailViewController. We need to 
transfer the airport database delegate because we want to show the progress bar in the DetailViewController's
view rather than on the MasterViewController's view.

In MasterViewController:

    - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
        if ([[segue identifier] isEqualToString:@"showDetail"]) {

            // although the MasterViewController has been the airportDatabase delegate up until this point
            // the DetailViewController will now become the delegate so it can receive messages about the airport
            self.airportDatabase.delegate = segue.destinationViewController;

            // Load the appropriate airport based on the selected row
            NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
            LLAirportInfo *info = self.airportList[indexPath.row];
            [self.airportDatabase loadAirport:info.airportCode];
        }
    }

## Showing a progress bar and loading the map ##

Because it may take a while to load airport data, the LocusLabs SDK sends progress messages that can be used
for display in a UIProgressView. Because we want the progress bar to be visible in the DetailViewController
we implement the airport database delegate's progress methods:

    - (void)airportDatabase:(LLAirportDatabase *)airportDatabase airportLoadStarted:(NSString*)venueId {

        // create a progress bar
        self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        [self.view addSubview:self.progressView];

        self.progressView.translatesAutoresizingMaskIntoConstraints = NO;

        NSDictionary *views = [NSDictionary dictionaryWithObject:self.progressView forKey:@"progressBar"];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(30)-[progressBar]-(30)-|" options:0 metrics:nil views:views]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(250)-[progressBar]-(250)-|" options:0 metrics:nil views:views]];
        self.progressView.progress = 0.0;
    }

    - (void)airportDatabase:(LLAirportDatabase *)airportDatabase airportLoadStatus:(NSString*)venueId percentage:(int)percent {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.progressView setProgress:percent/100.0 animated:YES];
        });
    }

    - (void)airportDatabase:(LLAirportDatabase *)airportDatabase airportLoadCompleted:(NSString*)venueId {
        [self.progressView removeFromSuperview];
    }

    - (void)airportDatabase:(LLAirportDatabase *)airportDatabase airportLoadFailed:(NSString*)venueId code:(LLDownloaderError)errorCode message:(NSString*)message {
        [self.progressView removeFromSuperview];
        [[[UIAlertView alloc] initWithTitle:@"Assets" message:@"Unable to download assets." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }

We also need to implement the airportDatabase:airportLoaded delegate method:

    - (void)airportDatabase:(LLAirportDatabase *)airportDatabase airportLoaded:(LLAirport *)airport {

        // Collect the list of buildingsInfos found in this airport and (arbitrarily) load the first one
        LLBuildingInfo *buildingInfo = [airport listBuildings][0];
        LLBuilding *building  = [airport loadBuilding:buildingInfo.buildingId];

        // Collect the list of floorInfos found in this building and (arbitrarily) load the first one
        LLFloorInfo *floorInfo = [building listFloors][0];
        LLFloor *floor = [building loadFloor:floorInfo.floorId];

        floor.delegate = self;

        // Load the map for the floor.  Map is sent via floor:mapLoaded:
        [floor loadMap];
    }

## Showing the Airport ##

Finally, the DetailViewController simply places the LLMapView when the floor is loaded:

    - (void)floor:(LLFloor *)floor mapLoaded:(LLMap *)map {
        // Create and initialize a new LLMapView and set its map and delegate
        LLMapView *mapView = [[LLMapView alloc] init];
        self.mapView = mapView;
        mapView.map = map;
        mapView.shouldAllowSpaceForStatusBar = YES;
        mapView.searchBarBackgroundColor = [UIColor lightGrayColor];
        mapView.backButtonText = @"Back";
        mapView.delegate = self;

        // add the mapView as a subview
        [self.view addSubview:mapView];

        // "constrain" the mapView to fill the entire screen
        [mapView setTranslatesAutoresizingMaskIntoConstraints:NO];
        NSDictionary *views = NSDictionaryOfVariableBindings(mapView);
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[mapView]|" options:0 metrics:nil views:views]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[mapView]|" options:0 metrics:nil views:views]];
    }


## Modifying the UI ##

The DetailViewController also makes adjustments to the LocusLabs UI.

### Hiding the Navigation Bar ###

By default, a UI with a UINavigationController normally has a "navigation bar" at the top, with the view controller's own views
beneath it. Since the LLMapView basically acts as a navigation bar itself, we want to hide the "normal" navigation bar when showing
the airport and put it back when we're done:

    - (void)viewWillAppear:(BOOL)animated {
        [super viewWillAppear:animated];
        [self.navigationController setNavigationBarHidden:YES animated:NO];
    }

    - (void)viewWillDisappear:(BOOL)animated {
        [super viewWillDisappear:animated];
        [self.navigationController setNavigationBarHidden:NO animated:NO];
    }

### Handling the Status Bar ###

Since we want the status bar to show at the top of the screen, we can tell the LLMapView to leave extra space for it. While 
we're at it, we can also change the background color of the status bar as well and the text of the "back" button:

        ...
        mapView.shouldAllowSpaceForStatusBar = YES;
        mapView.searchBarBackgroundColor = [UIColor lightGrayColor];
        mapView.backButtonText = @"Back";
        ...

### Handling the Back Button ###

Finally, we need to return to the list of airports when the user hits the "back" button, which we do by handling the 
LLMapViewDelegate method: mapViewDidClickBack:


    - (void)mapViewDidClickBack:(LLMapView *)mapView {
        [self.navigationController popViewControllerAnimated:YES];
    }




