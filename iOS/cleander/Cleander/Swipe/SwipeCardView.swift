import SwiftUI
import Photos

struct SwipeCardView: View {
    let asset: PHAsset
    let photoLibrary: PhotoLibraryService
    let onSwipe: (SwipeDirection) -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var offset: CGSize = .zero
    @State private var activeDirection: SwipeDirection?

    private let threshold: CGFloat = 120

    var body: some View {
        ZStack {
            PhotoAssetImage(asset: asset, photoLibrary: photoLibrary)
                .clipShape(.rect(cornerRadius: 28))
                .overlay {
                    RoundedRectangle(cornerRadius: 28)
                        .strokeBorder(.white.opacity(0.35), lineWidth: 1)
                }
                .shadow(color: CleanderTheme.cardShadow, radius: 24, y: 14)

            swipeOverlay
        }
        .offset(offset)
        .rotationEffect(.degrees(Double(offset.width / 24)))
        .gesture(dragGesture)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Photo")
        .accessibilityHint("Swipe right to keep, left to delete, down to see later.")
        .accessibilityAction(named: "Keep") { onSwipe(.right) }
        .accessibilityAction(named: "Delete") { onSwipe(.left) }
        .accessibilityAction(named: "Later") { onSwipe(.down) }
    }

    @ViewBuilder
    private var swipeOverlay: some View {
        if let activeDirection {
            Text(activeDirection.label.uppercased())
                .font(.title2.bold())
                .fontDesign(.rounded)
                .tracking(2)
                .foregroundStyle(.white)
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .background(badgeColor(for: activeDirection).opacity(0.92))
                .clipShape(.rect(cornerRadius: 12))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: badgeAlignment(for: activeDirection))
                .padding(28)
                .allowsHitTesting(false)
        }
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                offset = value.translation
                activeDirection = direction(for: value.translation)
            }
            .onEnded { value in
                if let direction = direction(for: value.translation),
                   hypot(value.translation.width, value.translation.height) > threshold {
                    completeSwipe(direction)
                } else {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        offset = .zero
                        activeDirection = nil
                    }
                }
            }
    }

    private func completeSwipe(_ direction: SwipeDirection) {
        if reduceMotion {
            onSwipe(direction)
            offset = .zero
            activeDirection = nil
            return
        }

        withAnimation(.easeOut(duration: 0.18)) {
            offset = flingOffset(for: direction)
        }

        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(180))
            onSwipe(direction)
            offset = .zero
            activeDirection = nil
        }
    }

    private func direction(for translation: CGSize) -> SwipeDirection? {
        let absX = abs(translation.width)
        let absY = abs(translation.height)
        guard max(absX, absY) > 40 else { return nil }

        if absX > absY {
            return translation.width < 0 ? .left : .right
        }
        return translation.height < 0 ? .up : .down
    }

    private func flingOffset(for direction: SwipeDirection) -> CGSize {
        switch direction {
        case .left: CGSize(width: -700, height: 0)
        case .right: CGSize(width: 700, height: 0)
        case .up: CGSize(width: 0, height: -900)
        case .down: CGSize(width: 0, height: 900)
        }
    }

    private func badgeColor(for direction: SwipeDirection) -> Color {
        switch direction {
        case .left: CleanderTheme.delete
        case .right, .up: CleanderTheme.keep
        case .down: CleanderTheme.deferColor
        }
    }

    private func badgeAlignment(for direction: SwipeDirection) -> Alignment {
        switch direction {
        case .left: .trailing
        case .right: .leading
        case .up: .bottom
        case .down: .top
        }
    }
}
