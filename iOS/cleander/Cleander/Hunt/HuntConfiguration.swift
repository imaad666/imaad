import Foundation
import Photos

struct HuntConfiguration: Hashable, Identifiable, Sendable {
    let id: UUID
    var album: AlbumOption
    var isUnlimited: Bool
    var photoCount: Int

    init(id: UUID = UUID(), album: AlbumOption, isUnlimited: Bool, photoCount: Int) {
        self.id = id
        self.album = album
        self.isUnlimited = isUnlimited
        self.photoCount = photoCount
    }

    var displayLimit: Int? {
        isUnlimited ? nil : max(photoCount, 1)
    }

    var summary: String {
        if isUnlimited {
            return "\(album.title) · Unlimited"
        }
        return "\(album.title) · \(photoCount) photos"
    }
}
