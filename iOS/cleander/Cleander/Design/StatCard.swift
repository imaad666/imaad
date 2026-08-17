import SwiftUI

struct StatCard: View {
    let title: String
    let value: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundStyle(CleanderTheme.accent)
                .frame(width: 44, height: 44)
                .background(CleanderTheme.accent.opacity(0.12), in: .circle)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(CleanderTheme.muted)
                Text(value)
                    .font(.headline)
                    .fontDesign(.rounded)
                    .foregroundStyle(CleanderTheme.ink)
            }

            Spacer(minLength: 0)
        }
        .padding(CleanderTheme.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(CleanderTheme.cardFill, in: RoundedRectangle(cornerRadius: CleanderTheme.cardRadius))
        .accessibilityElement(children: .combine)
    }
}
