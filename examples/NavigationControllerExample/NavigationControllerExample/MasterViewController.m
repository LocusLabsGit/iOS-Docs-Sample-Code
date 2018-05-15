//
//  MasterViewController.m
//  NavigationControllerExample
//
//  Created by Jeff Goldberg on 3/4/15.
//  Copyright (c) 2015 LocusLabs. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"

@interface MasterViewController ()

@property (strong, nonatomic) LLAirportDatabase *airportDatabase;
@property (strong, nonatomic) LLAirport *airport;
@property (strong, nonatomic) NSArray *airportList;

@end

@implementation MasterViewController

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Initialize the LocusLabs SDK with the accountId provided by LocusLabs.
    [LLLocusLabs setup].accountId = @"A11F4Y6SZRXH4X";

    // Create a new LLAirportDatabase object: our top-level entry point into the LocusLabs SDK functionality.
    // Set its delegate: asynchronous calls to LLAirportDatabase are fielded by delegate methods.
    // Initiate a request for the list of airports (to be processed later by LLAirportDatabaseDelegate.airportList)
    self.airportDatabase = [LLAirportDatabase airportDatabase];
    self.airportDatabase.delegate = self;
    [self.airportDatabase listAirports];
}

#pragma mark - Segue

// The user has clicked on an airport and the DetailViewController is about to appear.
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


#pragma mark - Table View


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.airportList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    LLAirportInfo *airportInfo = self.airportList[indexPath.row];
    cell.textLabel.text = airportInfo.airportCode;
    return cell;
}


@end

// ---------------------------------------------------------------------------------------------------------------------
//  LLAirportDatabaseDelegate
//
// - airportDatabase:airportList:
//
// ---------------------------------------------------------------------------------------------------------------------
@implementation MasterViewController(LLAirportDatabaseDelegate)

// ---------------------------------------------------------------------------------------------------------------------
//  airportDatabase:airportList
//
//  Receive the list of available airports and (arbitrarily) pick one to show
// ---------------------------------------------------------------------------------------------------------------------
- (void)airportDatabase:(LLAirportDatabase *)airportDatabase airportList:(NSArray *)airportList
{
    self.airportList = airportList;
    [self.tableView reloadData];
}


@end
