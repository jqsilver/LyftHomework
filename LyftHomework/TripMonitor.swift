import Foundation
import CoreLocation

protocol TripMonitorDelegate: class {
    func tripsDidChange()
    func tripCompleted(trip: Trip)
    func monitoringPermissionDenied()
}

class TripMonitor: NSObject, CLLocationManagerDelegate {
    let timeStillToEndTrip: NSTimeInterval = 60 // 1 minute
    let carSpeed = 4.5 // meters / second, ~10 mph
    
    private var tripStore: TripStore
    private var locationManager: CLLocationManager
    private(set) var enabled = false
    
    // nil means we haven't checked for permissions yet
    private var hasPermission: Bool? = nil
    
    private var currentTrip: PendingTrip? = nil
    private(set) var tripLog = [Trip]()
    
    var isInTripMode: Bool {
        return currentTrip != nil
    }
    
    private var becameStillAt: NSDate? = nil
    
    weak var delegate: TripMonitorDelegate?
    
    override init() {
        tripStore = TripStore()
        locationManager = CLLocationManager()
        super.init()
        locationManager.delegate = self
        tripLog = tripStore.loadTrips()
    }
    
    private func checkPermission() {
        let authStatus = CLLocationManager.authorizationStatus()
        switch (authStatus) {
        case .NotDetermined:
            // actually request permission
            println("requesting permission")
            locationManager.requestAlwaysAuthorization()
        case .Restricted, .Denied, .AuthorizedWhenInUse:
            println("denied")
            hasPermission = false
            disableMonitoring()
            delegate?.monitoringPermissionDenied()
        case .AuthorizedAlways:
            hasPermission = true
            reallyStartMonitoring()
        }
    }
    
    // MARK: on/off switch
    
    func disableMonitoring() {
        enabled = false
        currentTrip = nil
        locationManager.stopUpdatingLocation()
        println("disabled")
    }
    
    func enableMonitoring() {
        if let checkedPermission = hasPermission {
            if checkedPermission {
                reallyStartMonitoring()
            } else {
                println("no permission: not enabled")
            }
        } else {
            checkPermission()
        }
    }
    
    private func reallyStartMonitoring() {
        if !CLLocationManager.locationServicesEnabled() {
            println("location services still not actually available")
            delegate?.monitoringPermissionDenied()
            return
        }

        println("starting")
        
        enabled = true
        locationManager.activityType = .AutomotiveNavigation
        locationManager.startUpdatingLocation()
    }
    
    // MARK: CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedAlways {
            if enabled {
                reallyStartMonitoring()
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
    
    // In a larger project I'd try to make this more testable
    private func handleStillness(location: CLLocation) {
        if let becameStillAt = becameStillAt {
            // check time difference
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
