import Foundation

enum AppRoute: Hashable {
    case huntSetup
    case huntSession(HuntConfiguration)
    case settings
}
