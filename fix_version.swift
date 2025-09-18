import Foundation
let defaults = UserDefaults.standard
print("🔧 Fixing version tracking...")
print("Before: lastAppVersion = \(defaults.string(forKey: "lastAppVersion") ?? "none")")

// Set the version to 1.2 to stop migration from running
defaults.set("1.2", forKey: "lastAppVersion")
defaults.synchronize()

print("After: lastAppVersion = \(defaults.string(forKey: "lastAppVersion") ?? "none")")
print("✅ Migration should no longer run on app launch")
