//
//  TCRValidationActionPerformer.swift
//  YandexMaps
//
//  Created by Alexander Goremykin on 24.05.17.
//  Copyright © 2017 Yandex LLC. All rights reserved.
//

import Foundation

class TCRValidationActionPerformer: NSObject, TCRCompletionActionPerformer {

    // MARK: - Constructors
    
    init(url: URL, token: String) {
        self.url = url
        self.token = token
    }

    // MARK: - Public

    func performCompletionAction(for testCaseInfo: TCRTestCaseInfo, uuid: String, onDone: ((_ success: Bool) -> Void)?) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let parameters = ["uuid": uuid,
                          "test_case_id": testCaseInfo.identifier,
                          "start_datetime": testCaseInfo.creationTimestamp,
                          "delay": "0sec",
                          "token": token]
        let parametersString = parameters.map{ (key, value) in return "\(key)=\(value)" }.reduce("", { $0.0 + "&" + $0.1 })
        request.httpBody = parametersString.data(using: .utf8)

        let task = session.dataTask(with: request){ data, response, error in
            onDone?(error == nil)
        }

        task.resume()
    }

    // MARK: - Private Propetties

    fileprivate let url: URL
    fileprivate let token: String

    fileprivate let session = URLSession(configuration: .default, delegate: nil, delegateQueue: .main)

}
