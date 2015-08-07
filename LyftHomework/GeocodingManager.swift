import Foundation
import CoreLocation
import AddressBook

extension Array {
    var rest: [Element] {
        if self.count > 1 {
            return Array(self[1...self.count - 1])
        } else {
            return []
        }
    }
}

/**
    Wraps the CLGeocoder so we can simulate batch fetching
*/
class GeocodingManager {
    private let geocoder = CLGeocoder()
    private var cache = [CLLocation: String]()
    
    
    // TODO: try to do this with NSOperations instead, see if it's any more readable
    func lookupAddresses(locations: [CLLocation], completion: ([String] -> Void)) {
        // CLGeocoder wants to you to only look up one at a time, so let's do some recursive magic to chain the lookups
        if let firstLocation = locations.first {

            // TODO: consider using ArraySlices everywhere
            let restLocations = locations.rest

            // Look up the first address
            lookupAddress(firstLocation) { firstAddress in
                
                // Once that comes back, make a recursive call on the rest of the locations
                self.lookupAddresses(restLocations) { restAddresses in
                    
                    // Then we can just prepend our result to the beginning of the array
                    let finalResult = [firstAddress] + restAddresses
                    completion(finalResult)
                }
            }
        } else {
            completion([])
        }
        
    }
    
    // Get the address right away, or return nil if it's not available
    func getAddress(location: CLLocation) -> String? {
        return cache[location]
    }
    
    func lookupAddress(location: CLLocation, completion: (String) -> Void) {
        // TODO: caching would be nice
        if let address = cache[location] {
            completion(address)
            return
        }

        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let error = error {
                println(error)
                completion("unknown")
            }
            
            if let placemark = placemarks.last as? CLPlacemark {
                let addressString = self.formatPlacemark(placemark)
                self.cache[location] = addressString
                completion(addressString)
            }
        }
    }
    
    private func formatPlacemark(placemark: CLPlacemark) -> String {
        let addressDict = placemark.addressDictionary
        return addressDict[kABPersonAddressStreetKey] as? String ?? "unknown"
    }
}