//
//  TCRControllerState.swift
//  YandexMaps
//
//  Created by Alexander Goremykin on 24.05.17.
//  Copyright © 2017 Yandex LLC. All rights reserved.
//

import Foundation

public enum TCRControllerState: Equatable {

    case idle
    case recording(info: TCRTestCaseInfo)
    case completion(info: TCRTestCaseInfo)
    case completionError(info: TCRTestCaseInfo)

    // MARK: - Public Methods

    public static func ==(lhs: TCRControllerState, rhs: TCRControllerState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle): return true
        case (.recording(let lInfo), .recording(let rInfo)): return lInfo == rInfo
        case (.completion(let lInfo), .completion(let rInfo)): return lInfo == rInfo
        case (.completionError(let lInfo), .completionError(let rInfo)): return lInfo == rInfo
        default: return false
        }
    }

    // MARK: - Internal Properties

    var isIdle: Bool {
        guard case .idle = self else { return false }
        return true
    }

    var isRecording: Bool {
        guard case .recording = self else { return false }
        return true
    }

    var isCompletion: Bool {
        guard case .completion = self else { return false }
        return true
    }

    var isCompletionError: Bool {
        guard case .completionError = self else { return false }
        return true
    }

}
