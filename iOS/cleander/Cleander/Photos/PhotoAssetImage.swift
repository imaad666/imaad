import SwiftUI
import Photos
import UIKit

struct PhotoAssetImage: View {
    let asset: PHAsset
    let photoLibrary: PhotoLibraryService

    @State private var image: UIImage?
    @State private var isLoading = true

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(CleanderTheme.background)
            } else {
                ContentUnavailableView(
                    "Couldn’t Load Photo",
                    systemImage: "photo"
                )
            }
        }
        .task(id: asset.localIdentifier) {
            isLoading = true
            image = nil
            image = await photoLibrary.requestImage(
                for: asset,
                targetSize: CGSize(width: 900, height: 1200)
            )
            isLoading = false
        }
    }
}
