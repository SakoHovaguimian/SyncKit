// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "SyncKit",
    platforms: [
        .iOS(.v26),
        .macOS(.v26),
        .watchOS(.v26),
        .tvOS(.v26),
        .visionOS(.v26)
    ],
    products: [
        .library(
            name: "SyncKit",
            targets: ["SyncKit"]
        ),
    ],
    targets: [
        .target(
            name: "SyncKit",
            swiftSettings: [
                .defaultIsolation(MainActor.self),
                .enableUpcomingFeature("InferIsolatedConformances"),
                .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
            ]
        ),
    ]
)
