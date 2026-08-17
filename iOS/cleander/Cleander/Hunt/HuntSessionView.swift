import SwiftUI
import Photos

struct HuntSessionView: View {
    @Environment(AppModel.self) private var appModel

    let configuration: HuntConfiguration
    let onExit: () -> Void

    @State private var session: HuntSessionModel?
    @State private var showDoneConfirmation = false
    @State private var showQueue = false
    @State private var isDeleting = false
    @State private var deleteError: String?
    @State private var showDeleteError = false
    @State private var triggerKeep = false
    @State private var triggerDelete = false

    var body: some View {
        ZStack {
            ScreenBackground()

            if let session {
                sessionContent(session)
            } else {
                ProgressView("Starting hunt…")
            }
        }
        .navigationTitle("Hunt")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await startSession()
        }
        .alert("Couldn’t Delete", isPresented: $showDeleteError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(deleteError ?? "Something went wrong.")
        }
        .sensoryFeedback(.success, trigger: triggerKeep)
        .sensoryFeedback(.warning, trigger: triggerDelete)
    }

    @ViewBuilder
    private func sessionContent(_ session: HuntSessionModel) -> some View {
        VStack(spacing: 16) {
            HuntSessionHeader(
                summary: configuration.summary,
                reviewedCount: session.reviewedCount,
                remainingCount: session.remainingCount,
                queuedDeleteCount: session.queuedDeleteCount,
                progress: session.progress
            )

            Group {
                if session.isLoading {
                    ProgressView("Shuffling photos…")
                } else if let asset = session.currentAsset {
                    SwipeCardView(asset: asset, photoLibrary: appModel.photoLibrary) { direction in
                        handleSwipe(direction, session: session)
                    }
                    .padding(.vertical, 8)
                    .id(asset.localIdentifier)
                } else {
                    HuntFinishedView(queuedDeleteCount: session.queuedDeleteCount)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            HuntActionBar(
                canDecide: session.currentAsset != nil,
                canUndo: !session.history.isEmpty,
                deleteAction: { handleSwipe(.left, session: session) },
                laterAction: { handleSwipe(.down, session: session) },
                undoAction: { session.undo() },
                keepAction: { handleSwipe(.right, session: session) }
            )

            Button(action: { finishHunt(session) }) {
                if isDeleting {
                    ProgressView()
                        .tint(.white)
                        .frame(maxWidth: .infinity)
                } else {
                    Text(session.queuedDeleteCount > 0 ? "I’m Done" : "Finish Hunt")
                }
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(isDeleting)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 12)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Queue \(session.queuedDeleteCount)", systemImage: "trash") {
                    showQueue = true
                }
                .disabled(session.queuedDeleteCount == 0)
            }
        }
        .sheet(isPresented: $showQueue) {
            DeleteQueueView(session: session, photoLibrary: appModel.photoLibrary)
        }
        .confirmationDialog(
            "Delete \(session.queuedDeleteCount) photos?",
            isPresented: $showDoneConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete \(session.queuedDeleteCount)", role: .destructive) {
                Task { await commitDeletes(session) }
            }
            Button("Finish Without Deleting") {
                onExit()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Only photos you swiped left will be removed. This can’t be undone from Cleander.")
        }
    }

    private func startSession() async {
        let model = HuntSessionModel(
            configuration: configuration,
            photoLibrary: appModel.photoLibrary,
            seenStore: appModel.seenStore
        )
        await model.load()
        session = model
    }

    private func finishHunt(_ session: HuntSessionModel) {
        if session.queuedDeleteCount > 0 {
            showDoneConfirmation = true
        } else {
            onExit()
        }
    }

    private func handleSwipe(_ direction: SwipeDirection, session: HuntSessionModel) {
        switch direction {
        case .left:
            triggerDelete.toggle()
        case .right, .up:
            triggerKeep.toggle()
        case .down:
            break
        }
        withAnimation(.easeInOut(duration: 0.15)) {
            session.apply(direction.decision)
        }
    }

    private func commitDeletes(_ session: HuntSessionModel) async {
        isDeleting = true
        defer { isDeleting = false }
        do {
            try await session.commitDeletes()
            onExit()
        } catch {
            deleteError = error.localizedDescription
            showDeleteError = true
        }
    }
}
