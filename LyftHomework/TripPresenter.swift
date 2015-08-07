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
        // TODO: compute and format duration
        return "\(startTimeString)-\(endTimeString)"
    }
    
    func locationString(startAddress: String, endAddress: String) -> String {
        return "\(startAddress) > \(endAddress)"
    }
}
