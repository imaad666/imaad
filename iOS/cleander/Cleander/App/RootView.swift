import SwiftUI

struct RootView: View {
    @Environment(AppModel.self) private var appModel

    var body: some View {
        Group {
            if appModel.hasPhotoAccess {
                HomeView()
            } else {
                OnboardingView()
            }
        }
        .tint(CleanderTheme.accent)
        .preferredColorScheme(.light)
    }
}
