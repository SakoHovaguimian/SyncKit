//
//  SyncStorage+PrimitiveInitializers.swift
//  SyncKit
//
//  Created by Sako Hovaguimian on 4/27/26.
//

import Foundation

extension SyncStorage where Value == Bool {

    public init(wrappedValue: Value,
                _ key: String) {

        self.init(
            keyName: key,
            syncGet: { syncStorageSync.bool(for: key) ?? wrappedValue },
            syncSet: { syncStorageSync.set($0, for: key) }
        )

    }

}

extension SyncStorage where Value == Int {

    public init(wrappedValue: Value,
                _ key: String) {

        self.init(
            keyName: key,
            syncGet: { syncStorageSync.int(for: key) ?? wrappedValue },
            syncSet: { syncStorageSync.set($0, for: key) }
        )

    }

}

extension SyncStorage where Value == Int64 {

    public init(wrappedValue: Value,
                _ key: String) {

        self.init(
            keyName: key,
            syncGet: { syncStorageSync.int64(for: key) ?? wrappedValue },
            syncSet: { syncStorageSync.set($0, for: key) }
        )

    }

}

extension SyncStorage where Value == Double {

    public init(wrappedValue: Value,
                _ key: String) {

        self.init(
            keyName: key,
            syncGet: { syncStorageSync.double(for: key) ?? wrappedValue },
            syncSet: { syncStorageSync.set($0, for: key) }
        )

    }

}

extension SyncStorage where Value == String {

    public init(wrappedValue: Value,
                _ key: String) {

        self.init(
            keyName: key,
            syncGet: { syncStorageSync.string(for: key) ?? wrappedValue },
            syncSet: { syncStorageSync.set($0, for: key) }
        )

    }

}

extension SyncStorage where Value == URL {

    public init(wrappedValue: Value,
                _ key: String) {

        self.init(
            keyName: key,
            syncGet: { syncStorageSync.url(for: key) ?? wrappedValue },
            syncSet: { syncStorageSync.set($0, for: key) }
        )

    }

}

extension SyncStorage where Value == Date {

    public init(wrappedValue: Value,
                _ key: String) {

        self.init(
            keyName: key,
            syncGet: { syncStorageSync.date(for: key) ?? wrappedValue },
            syncSet: { syncStorageSync.set($0, for: key) }
        )

    }

}

extension SyncStorage where Value == Data {

    public init(wrappedValue: Value,
                _ key: String) {

        self.init(
            keyName: key,
            syncGet: { syncStorageSync.data(for: key) ?? wrappedValue },
            syncSet: { syncStorageSync.set($0, for: key) }
        )

    }

}
