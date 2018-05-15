//
//  ViewController.swift
//  ShowFullScreenMapSwift
//
//  Created by Juan Kruger on 31/01/18.
//  Copyright © 2018 LocusLabs. All rights reserved.
//

import UIKit

class ViewController: UIViewController, LLAirportDatabaseDelegate, LLFloorDelegate, LLMapViewDelegate {

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
        
        // Get an instance of the LLAirportDatabase and register as its delegate
        airportDatabase = LLAirportDatabase()
        airportDatabase.delegate = self
        
        // Request a list of airports - the "airportList" delegate method will be called when the list is ready
        airportDatabase.listAirports()
    }

    // MARK: Delegates - LLAirportDatabase
    func airportDatabase(_ airportDatabase: LLAirportDatabase!, airportList: [Any]!) {
        
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

    // MARK: Delegates - LLFloor
    func floor(_ floor: LLFloor!, mapLoaded map: LLMap!) {
        
        // Create a new LLMapView, set its map and add it as a subview
        mapView = LLMapView()
        
        if mapView != nil {
            
            mapView!.map = map
            view.addSubview(mapView!)
            
            mapView!.delegate = self
            
            // Set the mapview's layout constraints
            mapView!.translatesAutoresizingMaskIntoConstraints = false
            mapView!.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
            mapView!.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
            mapView!.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
            mapView!.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        }
    }
    
    // MARK: Delegates - LLMapView
    func mapViewReady(_ mapView: LLMapView!) {
        
        // Zoom in close to the Starbucks at gate 60 on the departures level of LAX
        mapView.levelSelected("lax-default-Departures")
        mapView.mapCenter = LLLatLng(lat: NSNumber(value:33.94211), lng: NSNumber(value:-118.40210))
        mapView.mapRadius = 50
    }
    
    func mapView(_ mapView: LLMapView!, markerIconUrlForPOI poiId: String!, type: LLMapViewMarkerType) -> String! {
        
        var iconUrl: String?
        
        // 870 is the POI ID for the Starbucks at Gate 60
        if poiId == "870" {
            
            switch type {
                
            case .selected:
                iconUrl = Bundle.main.path(forResource: "starbucks_selected.svg", ofType: nil)
                break
                
            case .unselected:
                iconUrl = Bundle.main.path(forResource: "starbucks_unselected.svg", ofType: nil)
                break
            }
        }
        
        return iconUrl
    }
}

