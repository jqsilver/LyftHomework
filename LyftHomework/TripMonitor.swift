import Foundation
import CoreLocation

// TODO: perist trips
class TripMonitor {

    init() {
        locationManager = CLLocationManager()
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
            enabled = true
            println("always")
        }
    }
    
    // MARK: on/off switch

    
    func disableMonitoring() {
        enabled = false
        // clear data
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
        enabled = true
        println("starting")
    }
    
}
