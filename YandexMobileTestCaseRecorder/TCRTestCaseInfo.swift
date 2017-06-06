//
//  TCRTestCaseInfo.swift
//  YandexMaps
//
//  Created by Alexander Goremykin on 24.05.17.
//  Copyright © 2017 Yandex LLC. All rights reserved.
//

import Foundation

public class TCRTestCaseInfo: Equatable {

    // MARK: - Public Properties

    public let identifier: String
    public let creationTimestamp: String

    // MARK: - Constructors

    init(identifier: String) {
        self.identifier = identifier

        let dateTimeFormatter = DateFormatter()
        dateTimeFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        self.creationTimestamp = dateTimeFormatter.string(from: Date())
    }

    init?(dictionary: [String: Any]) {
        guard let identifier = dictionary[Keys.identifier] as? String,
            let timestamp = dictionary[Keys.timestamp] as? String
        else {
            return nil
        }

        self.identifier = identifier
        self.creationTimestamp = timestamp
    }

    // MARK: - Public Methods

    public static func ==(lhs: TCRTestCaseInfo, rhs: TCRTestCaseInfo) -> Bool {
        return lhs.identifier == rhs.identifier && lhs.creationTimestamp == rhs.creationTimestamp
    }

    // MARK: - Internal Methods

    func toDictionary() -> [String: Any] {
        return [Keys.identifier: identifier, Keys.timestamp: creationTimestamp]
    }

}

fileprivate extension TCRTestCaseInfo {

    fileprivate struct Keys {
        static let identifier = "identifier"
        static let timestamp = "timestamp"
    }

}
