//
//  SyncStorage.swift
//  SyncKit
//
//  Created by Sako Hovaguimian on 4/27/26.
//

import Combine
import SwiftUI

internal let syncStorageSync = SyncStorageSync.shared

@propertyWrapper
public struct SyncStorage<Value>: DynamicProperty {

    @ObservedObject private var object: SyncStorageObject<Value>

    public var wrappedValue: Value {
        get { self.object.value }
        nonmutating set { self.object.value = newValue }
    }

    public var projectedValue: Binding<Value> {
        return self.$object.value
    }

    public init(keyName key: String,
                syncGet: @escaping () -> Value,
                syncSet: @escaping (Value) -> Void) {

        self.object = SyncStorageObject(
            key: key,
            syncGet: syncGet,
            syncSet: syncSet
        )

    }

    public static subscript<EnclosingSelf: ObservableObject>(
        _enclosingInstance instance: EnclosingSelf,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<EnclosingSelf, Value>,
        storage storageKeyPath: ReferenceWritableKeyPath<EnclosingSelf, Self>
    ) -> Value {
        get {
            let storage = instance[keyPath: storageKeyPath]
            storage.object.keyObserver.enclosingObjectWillChange = instance.objectWillChange as? ObservableObjectPublisher
            return storage.wrappedValue
        }
        set {
            instance[keyPath: storageKeyPath].wrappedValue = newValue
        }
    }

}

extension SyncStorage: Sendable where Value: Sendable {}
