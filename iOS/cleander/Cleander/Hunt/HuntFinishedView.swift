import SwiftUI

struct HuntFinishedView: View {
    let queuedDeleteCount: Int

    var body: some View {
        ContentUnavailableView {
            Label(
                queuedDeleteCount > 0 ? "Hunt complete" : "All clear",
                systemImage: queuedDeleteCount > 0 ? "checkmark.seal.fill" : "leaf.fill"
            )
        } description: {
            Text(
                queuedDeleteCount > 0
                    ? "You queued \(queuedDeleteCount) photos. Tap I’m Done to delete them."
                    : "No more unseen photos in this hunt."
            )
        }
    }
}
