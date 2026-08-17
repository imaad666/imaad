import SwiftUI

enum CleanderTheme {
    static let accent = Color("AccentColor")
    static let background = Color(red: 0.957, green: 0.965, blue: 0.965)
    static let ink = Color(red: 0.12, green: 0.16, blue: 0.14)
    static let muted = Color(red: 0.35, green: 0.42, blue: 0.40)
    static let keep = Color(red: 0.18, green: 0.55, blue: 0.42)
    static let delete = Color(red: 0.78, green: 0.28, blue: 0.28)
    static let deferColor = Color(red: 0.45, green: 0.48, blue: 0.55)
    static let cardFill = Color.white.opacity(0.78)
    static let cardShadow = Color.black.opacity(0.10)

    static let screenPadding: CGFloat = 28
    static let cardRadius: CGFloat = 22
    static let cardPadding: CGFloat = 16
    static let sectionSpacing: CGFloat = 28

    static var canvas: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.96, green: 0.97, blue: 0.96),
                Color(red: 0.90, green: 0.93, blue: 0.91),
                Color(red: 0.94, green: 0.93, blue: 0.88)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
