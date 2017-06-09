//
//  CircleButton.swift
//  Scribe
//
//  Created by J. M. Lowe on 6/9/17.
//  Copyright © 2017 JMLeaux LLC. All rights reserved.
//

import UIKit

@IBDesignable


class CircleButton: UIButton {

    @IBInspectable var cornerRadius: CGFloat = 30.0 {
        didSet {
            setupView()
        }
    }

    override func prepareForInterfaceBuilder() {
        setupView()
    }
    
    func setupView() {
        layer.cornerRadius = cornerRadius

    }
}
