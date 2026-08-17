import Foundation
import Photos

struct AlbumOption: Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let estimatedCount: Int
    let kind: Kind

    enum Kind: Hashable, Sendable {
        case allPhotos
        case collection(localIdentifier: String)
    }

    static let allPhotos = AlbumOption(
        id: "all-photos",
        title: "All Photos",
        estimatedCount: 0,
        kind: .allPhotos
    )
}
