//
//  SyncEvent.swift
//  SyncKit
//
//  Created by Sako Hovaguimian on 4/27/26.
//

import Foundation

public struct SyncEvent: CustomStringConvertible, Equatable {

    public enum Source: Equatable {

        case initial
        case localChange
        case externalChange(ChangeReason?)

    }

    public let date: Date
    public let source: Source
    public let keys: [String]

    public var description: String {

        let timeString = self.date.formatted(date: .omitted, time: .standard)
        let keysString = self.keys.joined(separator: ", ")

        switch self.source {
        case .initial:
            return "[\(timeString)] Initial"

        case .localChange:
            return "[\(timeString)] Local change: \(keysString)"

        case .externalChange(let reason?):
            return "[\(timeString)] External change (\(reason)): \(keysString)"

        case .externalChange(nil):
            return "[\(timeString)] External change (unknown): \(keysString)"
        }

    }

}
