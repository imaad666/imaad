import SwiftUI
import Photos

struct DeleteQueueView: View {
    @Bindable var session: HuntSessionModel
    let photoLibrary: PhotoLibraryService
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if session.deleteQueue.isEmpty {
                    ContentUnavailableView(
                        "Queue Empty",
                        systemImage: "trash",
                        description: Text("Swipe left on photos to queue them for deletion.")
                    )
                } else {
                    List {
                        ForEach(session.deleteQueue, id: \.localIdentifier) { asset in
                            HStack(spacing: 14) {
                                PhotoAssetImage(asset: asset, photoLibrary: photoLibrary)
                                    .frame(width: 64, height: 64)
                                    .clipShape(.rect(cornerRadius: 10))

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Queued for delete")
                                        .font(.headline)
                                    if let date = asset.creationDate {
                                        Text(date, style: .date)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }

                                Spacer()

                                Button("Keep") {
                                    session.removeFromQueue(asset)
                                }
                                .buttonStyle(.bordered)
                            }
                            .padding(.vertical, 4)
                            .accessibilityElement(children: .combine)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Delete Queue")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}
