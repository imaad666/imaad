import SwiftUI

struct FeatureRow: View {
    let symbol: String
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: symbol)
                .font(.title3)
                .foregroundStyle(CleanderTheme.accent)
                .frame(width: 44, height: 44)
                .background(CleanderTheme.accent.opacity(0.12), in: .circle)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontDesign(.rounded)
                    .foregroundStyle(CleanderTheme.ink)
                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(CleanderTheme.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(CleanderTheme.cardPadding)
        .background(CleanderTheme.cardFill, in: RoundedRectangle(cornerRadius: CleanderTheme.cardRadius))
        .accessibilityElement(children: .combine)
    }
}
