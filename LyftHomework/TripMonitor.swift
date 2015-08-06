import Foundation
import CoreLocation

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
        // clear data
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
        
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println(error)
    }
    
}
