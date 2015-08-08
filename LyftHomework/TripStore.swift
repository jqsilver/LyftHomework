import Foundation
import CoreLocation

class TripStore {
    
    let userDefaultsKey = "trips"
    let startTripKey = "start"
    let endTripkey = "end"
    
    let dateFormatter = NSDateFormatter()
    
    init() {
        dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
    }
    
    func loadTrips() -> [Trip] {
        if let serializedTrips = NSUserDefaults.standardUserDefaults().objectForKey(userDefaultsKey) as? [ [String: AnyObject]] {
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
            return nil
        }
    }
    
    private func serializeLocation(location: CLLocation) -> [String: AnyObject] {
        let timestampString = dateFormatter.stringFromDate(location.timestamp)
        
        return [
            "lat" : location.coordinate.latitude,
            "lon" : location.coordinate.longitude,
            "timestamp" : timestampString,
        ]
    }
    
    private func deserializeLocation(dict: [String: AnyObject]) -> CLLocation? {
        if let lat = dict["lat"] as? CLLocationDegrees,
           let lon = dict["lon"] as? CLLocationDegrees,
           let timestampString = dict["timestamp"] as? String,
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
            return nil
        }
    }

    
}
