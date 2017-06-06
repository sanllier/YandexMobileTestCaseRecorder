//
//  TCRCopyIntoPasteboardActionPerformer.swift
//  YandexMaps
//
//  Created by Alexander Goremykin on 24.05.17.
//  Copyright © 2017 Yandex LLC. All rights reserved.
//

import Foundation
import UIKit

class TCRCopyIntoPasteboardActionPerformer: TCRCompletionActionPerformer {

    // MARK: - Public

    func performCompletionAction(for testCaseInfo: TCRTestCaseInfo, uuid: String, onDone: ((_ success: Bool) -> Void)?) {
        var infoString = ""
        infoString += "uuid=\(uuid) "
        infoString += "test_case_id=\(testCaseInfo.identifier) "
        infoString += "start_datetime=\(testCaseInfo.creationTimestamp)"
        UIPasteboard.general.string = infoString

        onDone?(true)
    }

}
