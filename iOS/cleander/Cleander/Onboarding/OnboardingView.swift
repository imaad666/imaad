import SwiftUI
import UIKit

struct OnboardingView: View {
    @Environment(AppModel.self) private var appModel
    @State private var isRequesting = false

    var body: some View {
        ZStack {
            ScreenBackground()

            VStack(alignment: .leading, spacing: 0) {
                Spacer(minLength: 40)

                AppMark()

                Text("Cleander")
                    .font(.largeTitle)
                    .fontDesign(.serif)
                    .bold()
                    .foregroundStyle(CleanderTheme.ink)
                    .padding(.top, 16)

                Text("Clear your camera roll one hunt at a time.")
                    .font(.title3)
                    .fontDesign(.rounded)
                    .foregroundStyle(CleanderTheme.muted)
                    .padding(.top, 8)
                    .fixedSize(horizontal: false, vertical: true)

                VStack(alignment: .leading, spacing: 12) {
                    FeatureRow(
                        symbol: "rectangle.stack",
                        title: "Start a hunt",
                        detail: "Pick an album and how many photos to review."
                    )
                    FeatureRow(
                        symbol: "hand.draw",
                        title: "Swipe to decide",
                        detail: "Right keep · Left delete · Down later."
                    )
                    FeatureRow(
                        symbol: "checkmark.circle",
                        title: "Batch delete",
                        detail: "Queue deletes, then tap I’m Done when ready."
                    )
                }
                .padding(.top, 32)

                Spacer()

                Button(action: requestAccess) {
                    HStack {
                        if isRequesting {
                            ProgressView()
                                .tint(.white)
                        }
                        Text(isRequesting ? "Waiting…" : "Allow Photo Access")
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(isRequesting)

                if appModel.authorizationStatus == .denied || appModel.authorizationStatus == .restricted {
                    Text("Photos access is off. Enable it in Settings to start hunting.")
                        .font(.footnote)
                        .foregroundStyle(CleanderTheme.muted)
                        .padding(.top, 12)

                    Button("Open Settings", action: openSettings)
                        .padding(.top, 4)
                }
            }
            .padding(CleanderTheme.screenPadding)
        }
    }

    private func requestAccess() {
        Task {
            isRequesting = true
            await appModel.requestAuthorization()
            appModel.settings.hasCompletedOnboarding = true
            isRequesting = false
        }
    }

    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}
