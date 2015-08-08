import Foundation
import CoreLocation

protocol TripMonitorDelegate: class {
    func tripCompleted(trip: Trip)
    func monitoringPermissionDenied()
}

/**
    Talks to CLLocationManager and generates and tracks Trips.
*/
class TripMonitor: NSObject, CLLocationManagerDelegate {
    let timeStillToEndTrip: NSTimeInterval = 60 // 1 minute
    let carSpeed = 4.5 // meters / second, ~10 mph
    
    private var tripStore: TripStore
    private var locationManager: CLLocationManager
    
    private var hasPermission: Bool? {
        let authStatus = CLLocationManager.authorizationStatus()
        switch (authStatus) {
        case .NotDetermined:
            return nil
        case .Restricted, .Denied, .AuthorizedWhenInUse:
            return false
        case .AuthorizedAlways:
            return true
        }
    }

    // I hate having boolean flags but it's just faster this way
    private var enabledPendingPermission = false
    
    private var currentTrip: PendingTrip? = nil
    private(set) var tripLog = [Trip]()
    private var becameStillAt: NSDate? = nil
    
    weak var delegate: TripMonitorDelegate?
    
    var isInTripMode: Bool {
        return currentTrip != nil
    }
    
    override init() {
        tripStore = TripStore()
        locationManager = CLLocationManager()
        super.init()
        locationManager.delegate = self
        tripLog = tripStore.loadTrips()
    }
    
    // MARK: on/off switch
    
    func disableMonitoring() {
        currentTrip = nil
        locationManager.stopUpdatingLocation()
    }
    
    func enableMonitoring() {
        if hasPermission == true {
            reallyStartMonitoring()
        } else if hasPermission == false {
            delegate?.monitoringPermissionDenied()
        } else {
            enabledPendingPermission = true
            locationManager.requestAlwaysAuthorization()
        }
    }
    
    private func reallyStartMonitoring() {
        if !CLLocationManager.locationServicesEnabled() {
            println("location services still not actually available")
            delegate?.monitoringPermissionDenied()
            return
        }
        
        locationManager.activityType = .AutomotiveNavigation
        locationManager.startUpdatingLocation()
    }
    
    // MARK: CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedAlways {
            if enabledPendingPermission {
                reallyStartMonitoring()
                enabledPendingPermission = false
            }
        } else {
            disableMonitoring()
            if status != .NotDetermined {
                delegate?.monitoringPermissionDenied()
            }
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        println(locations)
        if let locations = locations as? [CLLocation] {
            for location in locations {
                handleLocationUpdate(location)
            }
        } else {
            assert(false, "Didn't get [CLLocation] for locations")
        }
        
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        // Not really sure how to react to these errors.  They're really vague.
        println(error)
    }
    
    // MARK actual trip logging
    
    private func handleLocationUpdate(location: CLLocation) {

        if isInTripMode {
            if location.speed <= 0 {
                handleStillness(location)
            } else {
                becameStillAt = nil
            }
        } else {
            if location.speed >= carSpeed {
                startTrip(location)
            }
        }
    }
    
    // In a larger project I'd try to make this more functional so it's easier to test
    private func handleStillness(location: CLLocation) {
        if let becameStillAt = becameStillAt {
            let timeStill = -becameStillAt.timeIntervalSinceNow
            if timeStill >= timeStillToEndTrip {
                endTrip(location)
            }
        } else {
            // Record beginning of stillness
            becameStillAt = NSDate()
        }
    }
    
    private func startTrip(location: CLLocation) {
        assert(currentTrip == nil, "trying to start a trip when one is already started!")
        currentTrip = PendingTrip(location: location)
        becameStillAt = nil
        println("START: \(location)")
    }
    
    private func endTrip(location: CLLocation) {
        assert(currentTrip != nil, "trying to end nonexistant trip!")
        if let currentTrip = currentTrip {
            let newTrip = Trip(pendingTrip: currentTrip, endLocation: location)
            tripLog.append(newTrip)
            delegate?.tripCompleted(newTrip)
            tripStore.saveTrips(tripLog)
            
            self.currentTrip = nil
            becameStillAt = nil
            println("END: \(location)")
        }
    }
    
}
