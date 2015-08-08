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

// Filters an array of optionals into an array of non-optionals, with nice type guarantees
func filterNil<Element>(arr: [Element?]) -> [Element] {
    var filtered = [Element]()
    for elem in arr {
        if let elem = elem {
            filtered.append(elem)
        }
    }
    return filtered
}