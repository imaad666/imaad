import Foundation
import Photos
import UIKit

@Observable
@MainActor
final class PhotoLibraryService {
    private let imageManager = PHCachingImageManager()

    var authorizationStatus: PHAuthorizationStatus {
        PHPhotoLibrary.authorizationStatus(for: .readWrite)
    }

    func requestAuthorization() async -> PHAuthorizationStatus {
        await PHPhotoLibrary.requestAuthorization(for: .readWrite)
    }

    func fetchAlbums() -> [AlbumOption] {
        var albums: [AlbumOption] = []

        let allPhotosCount = fetchAllImageAssets().count
        albums.append(
            AlbumOption(
                id: "all-photos",
                title: "All Photos",
                estimatedCount: allPhotosCount,
                kind: .allPhotos
            )
        )

        appendCollections(
            PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil),
            to: &albums
        )

        let smartAlbums = PHAssetCollection.fetchAssetCollections(
            with: .smartAlbum,
            subtype: .any,
            options: nil
        )
        albums.append(contentsOf: albumsFromCollections(smartAlbums, skippingUserLibrary: true))

        return albums
    }

    func fetchHuntAssets(
        album: AlbumOption,
        excluding seen: Set<String>,
        limit: Int?
    ) -> [PHAsset] {
        let assets = assets(in: album)
        let unseen = assets.filter { !seen.contains($0.localIdentifier) }
        let shuffled = unseen.shuffled()
        if let limit, limit > 0 {
            return Array(shuffled.prefix(limit))
        }
        return shuffled
    }

    func requestImage(
        for asset: PHAsset,
        targetSize: CGSize,
        contentMode: PHImageContentMode = .aspectFill
    ) async -> UIImage? {
        await withCheckedContinuation { continuation in
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.resizeMode = .fast
            options.isNetworkAccessAllowed = true
            options.isSynchronous = false

            let lock = NSLock()
            var hasResumed = false

            imageManager.requestImage(
                for: asset,
                targetSize: targetSize,
                contentMode: contentMode,
                options: options
            ) { image, info in
                let cancelled = (info?[PHImageCancelledKey] as? Bool) ?? false
                let degraded = (info?[PHImageResultIsDegradedKey] as? Bool) ?? false
                if cancelled {
                    lock.lock()
                    defer { lock.unlock() }
                    guard !hasResumed else { return }
                    hasResumed = true
                    continuation.resume(returning: nil)
                    return
                }
                if degraded { return }
                lock.lock()
                defer { lock.unlock() }
                guard !hasResumed else { return }
                hasResumed = true
                continuation.resume(returning: image)
            }
        }
    }

    func deleteAssets(_ assets: [PHAsset]) async throws {
        guard !assets.isEmpty else { return }
        try await PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.deleteAssets(assets as NSArray)
        }
    }

    private func appendCollections(
        _ result: PHFetchResult<PHAssetCollection>,
        to albums: inout [AlbumOption]
    ) {
        albums.append(contentsOf: albumsFromCollections(result, skippingUserLibrary: false))
    }

    private func albumsFromCollections(
        _ result: PHFetchResult<PHAssetCollection>,
        skippingUserLibrary: Bool
    ) -> [AlbumOption] {
        var options: [AlbumOption] = []
        options.reserveCapacity(result.count)

        for index in 0..<result.count {
            let collection = result.object(at: index)
            if skippingUserLibrary, collection.assetCollectionSubtype == .smartAlbumUserLibrary {
                continue
            }
            let count = imageCount(in: collection)
            guard count > 0 else { continue }
            options.append(
                AlbumOption(
                    id: collection.localIdentifier,
                    title: collection.localizedTitle ?? "Album",
                    estimatedCount: count,
                    kind: .collection(localIdentifier: collection.localIdentifier)
                )
            )
        }

        return options
    }

    private func assets(in album: AlbumOption) -> [PHAsset] {
        switch album.kind {
        case .allPhotos:
            return fetchAllImageAssets()
        case .collection(let localIdentifier):
            let collections = PHAssetCollection.fetchAssetCollections(
                withLocalIdentifiers: [localIdentifier],
                options: nil
            )
            guard let collection = collections.firstObject else { return [] }
            return fetchImageAssets(in: collection)
        }
    }

    private func fetchAllImageAssets() -> [PHAsset] {
        let options = PHFetchOptions()
        options.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        return mapAssets(PHAsset.fetchAssets(with: options))
    }

    private func fetchImageAssets(in collection: PHAssetCollection) -> [PHAsset] {
        let options = PHFetchOptions()
        options.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        return mapAssets(PHAsset.fetchAssets(in: collection, options: options))
    }

    private func imageCount(in collection: PHAssetCollection) -> Int {
        let options = PHFetchOptions()
        options.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
        return PHAsset.fetchAssets(in: collection, options: options).count
    }

    private func mapAssets(_ result: PHFetchResult<PHAsset>) -> [PHAsset] {
        var assets: [PHAsset] = []
        assets.reserveCapacity(result.count)
        for index in 0..<result.count {
            assets.append(result.object(at: index))
        }
        return assets
    }
}
