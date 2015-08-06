import Foundation
import CoreLocation


// TODO: see if there's something more accurate we could do here
let estimatedCarSpeed: CLLocationSpeed = 9 // meters / second
extension CLLocation {
    var isDriving: Bool {
        return self.speed >= estimatedCarSpeed
    }
}
