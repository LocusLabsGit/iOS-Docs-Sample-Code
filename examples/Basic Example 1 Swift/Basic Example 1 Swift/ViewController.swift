import UIKit

class ViewController: UIViewController, LLAirportDatabaseDelegate, LLFloorDelegate {

    let airportDatabase = LLAirportDatabase()
    var airport: LLAirport!
    var floor: LLFloor!
    var mapView: LLMapView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize the LocusLabs SDK with the accountId provided by LocusLabs.
        LLLocusLabs.setup().accountId = "A11F4Y6SZRXH4X"

        airportDatabase.delegate = self
        airportDatabase.loadAirport("lax")
    }

    // We loaded the airport; move on to loading a map
    func airportDatabase(_ airportDatabase: LLAirportDatabase!, airportLoaded airport: LLAirport!) {

        // Store the loaded airport
        self.airport = airport

        // Collect the list of buildingsInfos found in this airport and (arbitrarily) load the first one
        let building = airport.loadBuilding((airport.listBuildings()[0] as AnyObject).buildingId)

        // Collect the list of floors found in this building and (arbitrarily) load the first one
        floor = building!.loadFloor((building!.listFloors()[0] as AnyObject).floorId)

        // Make the delegate for the floor, so we receive floor:mapLoaded: call
        floor.delegate = self

        // Load the map for the floor.  Map is sent via floor:mapLoaded:
        floor!.loadMap()
    }

    func floor(_ floor: LLFloor!, mapLoaded map: LLMap!) {
        var frame : CGRect  = view.frame
        frame.origin.y = UIApplication.shared.statusBarFrame.size.height
        frame.size.height -= frame.origin.y

        // Create a new LLMapView, which is a subclass of UIView which knows how to render a map within a view.
        // Load the map into the LLMapView.
        // Add the newly created view as a subview of the fillView.
        mapView = LLMapView(frame: frame)
        mapView!.map = map

        view.addSubview(mapView!)
    }
}


