import Foundation
import CoreLocation

class TripPresenter {

    let dateFormatter = NSDateFormatter()
    let calendar = NSCalendar.currentCalendar()
    
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
    
    func durationString(trip: Trip) -> String {
        let duration = calendar.components(.CalendarUnitMinute,
            fromDate: trip.startLocation.timestamp,
            toDate: trip.endLocation.timestamp,
            options: nil)

        if duration.minute >= 1 {
            return String(format: "(%dmin)", duration.minute)
        } else {
            return "<1min"
        }
    }
    
    func locationString(startAddress: String, endAddress: String) -> String {
        return "\(startAddress) \u{276D} \(endAddress)"
    }
}
