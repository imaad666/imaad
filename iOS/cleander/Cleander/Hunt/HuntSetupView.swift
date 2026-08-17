import SwiftUI

struct HuntSetupView: View {
    @Environment(AppModel.self) private var appModel

    let onStart: (HuntConfiguration) -> Void

    @State private var albums: [AlbumOption] = []
    @State private var selectedAlbumID: String = AlbumOption.allPhotos.id
    @State private var isUnlimited = false
    @State private var photoCount = 20
    @State private var isLoadingAlbums = true

    private var selectedAlbum: AlbumOption {
        albums.first(where: { $0.id == selectedAlbumID }) ?? .allPhotos
    }

    var body: some View {
        Form {
            Section("Album") {
                if isLoadingAlbums {
                    ProgressView("Loading albums…")
                } else if albums.isEmpty {
                    ContentUnavailableView(
                        "No albums found",
                        systemImage: "photo.on.rectangle.angled",
                        description: Text("Grant photo access or add photos to this library, then try again.")
                    )
                } else {
                    Picker("Folder", selection: $selectedAlbumID) {
                        ForEach(albums) { album in
                            Text("\(album.title) (\(album.estimatedCount))")
                                .tag(album.id)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.navigationLink)
                }
            }

            Section("How many photos?") {
                Toggle("Unlimited mode", isOn: $isUnlimited)

                if !isUnlimited {
                    Stepper(value: $photoCount, in: 5...200, step: 5) {
                        Text("^[\(photoCount) photo](inflect: true)")
                    }
                } else {
                    Text("You’ll keep going until the album is cleared of unseen photos.")
                        .foregroundStyle(.secondary)
                }
            }

            Section {
                Button("Begin Hunt", action: beginHunt)
                    .disabled(isLoadingAlbums || selectedAlbum.estimatedCount == 0)
            } footer: {
                Text("Photos you’ve already reviewed stay hidden until you reset history in Settings.")
            }
        }
        .scrollContentBackground(.hidden)
        .background(ScreenBackground())
        .navigationTitle("New Hunt")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            isUnlimited = appModel.settings.useUnlimitedByDefault
            photoCount = appModel.settings.defaultDailyCount
            albums = appModel.photoLibrary.fetchAlbums()
            if let first = albums.first {
                selectedAlbumID = first.id
            }
            isLoadingAlbums = false
        }
    }

    private func beginHunt() {
        let configuration = HuntConfiguration(
            album: selectedAlbum,
            isUnlimited: isUnlimited,
            photoCount: photoCount
        )
        onStart(configuration)
    }
}
