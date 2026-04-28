//
//  SyncStorage+CollectionInitializers.swift
//  SyncKit
//
//  Created by Sako Hovaguimian on 4/27/26.
//

import Foundation

extension SyncStorage where Value == [Any] {

    public init(wrappedValue: Value,
                _ key: String) {

        self.init(
            keyName: key,
            syncGet: { syncStorageSync.array(for: key) ?? wrappedValue },
            syncSet: { syncStorageSync.set($0, for: key) }
        )

    }

}

extension SyncStorage where Value == [String: Any] {

    public init(wrappedValue: Value,
                _ key: String) {

        self.init(
            keyName: key,
            syncGet: { syncStorageSync.dictionary(for: key) ?? wrappedValue },
            syncSet: { syncStorageSync.set($0, for: key) }
        )

    }

}

extension SyncStorage where Value == [Any]? {

    public init(_ key: String) {
        
        self.init(
            keyName: key,
            syncGet: { syncStorageSync.array(for: key) },
            syncSet: { syncStorageSync.set($0, for: key) }
        )
        
    }

}

extension SyncStorage where Value == [String: Any]? {

    public init(_ key: String) {
        
        self.init(
            keyName: key,
            syncGet: { syncStorageSync.dictionary(for: key) },
            syncSet: { syncStorageSync.set($0, for: key) }
        )
        
    }

}
