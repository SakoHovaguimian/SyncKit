//
//  SyncStorage+RawRepresentableInitializers.swift
//  SyncKit
//
//  Created by Sako Hovaguimian on 4/27/26.
//

extension SyncStorage where Value: RawRepresentable & Sendable, Value.RawValue == Int {

    public init(wrappedValue: Value,
                _ key: String) {

        self.init(
            keyName: key,
            syncGet: { syncStorageSync.int(for: key).flatMap(Value.init(rawValue:)) ?? wrappedValue },
            syncSet: { syncStorageSync.set($0.rawValue, for: key) }
        )

    }

}

extension SyncStorage where Value: RawRepresentable & Sendable, Value.RawValue == String {

    public init(wrappedValue: Value,
                _ key: String) {

        self.init(
            keyName: key,
            syncGet: { syncStorageSync.string(for: key).flatMap(Value.init(rawValue:)) ?? wrappedValue },
            syncSet: { syncStorageSync.set($0.rawValue, for: key) }
        )

    }

}

extension SyncStorage {

    public init<R>(_ key: String) where Value == R?, R: RawRepresentable, R.RawValue == Int {
        
        self.init(
            keyName: key,
            syncGet: { syncStorageSync.rawRepresentable(for: key) },
            syncSet: { syncStorageSync.set($0, for: key) }
        )
        
    }

    public init<R>(_ key: String) where Value == R?, R: RawRepresentable, R.RawValue == String {
        
        self.init(
            keyName: key,
            syncGet: { syncStorageSync.rawRepresentable(for: key) },
            syncSet: { syncStorageSync.set($0, for: key) }
        )
        
    }

}
