//
//  ViewController.swift
//  ShowFullScreenMapSwift
//
//  Created by Juan Kruger on 31/01/18.
//  Copyright © 2018 LocusLabs. All rights reserved.
//

import UIKit

class ViewController: UIViewController, LLAirportDatabaseDelegate, LLFloorDelegate, LLPositionManagerDelegate {

    // Vars
    var airportDatabase:    LLAirportDatabase!
    var airport:            LLAirport?
    var floor:              LLFloor?
    var mapView:            LLMapView?
    var positionManager:    LLPositionManager?
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Initialize the LocusLabs SDK with the accountId provided by LocusLabs
        LLLocusLabs.setup().accountId = "A11F4Y6SZRXH4X"
        
        // Get an instance of the LLAirportDatabase and register as its delegate
        airportDatabase = LLAirportDatabase()
        airportDatabase.delegate = self
        
        // Request a list of airports - the "airportList" delegate method will be called when the list is ready
        airportDatabase.listAirports()
    }

    // MARK: Custom
    func startTrackingUserPosition() {
        
        positionManager = LLPositionManager(airports: [airport as Any])
        positionManager?.delegate = self
        
        // Start with passive positioning to conserve battery
        positionManager?.passivePositioning = true;
    }
    
    // MARK: Delegates - LLAirportDatabase
    func airportDatabase(_ airportDatabase: LLAirportDatabase!, airportList: [Any]!) {
        
        airportDatabase.loadAirport("lax")
    }
    
    func airportDatabase(_ airportDatabase: LLAirportDatabase!, airportLoaded airport: LLAirport!) {
        
        self.airport = airport
        
        // Get a list of buildings in this airport and load the first one
        if let buildingInfo = self.airport?.listBuildings().first as? LLBuildingInfo {
            
            let building = self.airport?.loadBuilding(buildingInfo.buildingId)
            
            // Get a list of floors for the building and load the first one
            if let floorInfo = building?.listFloors().first as? LLFloorInfo {
                
                floor = building?.loadFloor(floorInfo.floorId)
                
                // Set the floor delegate and load its map - mapLoaded is called when loading is complete
                floor?.delegate = self
                floor?.loadMap()
                
                startTrackingUserPosition()
            }
        }
    }
    
    // MARK: Delegates - LLFloor
    func floor(_ floor: LLFloor!, mapLoaded map: LLMap!) {
        
        // Create a new LLMapView, set its map and add it as a subview
        mapView = LLMapView()
        
        if mapView != nil {
            
            mapView!.map = map
            view.addSubview(mapView!)
            
            mapView?.positioningEnabled = true
            
            // Set the mapview's layout constraints
            mapView!.translatesAutoresizingMaskIntoConstraints = false
            mapView!.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
            mapView!.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
            mapView!.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
            mapView!.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        }
    }
    
    // MARK: Delegates LL PositionManager
    func positionManager(_ positionManager: LLPositionManager!, positioningAvailable: Bool) {
        
        if positioningAvailable {
            
            print("Positioning available")
        }
        else {
            
            print("Positioning not available - determine if bluetooth is active and prompt user if not.")
        }
    }
    
    func positionManager(_ positionManager: LLPositionManager!, positionChanged position: LLPosition!) {
        
        if position == nil {
            
            print("Unable to locate user")
            return
        }
        
        // If we're near a venue, start active positioning (more battery intensive but provides accurate tracking)
        if position.venueId != nil {
            
            positionManager.activePositioning = true
            print("Near venueId: %@", position.venueId)
        }
    }
}

