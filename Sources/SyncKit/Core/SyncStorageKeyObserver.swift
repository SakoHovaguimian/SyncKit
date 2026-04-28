//
//  SyncStorageKeyObserver.swift
//  SyncKit
//
//  Created by Sako Hovaguimian on 4/27/26.
//

import Combine

internal final class SyncStorageKeyObserver {

    internal var storageObjectWillChange: ObservableObjectPublisher?
    internal var enclosingObjectWillChange: ObservableObjectPublisher?

    internal func keyChanged() {

        self.storageObjectWillChange?.send()
        self.enclosingObjectWillChange?.send()

    }

}
