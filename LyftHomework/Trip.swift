import Foundation
import CoreLocation

struct Trip {
    
    var startLocation: CLLocation
    var endLocation: CLLocation

    var locations: [CLLocation] {
        return [startLocation, endLocation]
    }
    
    init(startLocation: CLLocation, endLocation: CLLocation) {
        self.startLocation = startLocation
        self.endLocation = endLocation
    }
    
    init(pendingTrip: PendingTrip, endLocation: CLLocation) {
        self.startLocation = pendingTrip.location
        self.endLocation = endLocation
    }

    static func fakeData() -> Trip {
        let start = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 37.78583400, longitude: -122.40641700), altitude: 0, horizontalAccuracy: 0, verticalAccuracy: 0, course: 0, speed: 0, timestamp: NSDate())
        let end = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 37.78583400, longitude: -122.40741700), altitude: 0, horizontalAccuracy: 0, verticalAccuracy: 0, course: 0, speed: 0, timestamp: NSDate(timeIntervalSinceNow: 60 * 44))
        return Trip(startLocation: start, endLocation: end)
    }
    
}