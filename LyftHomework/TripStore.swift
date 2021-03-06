import Foundation
import CoreLocation

/**
    Handles peristing a list of trips.
*/
class TripStore {
    
    let userDefaultsKey = "trips"
    let startTripKey = "start"
    let endTripkey = "end"
    let latKey = "lat"
    let lonKey = "lon"
    let timestampKey = "timestamp"
    
    let dateFormatter = NSDateFormatter()
    
    init() {
        dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
    }
    
    func loadTrips() -> [Trip] {
        if let serializedTrips = NSUserDefaults.standardUserDefaults().objectForKey(userDefaultsKey) as? [[String: AnyObject]] {
            let trips = serializedTrips.map(self.deserializeTrip)
            return filterNil(trips)
        } else {
            return []
        }
    }
    
    func saveTrips(trips: [Trip]) {
        let serializedTrips = trips.map(self.serializeTrip)
        
        NSUserDefaults.standardUserDefaults().setObject(serializedTrips, forKey: userDefaultsKey)
    }

    private func serializeTrip(trip: Trip) -> [String: AnyObject] {
        return [
            startTripKey : serializeLocation(trip.startLocation),
            endTripkey : serializeLocation(trip.endLocation)
        ]
    }
    
    private func deserializeTrip(tripDict: [String: AnyObject]) -> Trip? {
        if let startLocationDict = tripDict[startTripKey] as? [String: AnyObject],
            let endLocationDict = tripDict[endTripkey] as? [String: AnyObject],
            let startLocation = deserializeLocation(startLocationDict),
            let endLocation = deserializeLocation(endLocationDict)
        {
            return Trip(startLocation: startLocation, endLocation: endLocation)
        } else {
            println("something missing from trip dictionary \(tripDict)")
            return nil
        }
    }
    
    private func serializeLocation(location: CLLocation) -> [String: AnyObject] {
        let timestampString = dateFormatter.stringFromDate(location.timestamp)
        
        return [
            latKey : location.coordinate.latitude,
            lonKey : location.coordinate.longitude,
            timestampKey : timestampString,
        ]
    }
    
    private func deserializeLocation(locationDict: [String: AnyObject]) -> CLLocation? {
        if let lat = locationDict[latKey] as? CLLocationDegrees,
           let lon = locationDict[lonKey] as? CLLocationDegrees,
           let timestampString = locationDict[timestampKey] as? String,
           let timestamp = dateFormatter.dateFromString(timestampString)
        {
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            return CLLocation(coordinate: coordinate,
                altitude: 0,
                horizontalAccuracy: 0,
                verticalAccuracy: 0,
                course: 0,
                speed: 0,
                timestamp: timestamp
            )
        } else {
            println("something was missing from location dictionary \(locationDict)")
            return nil
        }
    }

    
}
