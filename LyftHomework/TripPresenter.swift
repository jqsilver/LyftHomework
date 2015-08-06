import Foundation
import CoreLocation

class TripPresenter {

    let dateFormatter = NSDateFormatter()
    
    init() {
        dateFormatter.dateFormat = "h:mma"
        dateFormatter.AMSymbol = "am"
        dateFormatter.PMSymbol = "pm"
    }
    
    func timeString(trip: Trip) -> String {
        let startTimeString = dateFormatter.stringFromDate(trip.startLocation.timestamp)
        let endTimeString = dateFormatter.stringFromDate(trip.endLocation.timestamp)
        // TODO: duration later
        return "\(startTimeString)-\(endTimeString)"
    }
    
    func locationString(trip: Trip) -> String {
        // TODO: geocoding!
        let start = trip.startLocation.coordinate
        let end = trip.endLocation.coordinate
        
        return "\(start) > \(end)"
    }
}