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
            syncGet: { syncStore.array(for: key) ?? wrappedValue },
            syncSet: { syncStore.set($0, for: key) }
        )

    }

}

extension SyncStorage where Value == [String: Any] {

    public init(wrappedValue: Value,
                _ key: String) {

        self.init(
            keyName: key,
            syncGet: { syncStore.dictionary(for: key) ?? wrappedValue },
            syncSet: { syncStore.set($0, for: key) }
        )

    }

}

extension SyncStorage where Value == [Any]? {

    public init(_ key: String) {
        
        self.init(
            keyName: key,
            syncGet: { syncStore.array(for: key) },
            syncSet: { syncStore.set($0, for: key) }
        )
        
    }

}

extension SyncStorage where Value == [String: Any]? {

    public init(_ key: String) {
        
        self.init(
            keyName: key,
            syncGet: { syncStore.dictionary(for: key) },
            syncSet: { syncStore.set($0, for: key) }
        )
        
    }

}
