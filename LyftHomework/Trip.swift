import Foundation
import CoreLocation

struct Trip {
    
    var startLocation: CLLocation
    var endLocation: CLLocation
    
    init(startLocation: CLLocation, endLocation: CLLocation) {
        self.startLocation = startLocation
        self.endLocation = endLocation
    }
    
    init(pendingTrip: PendingTrip, endLocation: CLLocation) {
        self.startLocation = pendingTrip.location
        self.endLocation = endLocation
    }

}