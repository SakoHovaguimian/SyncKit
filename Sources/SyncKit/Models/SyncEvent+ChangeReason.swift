//
//  SyncEvent+ChangeReason.swift
//  SyncKit
//
//  Created by Sako Hovaguimian on 4/27/26.
//

import Foundation

extension SyncEvent {

    public enum ChangeReason: Equatable {

        case serverChange
        case initialSyncChange
        case quotaViolationChange
        case accountChange
        case unknown(Int)

        internal init(rawValue: Int) {

            switch rawValue {
            case NSUbiquitousKeyValueStoreServerChange:
                self = .serverChange

            case NSUbiquitousKeyValueStoreInitialSyncChange:
                self = .initialSyncChange

            case NSUbiquitousKeyValueStoreQuotaViolationChange:
                self = .quotaViolationChange

            case NSUbiquitousKeyValueStoreAccountChange:
                self = .accountChange

            default:
                self = .unknown(rawValue)
            }

        }

    }

}
