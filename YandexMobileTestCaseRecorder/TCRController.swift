//
//  TCRController.swift
//  YandexMaps
//
//  Created by Alexander Goremykin on 24.05.17.
//  Copyright © 2017 Yandex LLC. All rights reserved.
//

import Foundation
import UIKit

public protocol TCRControllerListener: class {

    func testCaseRecordingController(_ recordingController: TCRController, didChangeState state: TCRControllerState)

}

public protocol TCRCompletionActionPerformer {

    func performCompletionAction(for testCaseInfo: TCRTestCaseInfo, uuid: String, onDone: ((_ success: Bool) -> Void)?)

}

public class TCRController: NSObject {

    // MARK: - Public Properties

    public fileprivate(set) var state: TCRControllerState = .idle {
        didSet{
            guard oldValue != state else { return }
            listeners.forEach { $0.impl?.testCaseRecordingController(self, didChangeState: state) }
        }
    }

    public var runningTestCaseInfo: TCRTestCaseInfo? {
        switch state {
        case .recording(let info): return info
        case .completion(let info): return info
        case .completionError(let info): return info
        default: return nil
        }
    }

    // MARK: - Constructors

    public init(uuid: String, testCaseIdentifierPreset: String = "") {
        self.uuid = uuid
        self.testCaseIdentifierPreset = testCaseIdentifierPreset
        super.init()

        addCompletionActionPerformer(TCRCopyIntoPasteboardActionPerformer(), withDisplayNAme: "Copy Info")

        defer {
            if let savedInfo = UserDefaults.standard.object(forKey: Static.userDefaultsStoredTestCaseKey) as? [String: Any] {
                TCRTestCaseInfo(dictionary: savedInfo).flatMap { info in
                    startRecording(with: info)
                }
            }
        }
    }

    public convenience init(uuid: String, testCaseIdentifierPreset: String = "", validationURL: URL, validationToken: String) {
        self.init(uuid: uuid, testCaseIdentifierPreset: testCaseIdentifierPreset)
        addCompletionActionPerformer(TCRValidationActionPerformer(url: validationURL, token: validationToken),
                                     withDisplayNAme: "Validate")
    }

    // MARK: - Public

    public func addListener(_ listener: TCRControllerListener) {
        listeners = listeners.filter { $0.impl != nil }
        listeners.append(WeakListener(listener))
    }

    public func removeListener(_ listener: TCRControllerListener) {
        listeners = listeners.filter { $0.impl != nil }
        if let index = listeners.index(where: { $0.impl === listener }) {
            listeners.remove(at: index)
        }
    }
    
    // MARK: -
    
    public func addCompletionActionPerformer(_ actionPerformer: TCRCompletionActionPerformer,
                                             withDisplayNAme displayName: String)
    {
        let actionPerformerInfo = TCRCompletionActionPerformerInfo(actionPerformer: actionPerformer,
                                                                   displayName: displayName)
        completionActionPerformers.append(actionPerformerInfo)
    }

    public func run(testCase: String) {
        guard state.isIdle else {
            assert(false)
            return
        }

        let info = TCRTestCaseInfo(identifier: testCase)
        startRecording(with: info)
    }

    public func runWithAlertPrompt() {
        guard state.isIdle else {
            assert(false)
            return
        }

        let alert: UIAlertView

        if state.isCompletion {
            alert = UIAlertView(title: "Test Case", message: "Completion Still Running",
                                delegate: nil, cancelButtonTitle: "Close")
        } else {
            alert = UIAlertView(title: "Test Case", message: "Enter test case identifier", delegate: self,
                                cancelButtonTitle: "Run", otherButtonTitles: "Close")
            alert.alertViewStyle = .plainTextInput
            alert.textField(at: 0)?.text = testCaseIdentifierPreset
        }

        alert.show()
    }

    public func stopCurrentTestCase() {
        guard state.isRecording else {
            assert(false)
            return
        }

        showCompletionAlert()
    }

    // MARK: - Private Properties

