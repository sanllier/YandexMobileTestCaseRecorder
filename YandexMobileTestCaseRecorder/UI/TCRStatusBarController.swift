//
//  TCRStatusBarController.swift
//  YandexMaps
//
//  Created by Alexander Goremykin on 06.06.17.
//  Copyright © 2017 Yandex LLC. All rights reserved.
//

import Foundation

public class TCRStatusBarController {

    // MARK: - Constructors

    public init(container: UIView, controller: TCRController) {
        self.container = container
        self.controller = controller

        controller.addListener(self)
    }

    deinit {
        controller?.removeListener(self)
    }

    // MARK: - Private Properties

    fileprivate weak var container: UIView?
    fileprivate weak var controller: TCRController?

    fileprivate weak var testCaseStatusBarView: TCRStatusBarView?

}

extension TCRStatusBarController: TCRControllerListener {

    public func testCaseRecordingController(_ recordingController: TCRController,
                                            didChangeState state: TCRControllerState)
    {
        updateUI()
    }

}

fileprivate extension TCRStatusBarController {

    fileprivate func updateUI() {
        guard let controller = controller else { return }

        switch controller.state {
        case .idle:
            testCaseStatusBarView?.removeFromSuperview()
            
        case .recording(let info):
            setupStatusViewIfNeeded()
            testCaseStatusBarView?.title = info.identifier

        case .completion:
            setupStatusViewIfNeeded()
            testCaseStatusBarView?.title = "Completion..."

        default:
            break
        }
    }

    fileprivate func setupStatusViewIfNeeded() {
        guard testCaseStatusBarView == nil, let container = container  else { return }

        testCaseStatusBarView = { (obj: TCRStatusBarView) -> TCRStatusBarView in
            container.addSubview(obj)
            obj.translatesAutoresizingMaskIntoConstraints = false

            [NSLayoutAttribute.top, NSLayoutAttribute.left, NSLayoutAttribute.right].forEach{ attribute in
                container.addConstraint(NSLayoutConstraint(item: obj, attribute: attribute,
                                                           relatedBy: .equal, toItem: container, attribute: attribute,
                                                           multiplier: 1.0, constant: 0.0))
            }

            container.addConstraint(NSLayoutConstraint(item: obj, attribute: .bottom,
                                                       relatedBy: .equal, toItem: container, attribute: .top,
                                                       multiplier: 1.0, constant: 20.0))

            return obj
        }(TCRStatusBarView())
    }

}
