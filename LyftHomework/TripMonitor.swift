import Foundation

/**
    TODO: integrate with LocationManager
*/
class TripMonitor {
    static private var instance: TripMonitor?
    class func sharedMonitor() -> TripMonitor {
        if let instance = instance {
            return instance
        } else {
            instance = TripMonitor()
            return instance!
        }
    }

    private init() {
    }
    
    
    // MARK: on/off switch
    
    private var enabled: Bool = true
    
    func disableMonitoring() {
        enabled = false
        // clear data
        println("disabled")
    }
    
    func enableMonitoring() {
        enabled = true
        println("enabling")
    }
    
}
