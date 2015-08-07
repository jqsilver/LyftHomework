import Foundation
import CoreLocation

protocol TripMonitorDelegate: class {
    func tripsDidChange()
}

// TODO: persist trips
class TripMonitor: NSObject, CLLocationManagerDelegate {
//    let timeStillToEndTrip: NSTimeInterval = 60 // 1 minute
    let timeStillToEndTrip: NSTimeInterval = 5
    let carSpeed = 4.5 // meters / second, ~10 mph
    
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
    
    func fakeData() -> [Trip] {
        let start = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 37.78583400, longitude: -122.40641700), altitude: 0, horizontalAccuracy: 0, verticalAccuracy: 0, course: 0, speed: 0, timestamp: NSDate())
        let end = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 37.78583400, longitude: -122.40641700), altitude: 0, horizontalAccuracy: 0, verticalAccuracy: 0, course: 0, speed: 0, timestamp: NSDate(timeIntervalSinceNow: 60 * 44))
        return [Trip(startLocation: start, endLocation: end)]
    }
    
    var isInTripMode: Bool {
        return currentTrip != nil
    }
    
    private var becameStillAt: NSDate? = nil
    
    weak var delegate: TripMonitorDelegate?
    
    override init() {
        locationManager = CLLocationManager()
        super.init()
        locationManager.delegate = self
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
        tripLog = fakeData()

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
    
    // TODO: try to make more testable
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
            tripLog.append(Trip(pendingTrip: currentTrip, endLocation: location))
            self.currentTrip = nil
            becameStillAt = nil
            println("END: \(location)")
        }
        
        
    }
    
}
