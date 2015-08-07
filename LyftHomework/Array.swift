import Foundation

extension Array {
    var rest: [Element] {
        if self.count > 1 {
            return Array(self[1...self.count - 1])
        } else {
            return []
        }
    }
}