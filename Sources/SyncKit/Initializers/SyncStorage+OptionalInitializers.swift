//
//  SyncStorage+OptionalInitializers.swift
//  SyncKit
//
//  Created by Sako Hovaguimian on 4/27/26.
//

import Foundation

extension SyncStorage where Value == Bool? {

    public init(_ key: String) {
        
        self.init(
            keyName: key,
            syncGet: { syncStore.bool(for: key) },
            syncSet: { syncStore.set($0, for: key) }
        )
        
    }

}

extension SyncStorage where Value == Int? {

    public init(_ key: String) {
        
        self.init(
            keyName: key,
            syncGet: { syncStore.int(for: key) },
            syncSet: { syncStore.set($0, for: key) }
        )
        
    }

}

extension SyncStorage where Value == Int64? {

    public init(_ key: String) {
        
        self.init(
            keyName: key,
            syncGet: { syncStore.int64(for: key) },
            syncSet: { syncStore.set($0, for: key) }
        )
        
    }

}

extension SyncStorage where Value == Double? {

    public init(_ key: String) {
        
        self.init(
            keyName: key,
            syncGet: { syncStore.double(for: key) },
            syncSet: { syncStore.set($0, for: key) }
        )
        
    }

}

extension SyncStorage where Value == String? {

    public init(_ key: String) {
        
        self.init(
            keyName: key,
            syncGet: { syncStore.string(for: key) },
            syncSet: { syncStore.set($0, for: key) }
        )
        
    }

}

extension SyncStorage where Value == URL? {

    public init(_ key: String) {
        
        self.init(
            keyName: key,
            syncGet: { syncStore.url(for: key) },
            syncSet: { syncStore.set($0, for: key) }
        )
        
    }

}

extension SyncStorage where Value == Date? {

    public init(_ key: String) {
        
        self.init(
            keyName: key,
            syncGet: { syncStore.date(for: key) },
            syncSet: { syncStore.set($0, for: key) }
        )
        
    }

}

extension SyncStorage where Value == Data? {

    public init(_ key: String) {
        
        self.init(
            keyName: key,
            syncGet: { syncStore.data(for: key) },
            syncSet: { syncStore.set($0, for: key) }
        )
        
    }

}
