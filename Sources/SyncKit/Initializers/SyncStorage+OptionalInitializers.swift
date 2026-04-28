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
            syncGet: { syncStorageSync.bool(for: key) },
            syncSet: { syncStorageSync.set($0, for: key) }
        )
        
    }

}

extension SyncStorage where Value == Int? {

    public init(_ key: String) {
        
        self.init(
            keyName: key,
            syncGet: { syncStorageSync.int(for: key) },
            syncSet: { syncStorageSync.set($0, for: key) }
        )
        
    }

}

extension SyncStorage where Value == Int64? {

    public init(_ key: String) {
        
        self.init(
            keyName: key,
            syncGet: { syncStorageSync.int64(for: key) },
            syncSet: { syncStorageSync.set($0, for: key) }
        )
        
    }

}

extension SyncStorage where Value == Double? {

    public init(_ key: String) {
        
        self.init(
            keyName: key,
            syncGet: { syncStorageSync.double(for: key) },
            syncSet: { syncStorageSync.set($0, for: key) }
        )
        
    }

}

extension SyncStorage where Value == String? {

    public init(_ key: String) {
        
        self.init(
            keyName: key,
            syncGet: { syncStorageSync.string(for: key) },
            syncSet: { syncStorageSync.set($0, for: key) }
        )
        
    }

}

extension SyncStorage where Value == URL? {

    public init(_ key: String) {
        
        self.init(
            keyName: key,
            syncGet: { syncStorageSync.url(for: key) },
            syncSet: { syncStorageSync.set($0, for: key) }
        )
        
    }

}

extension SyncStorage where Value == Date? {

    public init(_ key: String) {
        
        self.init(
            keyName: key,
            syncGet: { syncStorageSync.date(for: key) },
            syncSet: { syncStorageSync.set($0, for: key) }
        )
        
    }

}

extension SyncStorage where Value == Data? {

    public init(_ key: String) {
        
        self.init(
            keyName: key,
            syncGet: { syncStorageSync.data(for: key) },
            syncSet: { syncStorageSync.set($0, for: key) }
        )
        
    }

}
