import SwiftUI

struct SettingsView: View {
    @Environment(AppModel.self) private var appModel
    @State private var showResetConfirmation = false

    var body: some View {
        @Bindable var settings = appModel.settings

        Form {
            Section("Defaults for new hunts") {
                Toggle("Unlimited by default", isOn: $settings.useUnlimitedByDefault)

                if !settings.useUnlimitedByDefault {
                    Stepper(value: $settings.defaultDailyCount, in: 5...200, step: 5) {
                        Text("^[\(settings.defaultDailyCount) photo](inflect: true)")
                    }
                }
            }

            Section {
                LabeledContent("Reviewed photos", value: "\(appModel.seenStore.count)")

                Button("Reset Review History", role: .destructive, action: confirmReset)
            } footer: {
                Text("Resetting lets previously kept or queued photos show up in future hunts again.")
            }

            Section("Gestures") {
                LabeledContent("Right / Keep") {
                    Text("Keep the photo")
                }
                LabeledContent("Left / Delete") {
                    Text("Queue for deletion")
                }
                LabeledContent("Down / Later") {
                    Text("Skip for now")
                }
                LabeledContent("I’m Done") {
                    Text("Confirm and delete the queue")
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(ScreenBackground())
        .navigationTitle("Settings")
        .confirmationDialog(
            "Reset review history?",
            isPresented: $showResetConfirmation,
            titleVisibility: .visible
        ) {
            Button("Reset History", role: .destructive, action: resetHistory)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Cleander will forget which photos you’ve already reviewed.")
        }
    }

    private func confirmReset() {
        showResetConfirmation = true
    }

    private func resetHistory() {
        appModel.seenStore.reset()
    }
}
