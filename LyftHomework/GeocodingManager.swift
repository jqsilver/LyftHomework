import Foundation
import CoreLocation
import AddressBook

/**
    Wraps the CLGeocoder so we can simulate batch fetching
*/
class GeocodingManager {
    private let geocoder = CLGeocoder()
    private var cache = [CLLocation: String]()
    

    // It might more standard to use NSOperations here, but then you'd need shared mutable state, which I'd like to avoid.
    func lookupAddresses(locations: [CLLocation], completion: () -> Void) {
        // CLGeocoder wants to you to only look up one at a time, so let's do some recursive magic to chain the lookups
        if let firstLocation = locations.first {

            // TODO: consider using ArraySlices everywhere
            let restLocations = locations.rest

            // Look up the first address
            fetchAddress(firstLocation) { _ in
                
                // Once that comes back, make a recursive call on the rest of the locations
                self.lookupAddresses(restLocations) {
                    completion()
                }
            }
        } else {
            completion()
        }
        
    }
    
    // Get the address right away, or return nil if it hasn't been fetched
    func getAddress(location: CLLocation) -> String? {
        return cache[location]
    }
    
    func fetchAddress(location: CLLocation, completion: (String?) -> Void) {
        if let address = cache[location] {
            completion(address)
            return
        }

        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let error = error {
                println(error)
                completion(nil)
            }
            
            if let placemark = placemarks.last as? CLPlacemark {
                let addressString = self.formatAddress(placemark)
                self.cache[location] = addressString
                completion(addressString)
            }
        }
    }
    
    private func formatAddress(placemark: CLPlacemark) -> String? {
        let addressDict = placemark.addressDictionary
        return addressDict[kABPersonAddressStreetKey] as? String
    }
}
