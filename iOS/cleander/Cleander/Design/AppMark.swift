import SwiftUI

struct AppMark: View {
    @ScaledMetric(relativeTo: .largeTitle) private var size = 72

    var body: some View {
        Image(systemName: "leaf.fill")
            .font(.largeTitle)
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(CleanderTheme.accent.gradient, in: RoundedRectangle(cornerRadius: size * 0.24))
            .accessibilityHidden(true)
    }
}
