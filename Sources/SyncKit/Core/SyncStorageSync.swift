//
//  SyncStorageSync.swift
//  SyncKit
//
//  Created by Sako Hovaguimian on 4/27/26.
//

import Combine
import Foundation

#if canImport(UIKit)
import UIKit
#endif

public final class SyncStorageSync: ObservableObject {

    public static let shared = SyncStorageSync()

    private let ubiquitousKeyValueStore: NSUbiquitousKeyValueStore
    private var observers: [String: [ObjectIdentifier: SyncStorageKeyObserver]] = [:]
    private var externalChangeObserver: NSObjectProtocol?
    private var foregroundObserver: NSObjectProtocol?

    @Published public private(set) var lastEvent: SyncEvent

    public var synchronizesAfterLocalWrite: Bool

    private init(ubiquitousKeyValueStore: NSUbiquitousKeyValueStore = .default,
                 synchronizesAfterLocalWrite: Bool = true) {

        self.ubiquitousKeyValueStore = ubiquitousKeyValueStore
        self.synchronizesAfterLocalWrite = synchronizesAfterLocalWrite
        self.lastEvent = SyncEvent(
            date: Date(),
            source: .initial,
            keys: []
        )

        self.externalChangeObserver = NotificationCenter.default.addObserver(
            forName: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: ubiquitousKeyValueStore,
            queue: .main
        ) { [weak self] notification in

            let reasonRaw = notification.userInfo?[NSUbiquitousKeyValueStoreChangeReasonKey] as? Int
            let keys = notification.userInfo?[NSUbiquitousKeyValueStoreChangedKeysKey] as? [String] ?? []

            MainActor.assumeIsolated {
                self?.didChangeExternally(reasonRaw: reasonRaw, keys: keys)
            }

        }

        self.synchronize()
        self.installForegroundSynchronizer()

    }

    isolated deinit {

        if let externalChangeObserver {
            NotificationCenter.default.removeObserver(externalChangeObserver)
        }

        if let foregroundObserver {
            NotificationCenter.default.removeObserver(foregroundObserver)
        }

    }

    @discardableResult
    public func synchronize() -> Bool {
        return self.ubiquitousKeyValueStore.synchronize()
    }

    internal func notifyObservers(for key: String) {

        self.observers[key, default: [:]]
            .values
            .forEach { $0.keyChanged() }

    }

    internal func addObserver(_ observer: SyncStorageKeyObserver,
                              key: String) {

        let identifier = ObjectIdentifier(observer)
        self.observers[key, default: [:]][identifier] = observer

    }

    internal func removeObserver(_ observer: SyncStorageKeyObserver) {

        let identifier = ObjectIdentifier(observer)

        for key in Array(self.observers.keys) {

            self.observers[key]?[identifier] = nil

            if self.observers[key]?.isEmpty == true {
                self.observers[key] = nil
            }

        }

    }

    internal func updateLastEvent(source: SyncEvent.Source,
                                  keys: [String]) {

        self.lastEvent = SyncEvent(
            date: Date(),
            source: source,
            keys: keys
        )

    }

    internal func commitLocalChange(keys: [String]) {

        self.updateLastEvent(
            source: .localChange,
            keys: keys
        )

        keys.forEach { self.notifyObservers(for: $0) }

        if self.synchronizesAfterLocalWrite {
            self.synchronize()
        }

    }

    internal func ubiquitousObject(for key: String) -> Any? {
        return self.ubiquitousKeyValueStore.object(forKey: key)
    }

    internal func ubiquitousString(for key: String) -> String? {
        return self.ubiquitousKeyValueStore.string(forKey: key)
    }

    internal func ubiquitousArray(for key: String) -> [Any]? {
        return self.ubiquitousKeyValueStore.array(forKey: key)
    }

    internal func ubiquitousDictionary(for key: String) -> [String: Any]? {
        return self.ubiquitousKeyValueStore.dictionary(forKey: key)
    }

    internal func ubiquitousData(for key: String) -> Data? {
        return self.ubiquitousKeyValueStore.data(forKey: key)
    }

    internal func ubiquitousLongLong(for key: String) -> Int64 {
        return self.ubiquitousKeyValueStore.longLong(forKey: key)
    }

    internal func ubiquitousDouble(for key: String) -> Double {
        return self.ubiquitousKeyValueStore.double(forKey: key)
    }

    internal func ubiquitousBool(for key: String) -> Bool {
        return self.ubiquitousKeyValueStore.bool(forKey: key)
    }

    internal func setUbiquitousObject(_ value: Any,
                                      for key: String) {

        self.ubiquitousKeyValueStore.set(value, forKey: key)

    }

    internal func removeUbiquitousObject(for key: String) {
        self.ubiquitousKeyValueStore.removeObject(forKey: key)
    }

    private func didChangeExternally(reasonRaw: Int?,
                                     keys: [String]) {

        let reason = reasonRaw.flatMap(SyncEvent.ChangeReason.init(rawValue:))

        self.updateLastEvent(
            source: .externalChange(reason),
            keys: keys
        )

        keys.forEach { self.notifyObservers(for: $0) }

    }

    private func installForegroundSynchronizer() {

        #if canImport(UIKit) && !os(watchOS)
        self.foregroundObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in

            Task { @MainActor in
                self?.synchronize()
            }

        }
        #endif

    }

}
