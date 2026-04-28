# SyncKit

A Swift property wrapper for iCloud key-value storage — built to feel exactly like `@AppStorage`, but synced across all of a user's devices via `NSUbiquitousKeyValueStore`.

---

## Table of Contents

- [Why SyncKit?](#why-synckit)
- [How It Works](#how-it-works)
- [Requirements](#requirements)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Usage Examples](#usage-examples)
  - [SwiftUI View — Direct Usage](#swiftui-view--direct-usage)
  - [ObservableObject ViewModel](#observableobject-viewmodel)
  - [Observable ViewModel (Swift 5.9+)](#observable-viewmodel-swift-59)
  - [Primitive Types](#primitive-types)
  - [Optional Types](#optional-types)
  - [Collections](#collections)
  - [RawRepresentable Enums](#rawrepresentable-enums)
  - [Codable Models](#codable-models)
- [SyncStore — Direct Store Access](#syncstore--direct-store-access)
- [SyncEvent — Observing Changes](#syncevent--observing-changes)
- [Configuration](#configuration)
- [Entitlements](#entitlements)

---

## Why SyncKit?

`NSUbiquitousKeyValueStore` is Apple's lightweight iCloud sync mechanism — no CloudKit schema, no containers to provision, no async queries. It just works, the same way `UserDefaults` works, but across devices.

The problem is its API is verbose and imperative. SyncKit wraps it in a `@SyncStorage` property wrapper that integrates directly with SwiftUI's reactivity model, just like `@AppStorage`:

```swift
// Before
let store = NSUbiquitousKeyValueStore.default
let count = store.longLong(forKey: "launchCount")
store.set(count + 1, forKey: "launchCount")

// After
@SyncStorage("launchCount") var launchCount: Int = 0
launchCount += 1
```

Changes sync automatically across all signed-in devices. The UI updates instantly on write, and refreshes again when a remote change arrives.

---

## How It Works

SyncKit is built around three internal layers:

```
@SyncStorage (property wrapper)
    └── SyncStorageObject (ObservableObject, owns the key + closures)
            └── SyncStorageKeyObserver (bridges iCloud notifications → publisher sends)
                    └── SyncStore (wraps NSUbiquitousKeyValueStore, singleton)
```

**Write path:** When you set a value via `@SyncStorage`, it calls into `SyncStore`, which writes to `NSUbiquitousKeyValueStore` and immediately calls `synchronize()`. A `SyncEvent` is published on `SyncStore.shared.lastEvent` and all registered key observers are notified — causing any SwiftUI view or `ObservableObject` holding that key to re-render.

**Read path:** `@SyncStorage` reads directly from `NSUbiquitousKeyValueStore` on every access, so it always reflects the live store value with no intermediate cache.

**Remote change path:** `SyncStore` listens for `NSUbiquitousKeyValueStore.didChangeExternallyNotification`. When a remote change arrives, it notifies only the observers registered for the changed keys, publishing a `SyncEvent` with `.externalChange` source. UI updates are scoped to exactly the views and objects that own those keys.

**Publisher ownership:** `SyncStorageKeyObserver` holds a strong reference to the `ObservableObjectPublisher` it needs to signal. When `@SyncStorage` is used inside an `ObservableObject`, the enclosing object's publisher is wired in via the static subscript, so calling `objectWillChange.send()` on both the wrapper's internal object and the enclosing object keeps everything consistent.

**Concurrency safety:** Every type in SyncKit runs on `@MainActor` via `defaultIsolation: MainActor.self`. The package also enables three upcoming Swift 6.2 concurrency features — `NonisolatedNonsendingByDefault`, `InferIsolatedConformances`, and `DisableOutwardActorInference` — which together make `@MainActor` isolation behave correctly as the package-wide default. Notification callbacks that deliver on `queue: .main` use `MainActor.assumeIsolated` rather than `Task { @MainActor in }`, avoiding any cross-isolation sends. Closures that capture a `wrappedValue` default require `Value: Sendable` on `RawRepresentable` and `Codable` initializers to satisfy the strict concurrency model.

---

## Requirements

| Requirement | Minimum |
|---|---|
| iOS | 26.0 |
| macOS | 26.0 |
| watchOS | 26.0 |
| tvOS | 26.0 |
| visionOS | 26.0 |
| Swift | 6.2 |
| Xcode | 26.0+ |

---

## Installation

### Swift Package Manager

In Xcode: **File → Add Package Dependencies**, paste the repository URL, and select the `main` branch or a version tag.

Or add it manually in `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/your-org/SyncKit", from: "1.0.0")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: ["SyncKit"]
    )
]
```

---

## Quick Start

1. Add the iCloud entitlement to your target (see [Entitlements](#entitlements)).
2. Import SyncKit.
3. Replace `@AppStorage` with `@SyncStorage`.

```swift
import SyncKit

struct SettingsView: View {

    @SyncStorage("username") var username: String = "Guest"

    var body: some View {
        TextField("Username", text: $username)
    }

}
```

That's it. The value syncs across all of the user's devices automatically.

---

## Usage Examples

### SwiftUI View — Direct Usage

The most common pattern. Drop `@SyncStorage` directly into a SwiftUI view. The binding projection (`$`) works identically to `@AppStorage`.

```swift
import SwiftUI
import SyncKit

struct OnboardingView: View {

    @SyncStorage("hasCompletedOnboarding") var hasCompleted: Bool = false
    @SyncStorage("selectedTheme") var theme: String = "system"

    var body: some View {
        VStack {
            Toggle("Onboarding complete", isOn: $hasCompleted)

            Picker("Theme", selection: $theme) {
                Text("System").tag("system")
                Text("Light").tag("light")
                Text("Dark").tag("dark")
            }
            .pickerStyle(.segmented)
        }
        .padding()
    }

}
```

---

### ObservableObject ViewModel

When `@SyncStorage` is used inside an `ObservableObject`, its static subscript wires the property wrapper into the enclosing object's `objectWillChange` publisher. The view re-renders correctly whether the change comes from local code or a remote iCloud push.

```swift
import Combine
import SyncKit
import SwiftUI

final class UserSettingsViewModel: ObservableObject {

    @SyncStorage("notificationsEnabled") var notificationsEnabled: Bool = true
    @SyncStorage("badgeCount") var badgeCount: Int = 0
    @SyncStorage("lastSyncedAt") var lastSyncedAt: Date? = nil

    func resetBadge() {
        badgeCount = 0
        lastSyncedAt = Date()
    }

}

struct SettingsView: View {

    @StateObject private var viewModel = UserSettingsViewModel()

    var body: some View {
        Form {
            Section("Notifications") {
                Toggle("Enabled", isOn: $viewModel.notificationsEnabled)
                Text("Badge: \(viewModel.badgeCount)")
                Button("Clear Badge") { viewModel.resetBadge() }
            }

            if let date = viewModel.lastSyncedAt {
                Section {
                    Text("Last synced: \(date.formatted())")
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

}
```

---

### Observable ViewModel (Swift 5.9+)

With `@Observable`, use `@SyncStorage` via the computed property pattern, reading and writing through `SyncStore.shared` directly, and call `withMutation` / use the synthesized observation tracking.

> **Note:** `@SyncStorage` as a stored property wrapper is not compatible with `@Observable` because `@Observable` macro-generates its own storage. The recommended pattern for `@Observable` classes is to expose synced values as computed properties or use `SyncStore.shared` directly.

```swift
import Observation
import SyncKit

@Observable
final class ProfileViewModel {

    var username: String {
        get { SyncStore.shared.string(for: "username") ?? "Guest" }
        set { SyncStore.shared.set(newValue, for: "username") }
    }

    var proSubscriber: Bool {
        get { SyncStore.shared.bool(for: "proSubscriber") ?? false }
        set { SyncStore.shared.set(newValue, for: "proSubscriber") }
    }

}
```

---

### Primitive Types

All standard `AppStorage`-compatible primitives are supported, both required (with a default) and optional (no default, returns `nil` when absent).

```swift
// Required — always has a value; falls back to default if key is absent
@SyncStorage("launchCount") var launchCount: Int = 0
@SyncStorage("totalDistance") var totalDistance: Double = 0.0
@SyncStorage("username") var username: String = ""
@SyncStorage("isPremium") var isPremium: Bool = false
@SyncStorage("profileURL") var profileURL: URL = URL(string: "https://example.com")!
@SyncStorage("createdAt") var createdAt: Date = .now
@SyncStorage("avatarData") var avatarData: Data = Data()
```

---

### Optional Types

When no default makes sense — use the optional initializer. Returns `nil` when the key has never been written.

```swift
@SyncStorage("lastSeenAt") var lastSeenAt: Date?
@SyncStorage("referralCode") var referralCode: String?
@SyncStorage("onboardingStep") var onboardingStep: Int?
@SyncStorage("deepLinkURL") var deepLinkURL: URL?
```

Clearing a value is as simple as setting it to `nil`:

```swift
referralCode = nil  // removes the key from iCloud KV store
```

---

### Collections

Arrays and dictionaries of property-list-compatible types are supported.

```swift
@SyncStorage("recentSearches") var recentSearches: [Any] = []
@SyncStorage("featureFlags") var featureFlags: [String: Any] = [:]

// Optional variants
@SyncStorage("pinnedItems") var pinnedItems: [Any]?
@SyncStorage("metadata") var metadata: [String: Any]?
```

> Arrays and dictionaries are erased to `[Any]` / `[String: Any]` to remain property-list-compatible. For typed collections, use the Codable initializer instead.

---

### RawRepresentable Enums

Enums conforming to `RawRepresentable & Sendable` with `String` or `Int` raw values work out of the box. The `Sendable` requirement is enforced by the compiler — virtually all enums with value-type raw values satisfy it automatically.

```swift
enum AppTheme: String {
    case system, light, dark
}

enum OnboardingStep: Int {
    case welcome, permissions, profile, done
}

// Required (with default)
@SyncStorage("appTheme") var appTheme: AppTheme = .system
@SyncStorage("onboardingStep") var onboardingStep: OnboardingStep = .welcome

// Optional (no default)
@SyncStorage("lastSelectedTab") var lastSelectedTab: AppTheme?
```

When the stored raw value can't be mapped back to a valid case (e.g. after removing a case in a new release), the default is returned for required wrappers and `nil` for optional wrappers.

---

### Codable Models

Any `Codable & Sendable` type can be stored via JSON encoding. This is the recommended approach for typed arrays, nested structures, and complex models. Value types (`struct`, `enum`) that contain only `Sendable` members satisfy `Sendable` automatically — no annotation needed.

```swift
struct UserProfile: Codable {
    var displayName: String
    var avatarURL: URL?
    var joinedAt: Date
}

// Required — must provide a wrappedValue default
@SyncStorage(wrappedValue: UserProfile(displayName: "Guest", joinedAt: .now), codable: "userProfile")
var userProfile: UserProfile

// Optional — no default needed
@SyncStorage(codable: "cachedFeed") var cachedFeed: [FeedItem]?
```

Custom encoders and decoders are supported:

```swift
let iso8601Encoder: JSONEncoder = {
    let e = JSONEncoder()
    e.dateEncodingStrategy = .iso8601
    return e
}()

@SyncStorage(
    wrappedValue: UserProfile(displayName: "Guest", joinedAt: .now),
    codable: "userProfile",
    encoder: iso8601Encoder,
    decoder: JSONDecoder()
)
var userProfile: UserProfile
```

---

## SyncStore — Direct Store Access

`SyncStore.shared` exposes the full iCloud key-value store for cases where a property wrapper isn't the right tool — e.g. app delegate startup, background tasks, or non-SwiftUI code.

```swift
import SyncKit

// Read
let count = SyncStore.shared.int(for: "launchCount") ?? 0

// Write
SyncStore.shared.set(count + 1, for: "launchCount")

// Remove
SyncStore.shared.remove(for: "referralCode")

// Force a sync (called automatically on write when synchronizesAfterLocalWrite == true)
SyncStore.shared.synchronize()
```

---

## SyncEvent — Observing Changes

`SyncStore.shared` publishes a `SyncEvent` every time the store changes, regardless of source. Subscribe to `$lastEvent` to react to any store mutation.

```swift
import Combine
import SyncKit

final class SyncMonitor: ObservableObject {

    private var cancellable: AnyCancellable?

    init() {
        cancellable = SyncStore.shared.$lastEvent
            .sink { event in
                switch event.source {
                case .initial:
                    print("Store initialized")

                case .localChange:
                    print("Local write to keys: \(event.keys)")

                case .externalChange(let reason):
                    switch reason {
                    case .serverChange:
                        print("iCloud pushed changes for: \(event.keys)")
                    case .accountChange:
                        print("iCloud account changed — keys reset")
                    case .quotaViolationChange:
                        print("iCloud quota exceeded")
                    case .initialSyncChange:
                        print("Initial iCloud sync for: \(event.keys)")
                    case .unknown(let code):
                        print("Unknown change reason \(code)")
                    case nil:
                        print("External change, unknown reason")
                    }
                }
            }
    }

}
```

`SyncEvent` conforms to `CustomStringConvertible` for convenient logging:

```swift
print(SyncStore.shared.lastEvent)
// [14:32:01] External change (serverChange): username, isPremium
```

---

## Configuration

`SyncStore.shared.synchronizesAfterLocalWrite` controls whether `synchronize()` is called after every local write. It defaults to `true`, which is the safest option and matches Apple's recommendation.

```swift
// Disable if you want to batch writes and synchronize manually
SyncStore.shared.synchronizesAfterLocalWrite = false

// ... perform many writes ...

SyncStore.shared.synchronize()
```

---

## Entitlements

iCloud key-value storage requires a single entitlement. In Xcode:

1. Select your target → **Signing & Capabilities**
2. Click **+ Capability** → add **iCloud**
3. Check **Key-value storage**

This adds `com.apple.developer.ubiquity-kvstore-identifier` to your `.entitlements` file automatically. No additional CloudKit container provisioning is required.

> **Storage limits:** Apple allows up to 1 MB total and 1024 keys per app. SyncKit does not enforce these limits — design your schema accordingly. See [Apple's documentation](https://developer.apple.com/documentation/foundation/nsubiquitouskeyvaluestore) for details.
