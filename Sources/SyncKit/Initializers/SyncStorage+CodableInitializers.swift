//
//  SyncStorage+CodableInitializers.swift
//  SyncKit
//
//  Created by Sako Hovaguimian on 4/27/26.
//

import Foundation

extension SyncStorage where Value: Codable & Sendable {

    public init(wrappedValue: Value,
                codable key: String,
                encoder: JSONEncoder = JSONEncoder(),
                decoder: JSONDecoder = JSONDecoder()) {

        self.init(
            keyName: key,
            syncGet: {

                guard let data = syncStorageSync.data(for: key) else {
                    return wrappedValue
                }

                return (try? decoder.decode(Value.self, from: data)) ?? wrappedValue

            },
            syncSet: { value in

                guard let data = try? encoder.encode(value) else { return }
                syncStorageSync.set(data, for: key)

            }
        )

    }

}

extension SyncStorage {

    public init<R>(codable key: String,
                   encoder: JSONEncoder = JSONEncoder(),
                   decoder: JSONDecoder = JSONDecoder()) where Value == R?, R: Codable {

        self.init(
            keyName: key,
            syncGet: {

                guard let data = syncStorageSync.data(for: key) else {
                    return nil
                }

                return try? decoder.decode(R.self, from: data)

            },
            syncSet: { value in

                guard let value else {
                    syncStorageSync.remove(for: key)
                    return
                }

                guard let data = try? encoder.encode(value) else { return }
                syncStorageSync.set(data, for: key)

            }
        )

    }

}
