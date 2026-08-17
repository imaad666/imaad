import Foundation
import Photos

enum SwipeDecision: String {
    case keep
    case delete
    case deferForLater
}

struct HuntAction: Identifiable {
    let id = UUID()
    let asset: PHAsset
    let decision: SwipeDecision
}

@Observable
@MainActor
final class HuntSessionModel {
    let configuration: HuntConfiguration
    private let photoLibrary: PhotoLibraryService
    private let seenStore: SeenStore

    private(set) var deck: [PHAsset] = []
    private(set) var deleteQueue: [PHAsset] = []
    private(set) var history: [HuntAction] = []
    private(set) var reviewedCount = 0
    private(set) var isLoading = true
    private(set) var loadError: String?
    private(set) var isFinished = false
    private(set) var didCommitDeletes = false

    var currentAsset: PHAsset? { deck.first }
    var remainingCount: Int { deck.count }
    var queuedDeleteCount: Int { deleteQueue.count }

    var progress: Double {
        let total = reviewedCount + remainingCount
        guard total > 0 else { return 1 }
        return Double(reviewedCount) / Double(total)
    }

    init(
        configuration: HuntConfiguration,
        photoLibrary: PhotoLibraryService,
        seenStore: SeenStore
    ) {
        self.configuration = configuration
        self.photoLibrary = photoLibrary
        self.seenStore = seenStore
    }

    func load() async {
        isLoading = true
        loadError = nil
        let assets = photoLibrary.fetchHuntAssets(
            album: configuration.album,
            excluding: seenStore.identifiers,
            limit: configuration.displayLimit
        )
        deck = assets
        isLoading = false
        if assets.isEmpty {
            isFinished = true
            loadError = nil
        }
    }

    func apply(_ decision: SwipeDecision) {
        guard let asset = deck.first else { return }
        deck.removeFirst()
        reviewedCount += 1
        history.append(HuntAction(asset: asset, decision: decision))

        switch decision {
        case .keep:
            seenStore.markSeen(asset.localIdentifier)
        case .delete:
            deleteQueue.append(asset)
            seenStore.markSeen(asset.localIdentifier)
        case .deferForLater:
            break
        }

        if deck.isEmpty {
            isFinished = true
        }
    }

    func undo() {
        guard let last = history.popLast() else { return }
        reviewedCount = max(reviewedCount - 1, 0)
        isFinished = false

        switch last.decision {
        case .keep:
            seenStore.unmark(last.asset.localIdentifier)
        case .delete:
            if let index = deleteQueue.lastIndex(where: { $0.localIdentifier == last.asset.localIdentifier }) {
                deleteQueue.remove(at: index)
            }
            seenStore.unmark(last.asset.localIdentifier)
        case .deferForLater:
            break
        }

        deck.insert(last.asset, at: 0)
    }

    func removeFromQueue(_ asset: PHAsset) {
        deleteQueue.removeAll { $0.localIdentifier == asset.localIdentifier }
    }

    func commitDeletes() async throws {
        try await photoLibrary.deleteAssets(deleteQueue)
        deleteQueue.removeAll()
        didCommitDeletes = true
    }
}
