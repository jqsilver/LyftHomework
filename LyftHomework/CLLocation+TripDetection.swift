import Foundation
import CoreLocation



let estimatedCarSpeed: CLLocationSpeed = 4.5 // meters / second
extension CLLocation {
    var isDriving: Bool {
        return self.speed >= estimatedCarSpeed
    }
}
