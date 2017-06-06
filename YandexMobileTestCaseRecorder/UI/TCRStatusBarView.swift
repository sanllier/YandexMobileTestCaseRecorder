//
//  TCRStatusBarView.swift
//  YandexMaps
//
//  Created by Alexander Goremykin on 24.05.17.
//  Copyright © 2017 Yandex LLC. All rights reserved.
//

import Foundation
import UIKit

class TCRStatusBarView: UIView {

    // MARK: - Constructors

    init(title: String = "") {
        self.title = title
        super.init(frame: CGRect.zero)

        backgroundColor = UIColor.red

        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false

        [
            NSLayoutAttribute.top, NSLayoutAttribute.bottom,
            NSLayoutAttribute.left, NSLayoutAttribute.right
        ].forEach{ attribute in
            addConstraint(NSLayoutConstraint(item: label, attribute: attribute, relatedBy: .equal, toItem: self,
                                             attribute: attribute, multiplier: 1.0, constant: 0.0))
        }

        label.textColor = UIColor.white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.text = title
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Internal Properties

    var title: String { didSet { label.text = title } }

    // MARK: - Private Properties

    fileprivate let label = UILabel()

}
