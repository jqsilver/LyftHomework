import Foundation
import CoreLocation

protocol TripMonitorDelegate: class {
    func tripsDidChange()
}

// TODO: perist trips
class TripMonitor: NSObject, CLLocationManagerDelegate {

    override init() {
        locationManager = CLLocationManager()
        super.init()
        locationManager.delegate = self
    }
    
    private var locationManager: CLLocationManager
    private(set) var enabled = false
    
    // nil means we haven't checked yet
    private var hasPermission: Bool? = nil
    
    private var currentTrip: PendingTrip? = nil
    private(set) var tripLog = [Trip]() {
        didSet(oldValue) {
            delegate?.tripsDidChange()
        }
    }
    
    var isInTripMode: Bool {
        return currentTrip != nil
    }
    
    weak var delegate: TripMonitorDelegate?
    
    private func checkPermission() {
        let authStatus = CLLocationManager.authorizationStatus()
        switch (authStatus) {
        case .NotDetermined:
            // actually request permission
            println("requesting permission")
            locationManager.requestAlwaysAuthorization()
        case .Restricted, .Denied, .AuthorizedWhenInUse:
            println("denied")
            // show an alert that this app is useless
            enabled = false
            hasPermission = false
        case .AuthorizedAlways:
            hasPermission = true
            reallyStartMonitoring()
            println("always")
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
        // TODO: see if switch-case statement is easier to read
        
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
        // TODO: maybe use "significantLocationChangeMonitoring" instead
        if !CLLocationManager.locationServicesEnabled() {
            println("location services still not actually available!")
            return
        }

        println("starting")

        enabled = true
        locationManager.activityType = .AutomotiveNavigation
        // TODO: add UIBackgroundModes to Info.plist
        locationManager.startUpdatingLocation()
        
    }
    
    // MARK: CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedAlways && enabled {
            reallyStartMonitoring()
        } else {
            // TODO: figure this out
            disableMonitoring()
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

        if !isInTripMode && location.isDriving {
            startTrip(location)
        } else if isInTripMode && !location.isDriving {
            // TODO: end trip when still for 10 seconds
            endTrip(location)
        }
    }
    
    private func startTrip(location: CLLocation) {
        assert(currentTrip == nil, "trying to start a trip when one is already started!")
        currentTrip = PendingTrip(location: location)
        println("START: \(location)")
    }
    
    private func endTrip(location: CLLocation) {
        assert(currentTrip != nil, "trying to end nonexistant trip!")
        if let currentTrip = currentTrip {
            tripLog.append(Trip(pendingTrip: currentTrip, endLocation: location))
            self.currentTrip = nil
            println("END: \(location)")
        }
        
        
    }
    
}
