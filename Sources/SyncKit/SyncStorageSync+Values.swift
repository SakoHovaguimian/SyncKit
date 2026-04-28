//
//  SyncStorageSync+Values.swift
//  SyncKit
//
//  Created by Sako Hovaguimian on 4/27/26.
//

import Foundation

extension SyncStorageSync {

    public func object(forKey key: String) -> Any? {
        return self.ubiquitousObject(for: key)
    }

    public func object(for key: String) -> Any? {
        return self.ubiquitousObject(for: key)
    }

    public func string(for key: String) -> String? {
        return self.ubiquitousString(for: key)
    }

    public func url(for key: String) -> URL? {
        return self.ubiquitousString(for: key).flatMap(URL.init(string:))
    }

    public func array(for key: String) -> [Any]? {
        return self.ubiquitousArray(for: key)
    }

    public func dictionary(for key: String) -> [String: Any]? {
        return self.ubiquitousDictionary(for: key)
    }

    public func date(for key: String) -> Date? {
        return self.ubiquitousObject(for: key) as? Date
    }

    public func data(for key: String) -> Data? {
        return self.ubiquitousData(for: key)
    }

    public func int(for key: String) -> Int? {

        guard self.ubiquitousObject(for: key) != nil else { return nil }
        return Int(self.ubiquitousLongLong(for: key))

    }

    public func int64(for key: String) -> Int64? {

        guard self.ubiquitousObject(for: key) != nil else { return nil }
        return self.ubiquitousLongLong(for: key)

    }

    public func double(for key: String) -> Double? {

        guard self.ubiquitousObject(for: key) != nil else { return nil }
        return self.ubiquitousDouble(for: key)

    }

    public func bool(for key: String) -> Bool? {

        guard self.ubiquitousObject(for: key) != nil else { return nil }
        return self.ubiquitousBool(for: key)

    }

    public func rawRepresentable<R>(for key: String) -> R? where R: RawRepresentable, R.RawValue == String {

        guard let string = self.ubiquitousString(for: key) else { return nil }
        return R(rawValue: string)

    }

    public func rawRepresentable<R>(for key: String) -> R? where R: RawRepresentable, R.RawValue == Int {

        guard self.ubiquitousObject(for: key) != nil else { return nil }

        let int = Int(self.ubiquitousLongLong(for: key))
        return R(rawValue: int)

    }

    public func set(_ value: Any?,
                    for key: String) {

        self.setPropertyListValue(value, for: key)

    }

    public func set(_ value: String?,
                    for key: String) {

        self.setPropertyListValue(value, for: key)

    }

    public func set(_ value: URL?,
                    for key: String) {

        self.setPropertyListValue(value?.absoluteString, for: key)

    }

    public func set(_ value: Data?,
                    for key: String) {

        self.setPropertyListValue(value, for: key)

    }

    public func set(_ value: Date?,
                    for key: String) {

        self.setPropertyListValue(value, for: key)

    }

    public func set(_ value: [Any]?,
                    for key: String) {

        self.setPropertyListValue(value, for: key)

    }

    public func set(_ value: [String: Any]?,
                    for key: String) {

        self.setPropertyListValue(value, for: key)

    }

    public func set(_ value: Int?,
                    for key: String) {

        self.setPropertyListValue(value, for: key)

    }

    public func set(_ value: Int64?,
                    for key: String) {

        self.setPropertyListValue(value, for: key)

    }

    public func set(_ value: Double?,
                    for key: String) {

        self.setPropertyListValue(value, for: key)

    }

    public func set(_ value: Bool?,
                    for key: String) {

        self.setPropertyListValue(value, for: key)

    }

    public func set<R>(_ value: R?,
                       for key: String) where R: RawRepresentable, R.RawValue == String {

        self.setPropertyListValue(value?.rawValue, for: key)

    }

    public func set<R>(_ value: R?,
                       for key: String) where R: RawRepresentable, R.RawValue == Int {

        self.setPropertyListValue(value?.rawValue, for: key)

    }

    public func remove(for key: String) {

        self.removeUbiquitousObject(for: key)
        self.commitLocalChange(keys: [key])

    }

}

private extension SyncStorageSync {

    func setPropertyListValue(_ value: Any?,
                              for key: String) {

        if let value {
            self.setUbiquitousObject(value, for: key)
        } else {
            self.removeUbiquitousObject(for: key)
        }

        self.commitLocalChange(keys: [key])

    }

}
