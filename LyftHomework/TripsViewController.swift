import UIKit
import CoreLocation

class TripsViewController: UIViewController, TripMonitorDelegate, UITableViewDataSource {

    let cellId = "tripCell"
    
    @IBOutlet weak var tableView: UITableView!
    
    var data = [Trip]()
    let tripMonitor = TripMonitor()
    let geocodeManager = GeocodingManager()
    let tripPresenter = TripPresenter()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.titleView = UIImageView(image: UIImage(named: "navbar"))

        data = tripMonitor.tripLog

        tripMonitor.delegate = self
        tableView.dataSource = self
    }
    
    // MARK: on/off switch 
    
    @IBAction func onOffToggled(sender: UISwitch) {
        if sender.on {
            tripMonitor.enableMonitoring()
        } else {
            tripMonitor.disableMonitoring()
        }
    }
    
    // MARK: getting updates from monitor
    
    func tripsDidChange() {
        // TODO: do cell animations for a new trip
        let trips = tripMonitor.tripLog
        
        // TODO: something clever and functional here
        var locations = [CLLocation]()
        for trip in trips {
            locations.append(trip.startLocation)
            locations.append(trip.endLocation)
        }

        geocodeManager.lookupAddresses(locations) { addresses in
            self.data = trips
            self.tableView.reloadData()
        }
    }
    
    
    // MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection: Int) -> Int {
        assert(numberOfRowsInSection == 0)
        return data.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        assert(tableView == self.tableView)
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath) as! UITableViewCell
        
        // Apparently need this for the separator to work in ios 8
        cell.preservesSuperviewLayoutMargins = false
        // TODO: it still doesn't actually work though
        
        let trip = data[indexPath.row]
        
        let startLocationAddress = geocodeManager.getAddress(trip.startLocation) ?? "unfetched"
        let endLocationAddress = geocodeManager.getAddress(trip.endLocation) ?? "unfetched"
        
        cell.textLabel?.text = tripPresenter.locationString(startLocationAddress, endAddress: endLocationAddress)
        cell.detailTextLabel?.text = tripPresenter.timeString(trip)
        
        return cell
    }

}