    fileprivate let uuid: String
    fileprivate let testCaseIdentifierPreset: String

    fileprivate var completionActionPerformers: [TCRCompletionActionPerformerInfo] = []

    fileprivate var listeners: [WeakListener] = []

}

extension TCRController: UIAlertViewDelegate {

    public func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        switch state {
        case .idle: handleSetupTestCaseAlertButtonClick(alertView: alertView, buttonIndex: buttonIndex)
        case .recording: handleCompletionAlertButtonClick(alertView: alertView, buttonIndex: buttonIndex)
        case .completion: break
        case .completionError: handleAlertButtonClickInCompletionErrorState(alertView: alertView, buttonIndex: buttonIndex)
        }
    }

}

fileprivate extension TCRController {

    fileprivate struct Static {
        static let userDefaultsStoredTestCaseKey = "test_case_recording_controller_stored_test_case_key"
    }

    fileprivate struct TCRCompletionActionPerformerInfo {

        let actionPerformer: TCRCompletionActionPerformer
        let displayName: String

    }

    fileprivate class WeakListener {

        private(set) weak var impl: TCRControllerListener?

        init(_ impl: TCRControllerListener) {
            self.impl = impl
        }

    }

    // MARK: -

    fileprivate func startRecording(with info: TCRTestCaseInfo) {
        guard state.isIdle else {
            assert(false)
            return
        }

        UserDefaults.standard.set(info.toDictionary(), forKey: Static.userDefaultsStoredTestCaseKey)
        state = .recording(info: info)
    }

    fileprivate func resetState() {
        state = .idle
        UserDefaults.standard.removeObject(forKey: Static.userDefaultsStoredTestCaseKey)
    }

    // MARK: -

    fileprivate func handleSetupTestCaseAlertButtonClick(alertView: UIAlertView, buttonIndex: Int) {
        guard state.isIdle else {
            assert(false)
            return
        }

        if buttonIndex == 0 {
            if let text = alertView.textField(at: 0)?.text, !text.isEmpty && text != testCaseIdentifierPreset {
                run(testCase: text)
            }
        } else if buttonIndex == 1 {
            return
        } else {
            assert(false)
        }
    }

    fileprivate func handleCompletionAlertButtonClick(alertView: UIAlertView, buttonIndex: Int) {
        guard let runningTestCaseInfo = runningTestCaseInfo, state.isRecording else {
            assert(false)
            return
        }

        guard buttonIndex > 0 else { return }

        let targetActionPerformerIndex = buttonIndex - 1
        guard targetActionPerformerIndex < completionActionPerformers.count else {
            assert(false)
            return
        }

        state = .completion(info: runningTestCaseInfo)
        completionActionPerformers[targetActionPerformerIndex].actionPerformer.performCompletionAction(
            for: runningTestCaseInfo,
            uuid: uuid,
            onDone: { [weak self] success in
                if success {
                    self?.resetState()
                } else {
                    self?.state = .completionError(info: runningTestCaseInfo)

                    let alert: UIAlertView
                    alert = UIAlertView(title: "Test Case", message: "Completion Error", delegate: self,
                                        cancelButtonTitle: "Retry", otherButtonTitles: "Close")
                    alert.show()
                }
            }
        )
    }

    fileprivate func handleAlertButtonClickInCompletionErrorState(alertView: UIAlertView, buttonIndex: Int) {
        guard let runningTestCaseInfo = runningTestCaseInfo, state.isCompletionError else {
            assert(false)
            return
        }

        if buttonIndex == 0 {
            state = .recording(info: runningTestCaseInfo)
            showCompletionAlert()
        } else if buttonIndex == 1 {
            resetState()
        } else {
            assert(false)
        }
    }

    fileprivate func showCompletionAlert() {
        let alert = UIAlertView(title: "Test Case", message: "Completion Option", delegate: self, cancelButtonTitle: "Close")
        completionActionPerformers.forEach {
            alert.addButton(withTitle: $0.displayName)
        }

        alert.show()
    }

}
