import Foundation
import Photos

@Observable
@MainActor
final class AppModel {
    let photoLibrary = PhotoLibraryService()
    let seenStore = SeenStore()
    let settings = AppSettings()

    var authorizationStatus: PHAuthorizationStatus = .notDetermined

    init() {
        authorizationStatus = photoLibrary.authorizationStatus
    }

    func refreshAuthorization() {
        authorizationStatus = photoLibrary.authorizationStatus
    }

    func requestAuthorization() async {
        authorizationStatus = await photoLibrary.requestAuthorization()
    }

    var hasPhotoAccess: Bool {
        switch authorizationStatus {
        case .authorized, .limited:
            true
        default:
            false
        }
    }
}
