//
//  SyncStorageObject.swift
//  SyncKit
//
//  Created by Sako Hovaguimian on 4/27/26.
//

import Combine
import Foundation

internal final class SyncStorageObject<Value>: ObservableObject {

    private let key: String
    private let syncGet: () -> Value
    private let syncSet: (Value) -> Void

    internal let keyObserver = SyncStorageKeyObserver()

    internal var value: Value {
        get { self.syncGet() }
        set {
            self.syncSet(newValue)
        }
    }

    internal init(key: String,
                  syncGet: @escaping () -> Value,
                  syncSet: @escaping (Value) -> Void) {

        self.key = key
        self.syncGet = syncGet
        self.syncSet = syncSet

        self.keyObserver.storageObjectWillChange = self.objectWillChange
        syncStore.addObserver(self.keyObserver, key: key)

    }

    deinit {

        Task { @MainActor [keyObserver] in
            syncStore.removeObserver(keyObserver)
        }

    }

}
