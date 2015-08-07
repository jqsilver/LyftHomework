import Foundation
import CoreLocation
import AddressBook

extension Array {
    var rest: [Element] {
       return self[1, self.count]
    }
}

/**
    Wraps the CLGeocoder so we can simulate batch fetching
*/
class GeocodingManager {
    private let geocoder = CLGeocoder()
    
    
    func lookupAddresses(locations: [CLLocation], completion: ([String] -> Void)) {
        // CLGeocoder wants to you to only look up one at a time, so let's do some recursive magic to chain the lookups
        if let firstLocation = locations.first {
            let restLocations = Array(locations[1...locations.count])

            // Look up the first address
            lookupAddress(firstLocation) { firstAddress in
                
                // Once that comes back, make a recursive call on the rest of the locations
                self.lookupAddresses(restLocations) { addresses in
                    
                    // Then we can just prepend our result to the beginning of the array
                    let finalResult = [firstAddress] + addresses
                    completion(finalResult)
                }
            }
        } else {
            completion([])
        }
        
    }
    
    private func lookupAddress(location: CLLocation, completion: (String) -> Void) {
        // TODO: caching would be nice

        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let error = error {
                println(error)
                completion("unknown")
            }
            
            if let placemark = placemarks.last as? CLPlacemark {
                let addressString = self.formatPlacemark(placemark)
                completion(addressString)
            }
        }
    }
    
    private func formatPlacemark(placemark: CLPlacemark) -> String {
        let addressDict = placemark.addressDictionary
        return addressDict[kABPersonAddressStreetKey] as? String ?? "unknown"
    }
}
