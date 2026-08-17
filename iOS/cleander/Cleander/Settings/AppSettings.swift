import Foundation

@Observable
@MainActor
final class AppSettings {
    private enum Keys {
        static let defaultDailyCount = "defaultDailyCount"
        static let useUnlimitedByDefault = "useUnlimitedByDefault"
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
    }

    var defaultDailyCount: Int {
        didSet { UserDefaults.standard.set(defaultDailyCount, forKey: Keys.defaultDailyCount) }
    }

    var useUnlimitedByDefault: Bool {
        didSet { UserDefaults.standard.set(useUnlimitedByDefault, forKey: Keys.useUnlimitedByDefault) }
    }

    var hasCompletedOnboarding: Bool {
        didSet { UserDefaults.standard.set(hasCompletedOnboarding, forKey: Keys.hasCompletedOnboarding) }
    }

    init() {
        let defaults = UserDefaults.standard
        let storedCount = defaults.object(forKey: Keys.defaultDailyCount) as? Int
        defaultDailyCount = storedCount ?? 20
        useUnlimitedByDefault = defaults.bool(forKey: Keys.useUnlimitedByDefault)
        hasCompletedOnboarding = defaults.bool(forKey: Keys.hasCompletedOnboarding)
    }
}
