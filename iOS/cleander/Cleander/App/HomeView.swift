import SwiftUI

struct HomeView: View {
    @Environment(AppModel.self) private var appModel
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                ScreenBackground()

                VStack(alignment: .leading, spacing: CleanderTheme.sectionSpacing) {
                    AppMark()

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Cleander")
                            .font(.largeTitle)
                            .fontDesign(.serif)
                            .bold()
                            .foregroundStyle(CleanderTheme.ink)

                        Text("Pick a folder, swipe through a random set, and clear what you don’t need.")
                            .font(.body)
                            .fontDesign(.rounded)
                            .foregroundStyle(CleanderTheme.muted)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    VStack(spacing: 12) {
                        StatCard(
                            title: "Already reviewed",
                            value: "\(appModel.seenStore.count)",
                            systemImage: "eye"
                        )
                        StatCard(
                            title: "Default hunt size",
                            value: appModel.settings.useUnlimitedByDefault
                                ? "Unlimited"
                                : "\(appModel.settings.defaultDailyCount)",
                            systemImage: "rectangle.stack"
                        )
                    }

                    Spacer()

                    VStack(spacing: 12) {
                        Button("Start New Hunt", systemImage: "sparkles", action: startHunt)
                            .buttonStyle(PrimaryButtonStyle())

                        Button("Settings", systemImage: "gearshape", action: openSettings)
                            .font(.body)
                            .fontDesign(.rounded)
                            .foregroundStyle(CleanderTheme.ink)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                }
                .padding(CleanderTheme.screenPadding)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .huntSetup:
                    HuntSetupView { configuration in
                        path.append(AppRoute.huntSession(configuration))
                    }
                case .huntSession(let configuration):
                    HuntSessionView(configuration: configuration) {
                        path = NavigationPath()
                    }
                case .settings:
                    SettingsView()
                }
            }
        }
    }

    private func startHunt() {
        path.append(AppRoute.huntSetup)
    }

    private func openSettings() {
        path.append(AppRoute.settings)
    }
}
