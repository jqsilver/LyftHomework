import Foundation
import CoreLocation

/**
    Builds all the strings associated with displaying aa Trip
*/
class TripPresenter {

    let dateFormatter = NSDateFormatter()
    let calendar = NSCalendar.currentCalendar()
    let arrowString = "\u{276D}"
    
    init() {
        dateFormatter.dateFormat = "h:mma"
        dateFormatter.AMSymbol = "am"
        dateFormatter.PMSymbol = "pm"
    }
    
    func timeString(trip: Trip) -> String {
        let startTimeString = dateFormatter.stringFromDate(trip.startLocation.timestamp)
        let endTimeString = dateFormatter.stringFromDate(trip.endLocation.timestamp)

        let duration = durationString(trip)
        return "\(startTimeString)-\(endTimeString) \(duration)"
    }
    
    private func durationString(trip: Trip) -> String {
        let duration = calendar.components(.CalendarUnitMinute,
            fromDate: trip.startLocation.timestamp,
            toDate: trip.endLocation.timestamp,
            options: nil)

        if duration.minute >= 1 {
            return String(format: "(%dmin)", duration.minute)
        } else {
            return "(<1min)"
        }
    }
    
    func locationString(startAddress: String, endAddress: String) -> String {
        return "\(startAddress) \(arrowString) \(endAddress)"
    }
    
    func fallbackLocationString(startLocation: CLLocation) -> String {
        let lat = startLocation.coordinate.latitude
        let lon = startLocation.coordinate.longitude
        return String(format: "no address (%.2f, %.2f)", lat, lon)
    }

}
