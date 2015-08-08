import UIKit
import CoreLocation

class TripsViewController: UIViewController, TripMonitorDelegate, UITableViewDataSource {

    let cellId = "tripCell"
    
    @IBOutlet weak var monitoringToggle: UISwitch!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topViewBorderHeight: NSLayoutConstraint!
    
    var data = [Trip]()
    
    let tripMonitor = TripMonitor()
    let geocodeManager = GeocodingManager()
    let tripPresenter = TripPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.titleView = UIImageView(image: UIImage(named: "navbar"))

        // Can't get hairlines in IB.  Also I know this will look weird on 6+, but it's pretty close
        topViewBorderHeight.constant = 0.5
        
        tripMonitor.delegate = self
        tableView.dataSource = self
        fetchAddressesAndReloadData()
    }
    
    // MARK: on/off switch 
    
    @IBAction func onOffToggled(sender: UISwitch) {
        if sender.on {
            tripMonitor.enableMonitoring()
        } else {
            tripMonitor.disableMonitoring()
        }
    }
    
    // MARK: TripMonitorDelegate

    func monitoringPermissionDenied() {
        let alert = UIAlertController(title: "Location Permission Denied", message: "Please enable location permission level Always", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .Default, handler: nil))
        presentViewController(alert, animated: true) {
            self.monitoringToggle.setOn(false, animated: true)
        }
    }
    
    private func fetchAddressesAndReloadData() {
        let trips = tripMonitor.tripLog
        
        let locations = trips.flatMap { $0.locations }
        
        geocodeManager.fetchAddresses(locations) {
            self.data = trips
            self.tableView.reloadData()
        }
    }
    
    private func addNewTrip(trip: Trip) {
        tableView.beginUpdates()
        data.append(trip)
        let indexPaths = [NSIndexPath(forRow: data.count - 1, inSection: 0)]
        tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Automatic)
        tableView.endUpdates()
    }
    
    func tripCompleted(trip: Trip) {
        geocodeManager.fetchAddresses(trip.locations) {
            self.addNewTrip(trip)
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
        
        // Apparently need this for the separator inset to actually be 0 in ios 8
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = UIEdgeInsetsZero
        
        let trip = data[indexPath.row]
        
        let startLocationAddress = geocodeManager.getAddress(trip.startLocation) ?? tripPresenter.fallbackLocationString(trip.startLocation)
        let endLocationAddress = geocodeManager.getAddress(trip.endLocation) ?? tripPresenter.fallbackLocationString(trip.endLocation)
        
        cell.textLabel?.text = tripPresenter.locationString(startLocationAddress, endAddress: endLocationAddress)
        cell.detailTextLabel?.text = tripPresenter.timeString(trip)
        
        return cell
    }

}

