import SwiftUI

struct HuntActionBar: View {
    let canDecide: Bool
    let canUndo: Bool
    let deleteAction: () -> Void
    let laterAction: () -> Void
    let undoAction: () -> Void
    let keepAction: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            HuntActionButton(
                title: "Delete",
                systemImage: "xmark",
                tint: .white,
                fill: CleanderTheme.delete,
                diameter: 64,
                isEnabled: canDecide,
                action: deleteAction
            )

            HuntActionButton(
                title: "Later",
                systemImage: "clock",
                tint: CleanderTheme.deferColor,
                isEnabled: canDecide,
                action: laterAction
            )

            HuntActionButton(
                title: "Undo",
                systemImage: "arrow.uturn.backward",
                tint: CleanderTheme.ink,
                isEnabled: canUndo,
                action: undoAction
            )

            HuntActionButton(
                title: "Keep",
                systemImage: "checkmark",
                tint: .white,
                fill: CleanderTheme.keep,
                diameter: 64,
                isEnabled: canDecide,
                action: keepAction
            )
        }
        .frame(maxWidth: .infinity)
    }
}
