import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .fontDesign(.rounded)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .foregroundStyle(.white)
            .background(CleanderTheme.accent.gradient, in: RoundedRectangle(cornerRadius: CleanderTheme.cardRadius))
            .opacity(configuration.isPressed ? 0.82 : 1)
    }
}
