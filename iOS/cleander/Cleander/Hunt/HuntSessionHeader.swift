import SwiftUI

struct HuntSessionHeader: View {
    let summary: String
    let reviewedCount: Int
    let remainingCount: Int
    let queuedDeleteCount: Int
    let progress: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(summary)
                .font(.subheadline)
                .fontDesign(.rounded)
                .foregroundStyle(CleanderTheme.muted)

            ProgressView(value: progress)
                .tint(CleanderTheme.accent)

            HStack {
                Text("Reviewed \(reviewedCount)")
                Spacer()
                Text("\(remainingCount) left")
                Spacer()
                Text("^[\(queuedDeleteCount) queued](inflect: true)")
            }
            .font(.footnote)
            .fontDesign(.rounded)
            .foregroundStyle(CleanderTheme.ink)
        }
        .padding(.top, 8)
        .accessibilityElement(children: .combine)
    }
}
