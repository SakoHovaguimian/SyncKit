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
            syncGet: { syncStore.bool(for: key) ?? wrappedValue },
            syncSet: { syncStore.set($0, for: key) }
        )

    }

}

extension SyncStorage where Value == Int {

    public init(wrappedValue: Value,
                _ key: String) {

        self.init(
            keyName: key,
            syncGet: { syncStore.int(for: key) ?? wrappedValue },
            syncSet: { syncStore.set($0, for: key) }
        )

    }

}

extension SyncStorage where Value == Int64 {

    public init(wrappedValue: Value,
                _ key: String) {

        self.init(
            keyName: key,
            syncGet: { syncStore.int64(for: key) ?? wrappedValue },
            syncSet: { syncStore.set($0, for: key) }
        )

    }

}

extension SyncStorage where Value == Double {

    public init(wrappedValue: Value,
                _ key: String) {

        self.init(
            keyName: key,
            syncGet: { syncStore.double(for: key) ?? wrappedValue },
            syncSet: { syncStore.set($0, for: key) }
        )

    }

}

extension SyncStorage where Value == String {

    public init(wrappedValue: Value,
                _ key: String) {

        self.init(
            keyName: key,
            syncGet: { syncStore.string(for: key) ?? wrappedValue },
            syncSet: { syncStore.set($0, for: key) }
        )

    }

}

extension SyncStorage where Value == URL {

    public init(wrappedValue: Value,
                _ key: String) {

        self.init(
            keyName: key,
            syncGet: { syncStore.url(for: key) ?? wrappedValue },
            syncSet: { syncStore.set($0, for: key) }
        )

    }

}

extension SyncStorage where Value == Date {

    public init(wrappedValue: Value,
                _ key: String) {

        self.init(
            keyName: key,
            syncGet: { syncStore.date(for: key) ?? wrappedValue },
            syncSet: { syncStore.set($0, for: key) }
        )

    }

}

extension SyncStorage where Value == Data {

    public init(wrappedValue: Value,
                _ key: String) {

        self.init(
            keyName: key,
            syncGet: { syncStore.data(for: key) ?? wrappedValue },
            syncSet: { syncStore.set($0, for: key) }
        )

    }

}
