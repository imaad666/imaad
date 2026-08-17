import Foundation

enum SwipeDirection: Equatable {
    case left
    case right
    case up
    case down

    var decision: SwipeDecision {
        switch self {
        case .left: .delete
        case .right: .keep
        case .down: .deferForLater
        case .up: .keep
        }
    }

    var label: String {
        switch self {
        case .left: "Delete"
        case .right: "Keep"
        case .down: "Later"
        case .up: "Keep"
        }
    }
}
