import Foundation

@Observable
@MainActor
final class SeenStore {
    private let key = "seenPhotoIdentifiers"
    private(set) var identifiers: Set<String>

    var count: Int { identifiers.count }

    init() {
        let stored = UserDefaults.standard.stringArray(forKey: key) ?? []
        identifiers = Set(stored)
    }

    func contains(_ identifier: String) -> Bool {
        identifiers.contains(identifier)
    }

    func markSeen(_ identifier: String) {
        guard identifiers.insert(identifier).inserted else { return }
        persist()
    }

    func markSeen(_ identifiers: [String]) {
        var changed = false
        for id in identifiers where self.identifiers.insert(id).inserted {
            changed = true
        }
        if changed { persist() }
    }

    func unmark(_ identifier: String) {
        guard identifiers.remove(identifier) != nil else { return }
        persist()
    }

    func reset() {
        identifiers.removeAll()
        persist()
    }

    private func persist() {
        UserDefaults.standard.set(Array(identifiers), forKey: key)
    }
}
