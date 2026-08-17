import SwiftUI

struct HuntActionButton: View {
    let title: String
    let systemImage: String
    var tint: Color = CleanderTheme.ink
    var fill: Color = .white
    var diameter: CGFloat = 56
    var isEnabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(title, systemImage: systemImage, action: action)
            .labelStyle(.iconOnly)
            .font(diameter >= 64 ? .title2 : .body)
            .foregroundStyle(tint)
            .frame(width: diameter, height: diameter)
            .background(fill, in: .circle)
            .shadow(color: CleanderTheme.cardShadow, radius: 10, y: 4)
            .disabled(!isEnabled)
            .opacity(isEnabled ? 1 : 0.4)
    }
}
