//
//  ViewController.swift
//  ShowFullScreenMapSwift
//
//  Created by Juan Kruger on 31/01/18.
//  Copyright © 2018 LocusLabs. All rights reserved.
//

import UIKit

class ViewController: UIViewController, LLAirportDatabaseDelegate, LLFloorDelegate {

    // Vars
    var airportDatabase:    LLAirportDatabase!
    var airport:            LLAirport?
    var floor:              LLFloor?
    var mapView:            LLMapView?
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Initialize the LocusLabs SDK with the accountId provided by LocusLabs
        LLLocusLabs.setup().accountId = "A11F4Y6SZRXH4X"
        
        // Get an instance of the LLAirportDatabase, register as its delegate and load the venue LAX
        airportDatabase = LLAirportDatabase()
        airportDatabase.delegate = self
        airportDatabase.loadAirport("lax")
    }
    
    // Implement the airportLoaded delegate method
    func airportDatabase(_ airportDatabase: LLAirportDatabase!, airportLoaded airport: LLAirport!) {
        
        self.airport = airport
        
        /// Get a list of buildings in this airport and load the first one
        if let buildingInfo = self.airport?.listBuildings().first as? LLBuildingInfo {
            
            let building = self.airport?.loadBuilding(buildingInfo.buildingId)
            
            // Get a list of floors for the building and load the first one
            if let floorInfo = building?.listFloors().first as? LLFloorInfo {
                
                floor = building?.loadFloor(floorInfo.floorId)
                
                // Set the floor delegate and load its map - mapLoaded is called when loading is complete
                floor?.delegate = self
                floor?.loadMap()
            }
        }
    }
    

    func airportDatabase(_ airportDatabase: LLAirportDatabase!, airportLoadFailed venueId: String!, code errorCode: LLDownloaderError, message: String!) {
       
        print("Map loading error - handle appropriately")
    }
    
    // MARK: Delegates - LLFloor
    func floor(_ floor: LLFloor!, mapLoaded map: LLMap!) {
        
        // Create a new LLMapView, set its map and add it as a subview
        mapView = LLMapView()
        
        if mapView != nil {
            
            mapView!.map = map
            view.addSubview(mapView!)
            
            // Set the mapview's layout constraints
            mapView!.translatesAutoresizingMaskIntoConstraints = false
            mapView!.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
            mapView!.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
            mapView!.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
            mapView!.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        }
    }
}

